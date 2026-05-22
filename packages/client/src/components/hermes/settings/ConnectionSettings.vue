<script setup lang="ts">
import { ref, onMounted } from "vue";
import { NSelect, NInput, NButton, useMessage, NAlert } from "naive-ui";
import { useI18n } from "vue-i18n";
import { setServerUrl, getBaseUrlValue, setApiKey, getApiKey, clearApiKey } from "@/api/client";
import { useAppStore } from "@/stores/hermes/app";

const LOCAL_AUTH_TOKEN_KEY = 'hermes_local_auth_token'
const { t } = useI18n();
const message = useMessage();
const appStore = useAppStore();

const serverUrl = ref("");
const apiKey = ref("");
const showApiKey = ref(false);
const localAuthToken = ref("");
const showLocalAuthToken = ref(false);
const localHealthOk = ref(false);
const localHealthLoading = ref(true);
const testConnectionLoading = ref(false);
const testConnectionResult = ref<'success' | 'error' | null>(null);
const testConnectionMessage = ref("");

/** Build the base URL for direct Koa access bypassing Vite proxy */
function koaBaseUrl(): string {
  return import.meta.env.DEV ? 'http://127.0.0.1:8648' : ''
}

/** Check Koa /health (public, no auth required) */
async function checkLocalHealth() {
  try {
    localHealthLoading.value = true;
    const res = await fetch(`${koaBaseUrl()}/health`);
    localHealthOk.value = res.ok;
  } catch {
    localHealthOk.value = false;
  } finally {
    localHealthLoading.value = false;
  }
}

onMounted(async () => {
  appStore.syncDeployMode();
  serverUrl.value = getBaseUrlValue();
  apiKey.value = getApiKey();
  localAuthToken.value = localStorage.getItem(LOCAL_AUTH_TOKEN_KEY) || ''
  console.log('[ConnectionSettings] onMounted - deployMode:', appStore.deployMode, 'serverUrl:', serverUrl.value);

  if (appStore.deployMode === "local") {
    await checkLocalHealth();
  }
});

function saveLocalAuthToken() {
  if (localAuthToken.value.trim()) {
    localStorage.setItem(LOCAL_AUTH_TOKEN_KEY, localAuthToken.value.trim())
  } else {
    localStorage.removeItem(LOCAL_AUTH_TOKEN_KEY)
  }
  message.success(t("settings.saved"))
}

async function handleModeChange(mode: "local" | "remote") {
  console.log('[ConnectionSettings] handleModeChange - switching to:', mode);

  if (appStore.deployMode === "remote" && serverUrl.value.trim()) {
    let url = serverUrl.value.trim();
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      url = "http://" + url;
    }
    url = url.replace(/\/+$/, "");
    setServerUrl(url);
  }

  if (mode === "local") {
    // 备份远程 URL 后清除 localStorage，使 syncDeployMode 正确返回 "local"
    const currentUrl = getBaseUrlValue()
    if (currentUrl) {
      localStorage.setItem('hermes_server_url_backup', currentUrl)
    }
    localStorage.removeItem('hermes_server_url')
    serverUrl.value = "";
    await checkLocalHealth();
    message.success(t("settings.connection.switchToLocal"));
  } else {
    if (!serverUrl.value.trim()) {
      // 优先从备份恢复远程 URL
      const savedUrl = getBaseUrlValue() || localStorage.getItem('hermes_server_url_backup') || '';
      if (savedUrl) {
        serverUrl.value = savedUrl;
      }
    }
    if (serverUrl.value.trim()) {
      let url = serverUrl.value.trim();
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "http://" + url;
      }
      url = url.replace(/\/+$/, "");
      setServerUrl(url);
    }
    if (apiKey.value.trim()) {
      setApiKey(apiKey.value.trim());
    }
    message.success(t("settings.connection.switchToRemote"));
  }

  appStore.syncDeployMode();
}

function handleUrlSave() {
  console.log('[ConnectionSettings] handleUrlSave - called');
  console.log('[ConnectionSettings] handleUrlSave - raw serverUrl:', serverUrl.value);

  if (!serverUrl.value.trim()) {
    console.log('[ConnectionSettings] handleUrlSave - validation failed: empty URL');
    message.error(t("settings.connection.urlRequired"));
    return;
  }

  let url = serverUrl.value.trim();
  if (!url.startsWith("http://") && !url.startsWith("https://")) {
    console.log('[ConnectionSettings] handleUrlSave - auto-prefixing http://');
    url = "http://" + url;
  }
  url = url.replace(/\/+$/, "");
  console.log('[ConnectionSettings] handleUrlSave - normalized URL:', url);

  setServerUrl(url);
  console.log('[ConnectionSettings] handleUrlSave - setServerUrl called');
  console.log('[ConnectionSettings] handleUrlSave - verify localStorage:', getBaseUrlValue());

  message.success(t("settings.saved") + ' ' + t("settings.connection.pageRefresh"));
  console.log('[ConnectionSettings] handleUrlSave - success message shown');
  
  // 刷新页面使配置生效
  setTimeout(() => {
    window.location.reload();
  }, 1000);
}

function handleApiKeySave() {
  console.log('[ConnectionSettings] handleApiKeySave - called');
  console.log('[ConnectionSettings] handleApiKeySave - apiKey value:', apiKey.value ? 'yes (masked)' : 'empty');

  if (!apiKey.value.trim()) {
    console.log('[ConnectionSettings] handleApiKeySave - clearing API key');
    clearApiKey();
    console.log('[ConnectionSettings] handleApiKeySave - verify localStorage after clear:', getApiKey() ? 'yes' : 'no');
    message.success(t("settings.saved"));
    return;
  }

  setApiKey(apiKey.value.trim());
  console.log('[ConnectionSettings] handleApiKeySave - setApiKey called');
  console.log('[ConnectionSettings] handleApiKeySave - verify localStorage:', getApiKey() ? 'yes (masked)' : 'no');
  message.success(t("settings.saved"));
  console.log('[ConnectionSettings] handleApiKeySave - success message shown');
}

async function testConnection() {
  console.log('[ConnectionSettings] testConnection - called');

  testConnectionLoading.value = true;
  testConnectionResult.value = null;
  testConnectionMessage.value = "";

  try {
    let testUrl: string;
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (appStore.deployMode === "remote") {
      // 远程模式：测试远程服务器
      if (!serverUrl.value.trim()) {
        console.log('[ConnectionSettings] testConnection - validation failed: empty URL');
        message.error(t("settings.connection.urlRequired"));
        return;
      }

      let url = serverUrl.value.trim();
      if (!url.startsWith("http://") && !url.startsWith("https://")) {
        url = "http://" + url;
      }
      url = url.replace(/\/+$/, "");

      if (import.meta.env.DEV) {
        // 开发环境：通过 Vite 代理避免 CORS 问题
        // 代理目标由 .env 中的 VITE_HERMES_GATEWAY_URL 控制
        // 远程 agent 的 /health 已被代理规则转发
        testUrl = '/health';
        console.log('[ConnectionSettings] testConnection - dev mode, testing remote via proxy to', testUrl);
      } else {
        // 生产环境：直接请求远程 URL
        testUrl = `${url}/health`;
        console.log('[ConnectionSettings] testConnection - testing remote URL:', testUrl);
      }

      if (apiKey.value.trim()) {
        headers['Authorization'] = `Bearer ${apiKey.value.trim()}`;
        console.log('[ConnectionSettings] testConnection - using API key');
      }

      const response = await fetch(testUrl, {
        method: 'GET',
        headers: headers,
        signal: AbortSignal.timeout(10000),
      });

      if (!response.ok) {
        const text = await response.text().catch(() => '');
        console.error('[ConnectionSettings] testConnection - health failed:', response.status, text);
        testConnectionResult.value = 'error';
        testConnectionMessage.value = `${t("settings.connection.testFailed")}: ${response.status} - ${text || response.statusText}`;
        message.error(testConnectionMessage.value);
        return;
      }

      const data = await response.json();
      console.log('[ConnectionSettings] testConnection - health success:', data);

      // Step 2: Verify /v1/responses endpoint
      testConnectionMessage.value = 'health 正常，验证 responses 端点…';
      let responsesUrl: string;
      if (import.meta.env.DEV) {
        // In dev mode, VITE_HERMES_GATEWAY_URL is set, we need to call the real upstream
        responsesUrl = `/api/proxy/v1/responses?test=1`;
      } else {
        responsesUrl = `${url}/v1/responses`;
      }

      try {
        const respCheck = await fetch(responsesUrl, {
          method: 'POST',
          headers: { ...headers, 'Content-Type': 'application/json' },
          body: JSON.stringify({ input: 'test', stream: false, max_output_tokens: 1 }),
          signal: AbortSignal.timeout(8000),
        });
        if (respCheck.ok) {
          testConnectionResult.value = 'success';
          testConnectionMessage.value = t("settings.connection.testSuccess");
          message.success(t("settings.connection.testSuccess"));
        } else if (respCheck.status === 401 || respCheck.status === 403) {
          testConnectionResult.value = 'error';
          testConnectionMessage.value = '远程 Agent 拒绝访问（401/403）。请检查 API Key 是否正确。';
          message.error(testConnectionMessage.value);
        } else {
          testConnectionResult.value = 'error';
          testConnectionMessage.value = `远程 responses 端点返回 ${respCheck.status}。请确认远程 Agent 已启用 /v1/responses。`;
          message.error(testConnectionMessage.value);
        }
      } catch {
        testConnectionResult.value = 'error';
        testConnectionMessage.value = `远程 Agent 的 /v1/responses 不可达。请确认地址 ${url} 正确且 Agent 已启动。`;
        message.error(testConnectionMessage.value);
      }
    } else {
      // 本地模式：测试 Koa + gateway
      testUrl = `${koaBaseUrl()}/health`;
      console.log('[ConnectionSettings] testConnection - testing local at', testUrl);

      const response = await fetch(testUrl, {
        method: 'GET',
        headers: headers,
        signal: AbortSignal.timeout(10000),
      });

      if (!response.ok) {
        const text = await response.text().catch(() => '');
        console.error('[ConnectionSettings] testConnection - failed:', response.status, text);
        testConnectionResult.value = 'error';
        testConnectionMessage.value = `${t("settings.connection.testFailed")}: ${response.status} - ${text || response.statusText}`;
        message.error(testConnectionMessage.value);
        return;
      }

      const data = await response.json();
      console.log('[ConnectionSettings] testConnection - health success:', data);

      // Step 2: Check gateway status from health response
      if (data.gateway === 'running') {
        testConnectionResult.value = 'success';
        testConnectionMessage.value = t("settings.connection.testSuccess") + '（Gateway 运行中）';
        message.success(testConnectionMessage.value);
      } else {
        testConnectionResult.value = 'error';
        testConnectionMessage.value = `Koa 服务正常，但 Hermes Gateway 未运行。请启动 gateway（hermes gateway start）。Gateway 详情: ${data.gateway_detail || '无'}`;
        message.error(testConnectionMessage.value);
      }
    }
  } catch (error: any) {
    console.error('[ConnectionSettings] testConnection - error:', error);
    testConnectionResult.value = 'error';
    testConnectionMessage.value = `${t("settings.connection.testError")}: ${error.message || 'Unknown error'}`;
    message.error(testConnectionMessage.value);
  } finally {
    testConnectionLoading.value = false;
    console.log('[ConnectionSettings] testConnection - completed');
  }
}
</script>

<template>
  <section class="settings-section">
    <div class="mode-selector">
      <NSelect
        :value="appStore.deployMode"
        :options="[
          { label: t('settings.connection.localMode'), value: 'local' },
          { label: t('settings.connection.remoteMode'), value: 'remote' },
        ]"
        size="small"
        :consistent-menu-width="false"
        class="input-sm"
        @update:value="handleModeChange"
      />
    </div>

    <template v-if="appStore.deployMode === 'remote'">
      <div class="setting-row">
        <div class="setting-info">
          <label class="setting-label">{{ t("settings.connection.serverUrl") }}</label>
          <p class="setting-hint">{{ t("settings.connection.serverUrlHint") }}</p>
        </div>
        <div class="setting-control">
          <NInput
            v-model:value="serverUrl"
            :placeholder="t('settings.connection.serverUrlPlaceholder')"
            size="small"
            class="input-sm"
          />
        </div>
      </div>
      <div class="setting-actions">
        <NButton type="primary" size="small" @click="handleUrlSave">
          {{ t("common.save") }}
        </NButton>
      </div>
    </template>

    <!-- API Key / Auth Token — 本地和远程模式都需要 -->
    <div class="setting-row">
      <div class="setting-info">
        <label class="setting-label">{{ t("settings.connection.apiKey") }}</label>
        <p class="setting-hint">{{ t("settings.connection.apiKeyHint") }}</p>
      </div>
      <div class="setting-control">
        <NInput
          v-model:value="apiKey"
          :type="showApiKey ? 'text' : 'password'"
          :placeholder="t('settings.connection.apiKeyPlaceholder')"
          size="small"
          class="input-sm"
        />
      </div>
    </div>
    <div class="setting-actions">
      <NButton size="small" @click="showApiKey = !showApiKey">
        {{ showApiKey ? t("settings.connection.hide") : t("settings.connection.show") }}
      </NButton>
      <NButton type="primary" size="small" @click="handleApiKeySave">
        {{ t("common.save") }}
      </NButton>
    </div>

    <template v-if="appStore.deployMode === 'local'">
      <div class="setting-row">
        <div class="setting-info">
          <label class="setting-label">本地认证 Token</label>
          <p class="setting-hint">Koa 后端 AUTH_TOKEN，与 .env 中的值一致</p>
        </div>
        <div class="setting-control">
          <NInput
            v-model:value="localAuthToken"
            :type="showLocalAuthToken ? 'text' : 'password'"
            placeholder="输入 AUTH_TOKEN"
            size="small"
            class="input-sm"
          />
        </div>
      </div>
      <div class="setting-actions">
        <NButton size="small" @click="showLocalAuthToken = !showLocalAuthToken">
          {{ showLocalAuthToken ? '隐藏' : '显示' }}
        </NButton>
        <NButton type="primary" size="small" @click="saveLocalAuthToken">
          保存
        </NButton>
      </div>

      <div v-if="localHealthLoading" class="local-hint">正在检查 Koa 连接…</div>
      <div v-else-if="localHealthOk" class="local-hint" style="background: rgba(16,185,129,0.1); color: #10b981;">
        Koa 服务正常
        <span v-if="appStore.gatewayConnected" style="margin-left:8px;">· Gateway 运行中</span>
        <span v-else style="margin-left:8px; color:#ef4444;">· Gateway 未运行</span>
      </div>
      <div v-else class="local-hint" style="background: rgba(239,68,68,0.1); color: #ef4444;">
        Koa 服务不可达（127.0.0.1:8648），请确认后端已启动
      </div>
    </template>

    <!-- 测试连接按钮 - 在本地和远程模式下都显示 -->
    <div class="test-section">
      <div class="test-actions">
        <NButton 
          type="success" 
          size="small" 
          :loading="testConnectionLoading"
          @click="testConnection"
          :disabled="appStore.deployMode === 'remote' && !serverUrl.trim()"
        >
          {{ t("settings.connection.testConnection") }}
        </NButton>
      </div>
      <div v-if="testConnectionMessage" class="test-result">
        <NAlert 
          :type="testConnectionResult === 'success' ? 'success' : 'error'" 
          :closable="true"
          class="test-alert"
        >
          {{ testConnectionMessage }}
        </NAlert>
      </div>
    </div>
  </section>
</template>

<style scoped lang="scss">
@use "@/styles/variables" as *;

.settings-section {
  margin-top: 16px;
}

.mode-selector {
  margin-bottom: 16px;
}

.setting-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid $border-light;

  &:last-child {
    border-bottom: none;
  }
}

.setting-info {
  flex: 1;
  margin-right: 16px;
}

.setting-label {
  font-size: 13px;
  color: $text-primary;
  display: block;
}

.setting-hint {
  font-size: 12px;
  color: $text-muted;
  margin-top: 2px;
}

.setting-control {
  flex-shrink: 0;
  width: 280px;
}

.setting-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  padding: 8px 0;
}

.local-hint {
  padding: 12px;
  background: rgba(0, 128, 0, 0.1);
  border-radius: 4px;
  font-size: 13px;
  color: $text-muted;
  margin-top: 8px;
}

.cli-warning {
  margin-bottom: 12px;
}

.test-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid $border-light;
}

.test-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  margin-bottom: 12px;
}

.test-result {
  margin-top: 8px;
}

.test-alert {
  margin-bottom: 0;
}

@media (max-width: $breakpoint-mobile) {
  .setting-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .setting-info {
    margin-right: 0;
  }

  .setting-control {
    width: 100%;
  }
}
</style>
