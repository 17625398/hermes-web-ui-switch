# hermes-web-ui-switch

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/17625398/hermes-web-ui-switch.git
cd hermes-web-ui-switch
```

### 2. 应用修改到 Hermes Web UI

将本项目的代码文件复制到 Hermes Web UI 的对应位置：

```powershell
# 复制连接设置组件
copy "packages/client/src/components/hermes/settings/ConnectionSettings.vue" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\components\hermes\settings\"

# 复制设置页面视图
copy "packages/client/src/views/hermes/SettingsView.vue" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\views\hermes\"

# 复制中文翻译文件
copy "packages/client/src/i18n/locales/zh.ts" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"

# 复制英文翻译文件
copy "packages/client/src/i18n/locales/en.ts" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"
```

### 3. 运行 Hermes Web UI

```bash
cd D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui
npm install
npm run dev
```

### 4. 访问设置页面

打开浏览器访问 Web UI，进入「设置」页面，即可看到新增的「连接」标签页。

### 5. 环境变量配置（可选）

可以通过 `.env` 文件配置默认的远程服务器地址：

```bash
# 在 Hermes Web UI 目录下创建 .env 文件
cd D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui
copy .env.example .env
```

编辑 `.env` 文件，设置远程服务器地址：

```env
# 分离部署配置
# 设置此项后，Web UI 将默认连接到远程 agent
HERMES_GATEWAY_URL=http://your-server-ip:8642

# 其他可选配置
# PORT=8648
# AUTH_TOKEN=your-token-here
```

**配置说明：**

| 环境变量 | 说明 | 默认值 |
|----------|------|--------|
| `HERMES_GATEWAY_URL` | 远程 hermes-agent gateway 地址 | 空（本地模式） |
| `PORT` | Web UI 服务端口 | 8648 |
| `AUTH_TOKEN` | 认证 Token（如果 agent 需要） | 空 |
| `HERMES_WEB_UI_HOME` | Web UI 数据目录 | 系统默认 |
| `HERMES_WEB_UI_STOP_GATEWAYS_ON_SHUTDOWN` | 关闭 Web UI 时是否停止 gateway | 1 |

> **注意**：环境变量配置是初始默认值，用户仍可通过设置页面的「连接」标签页在运行时动态切换部署模式。

## 项目简介

**hermes-web-ui-switch** 是 Hermes Web UI 的延伸功能项目，提供在运行时动态切换**本地/分离部署模式**的能力。

通过设置页面的「连接」标签页，用户可以灵活选择：
- **本地模式**：连接本地 Hermes CLI
- **分离部署模式**：连接远程 API 服务器

## 备份文件结构

```
backup/hermes-web-ui-switch/
├── README.md              # 项目说明文档
├── backup.ps1             # 备份脚本
└── packages/
    └── client/
        └── src/
            ├── components/
            │   └── hermes/
            │       └── settings/
            │           └── ConnectionSettings.vue
            ├── views/
            │   └── hermes/
            │       └── SettingsView.vue
            └── i18n/
                └── locales/
                    ├── zh.ts
                    └── en.ts
```

## 备份文件说明

| 文件 | 路径 | 说明 |
|------|------|------|
| ConnectionSettings.vue | `packages/client/src/components/hermes/settings/` | 连接设置组件，包含本地/分离部署模式切换功能 |
| SettingsView.vue | `packages/client/src/views/hermes/` | 设置页面主视图，包含连接标签页配置 |
| zh.ts | `packages/client/src/i18n/locales/` | 中文国际化翻译文件（含连接设置相关翻译） |
| en.ts | `packages/client/src/i18n/locales/` | 英文国际化翻译文件（含连接设置相关翻译） |

## 功能特性

- **部署模式切换**：在本地模式和分离部署模式之间动态切换
- **本地模式**：连接本地 Hermes CLI，适合开发和单机部署
- **分离部署模式**：连接远程 API 服务器，适合分布式部署场景
- **服务器配置**：配置远程服务器 URL 和 API Key
- **CLI 状态检测**：切换到本地模式时自动检测 Hermes CLI 是否可用

## 升级时恢复备份

当 Hermes Web UI 升级后，按以下步骤恢复 hermes-web-ui-switch 功能：

### 步骤 1：确认备份目录

确保备份目录存在：
```
D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\
```

### 步骤 2：复制备份文件

执行以下命令将备份文件复制到对应位置：

```powershell
# 复制连接设置组件
copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\components\hermes\settings\ConnectionSettings.vue" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\components\hermes\settings\"

# 复制设置页面视图
copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\views\hermes\SettingsView.vue" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\views\hermes\"

# 复制中文翻译文件
copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\i18n\locales\zh.ts" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"

# 复制英文翻译文件
copy "D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\packages\client\src\i18n\locales\en.ts" `
     "D:\Doubao\DeepTutor\data\user\integrations\hermes-web-ui\packages\client\src\i18n\locales\"
```

### 步骤 3：重启服务

重启 Web UI 服务使修改生效。

## 创建新备份

如需创建新的备份，运行备份脚本：

```powershell
cd D:\Doubao\DeepTutor\backup\hermes-web-ui-switch
.\backup.ps1
```

## 注意事项

1. 升级前建议先运行备份脚本创建最新备份
2. 恢复备份后需要重启 Web UI 服务
3. 备份文件仅包含自定义修改，不包含原始框架代码
4. 如果升级后文件结构发生变化，可能需要手动调整恢复步骤

## 项目标识

- **项目名称**: hermes-web-ui-switch
- **所属项目**: Hermes Web UI
- **功能定位**: 部署模式切换扩展功能
- **备份目录**: `D:\Doubao\DeepTutor\backup\hermes-web-ui-switch\`