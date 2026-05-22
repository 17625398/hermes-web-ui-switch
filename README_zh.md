<p align="center">
  <strong>Hermes Web UI</strong>
  <a href="./README.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/NousResearch/hermes-agent">Hermes Agent</a> 的全功能 Web 管理面板。<br/>
  管理 AI 聊天会话、监控用量与成本、配置平台渠道、<br/>
  管理定时任务、浏览技能 —— 全部在一个简洁响应式的 Web 界面中完成。
</p>

<p align="center">
  <code>npm install -g hermes-web-ui && hermes-web-ui start</code>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/hermes-web-ui"><img src="https://img.shields.io/npm/v/hermes-web-ui?style=flat-square&color=blue" alt="npm 版本"/></a>
  <a href="https://github.com/EKKOLearnAI/hermes-web-ui/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/hermes-web-ui?style=flat-square" alt="许可证"/></a>
  <a href="https://github.com/EKKOLearnAI/hermes-web-ui/stargazers"><img src="https://img.shields.io/github/stars/EKKOLearnAI/hermes-web-ui?style=flat-square" alt="Star"/></a>
</p>

---

## 目录

- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [部署模式](#部署模式)
- [架构说明](#架构说明)
- [项目结构](#项目结构)
- [环境变量](#环境变量)
- [CLI 命令](#cli-命令)
- [开发指南](#开发指南)
- [技术栈](#技术栈)

---

## 功能特性

### AI 聊天

网页终端视角的 Agent 聊天界面，同时提供会议模式的群聊功能。

**个人聊天**

- 实时流式输出：通过 Socket.IO `/chat-run` 推送，无需轮询
- 多会话管理：创建、重命名、删除、切换会话
- 会话分组：按来源（Telegram、Discord、Slack、CLI 等）归类，可折叠手风琴面板
- 活跃会话指示器：正在运行的任务置顶并显示旋转图标
- 按最新消息时间排序
- Markdown 渲染：语法高亮 + 代码复制
- 工具调用展示：展开工具参数和返回结果
- 文件上传与下载：支持 local / Docker / SSH / Singularity 多后端
- 会话搜索：Ctrl+K 快速搜索本地会话库
- 全局模型选择器：从 `~/.hermes/auth.json` 发现可用模型
- Token 用量上下文显示

**群聊**

- 多 Agent 聊天房间，Socket.IO 实时通信
- @提及路由：@某个 Agent 触发上下文回复
- 上下文压缩：历史超阈值时自动摘要
- 输入状态和进度指示器
- 房间创建/删除与邀请码管理
- Agent 管理：添加/移除房间 Agent，支持独立 Profile
- SQLite 消息持久化

### 平台渠道

统一配置 **8 个平台**，适配多通道场景：

| 平台 | 功能 |
|---|---|
| Telegram | Bot Token、提及控制、表情回应、自由回复 |
| Discord | Bot Token、提及、自动线程、表情回应、频道白名单/黑名单 |
| Slack | Bot Token、提及控制、Bot 消息处理 |
| WhatsApp | 启用/禁用、提及控制、提及模式 |
| Matrix | Access Token、Homeserver、自动线程、私信提及线程 |
| 飞书 | App ID / Secret、提及控制 |
| 微信 | 扫码登录（浏览器扫码，自动保存凭证） |
| 企业微信 | Bot ID / Secret |

- 凭证管理写入 `~/.hermes/.env`
- 渠道行为设置写入 `~/.hermes/config.yaml`
- 自动检测各平台配置状态（已配置/未配置）

### 用量分析

- Token 总用量（输入 / 输出）
- 会话数及日均统计
- 预估费用追踪 + 缓存命中率
- 模型使用分布图
- 30 天每日趋势柱状图及数据表

### 定时任务

- 创建、编辑、暂停、恢复、删除 Cron 任务
- 立即触发执行
- Cron 表达式快捷预设

### 模型管理

- 从 `~/.hermes/auth.json` 自动发现模型
- 从 Provider 端点获取可用模型列表（`/v1/models`）
- 添加/更新/删除 Provider（预设 & 自定义 OpenAI 兼容）
- OpenAI Codex & Nous Portal OAuth 登录
- Provider URL 自动检测（非 v1 版本如 `/v4` 也可适配）
- Provider 级别模型分组，支持切换默认模型

### 多 Profile

- 创建、重命名、删除、切换 Profile
- 克隆或从 `.tar.gz` 归档导入
- 导出为归档用于备份或分享
- Profile 级别的配置和缓存隔离

### 文件浏览器

- 浏览远程后端文件（local / Docker / SSH / Singularity）
- 上传、下载、重命名、复制、移动、删除
- 创建目录
- 语法高亮查看文件内容

### 技能与记忆

- 浏览和搜索已安装的技能
- 查看技能详情和附件
- 用户笔记和档案管理

### 日志

- 查看 Agent / Server / Error 日志
- 按日志级别、日志文件和关键词过滤
- 结构化日志解析，HTTP 访问日志高亮

### 认证

- Token 认证（首次运行自动生成或 `AUTH_TOKEN` 环境变量指定）
- 可选用户名/密码登录（通过 Token 认证后设置）
- `AUTH_DISABLED=1` 可关闭认证

### 设置

- 显示：流式输出、紧凑模式、推理过程、费用显示
- Agent：最大轮次、超时、工具强制执行
- 记忆：启用/禁用、字符限制
- 会话：空闲超时、定时重置
- 隐私：PII 脱敏
- 模型：默认模型 & Provider
- **部署模式切换**：在 UI 中动态切换本地/分离部署模式

### Web 终端

- 集成终端，基于 node-pty 和 @xterm/xterm
- 多会话支持：创建、切换、关闭
- 键盘输入和 PTY 输出通过 WebSocket 实时传输
- 窗口大小调整支持

---

## 快速开始

### npm 全局安装（推荐）

```bash
npm install -g hermes-web-ui
hermes-web-ui start
```

打开 **http://localhost:8648**

### 一键安装（Debian/Ubuntu/macOS）

自动安装 Node.js（如未安装）和 hermes-web-ui：

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/EKKOLearnAI/hermes-web-ui@main/scripts/setup.sh)
```

### WSL

```bash
bash <(curl -fsSL https://cdn.jsdelivr.net/gh/EKKOLearnAI/hermes-web-ui@main/scripts/setup.sh)
hermes-web-ui start
```

### Docker Compose

单容器部署，内置 Hermes Agent 运行时：

```bash
# 用预构建镜像（推荐）
WEBUI_IMAGE=ekkoye8888/hermes-web-ui docker compose up -d

# 或从源码构建
docker compose up -d --build

docker compose logs -f hermes-webui
```

打开 **http://localhost:6060**

- 持久化数据目录：`./hermes_data`
- Web UI Token 存储位置：`./hermes_data/hermes-web-ui/.token`
- 所有运行参数由 `docker-compose.yml` 环境变量驱动

详细说明见 [`docs/docker.md`](./docs/docker.md)。

### 从源码运行（开发模式）

```bash
git clone https://github.com/EKKOLearnAI/hermes-web-ui.git
cd hermes-web-ui
npm install
npm run dev
```

- 前端（Vite 开发服务器）：**http://localhost:5173**
- BFF 后端（Koa）：**http://localhost:8648**

---

## 部署模式

Hermes Web UI 支持两种部署模式：**本地模式（Local）** 和 **分离部署（Remote）**。

两种模式在**路由路径**、**进程模型**、**功能边界**上有根本差异。理解这些差异对配置和排错至关重要。

### 模式对比

| 对比维度 | 本地模式（Local） | 分离部署（Remote） |
|---|---|---|
| **Agent 位置** | 与 Koa 同机，由 GatewayManager 进程管理 | 远程机器，通过 HTTP API 访问 |
| **GatewayManager** | 启动并管理本地 Agent 进程（:18765） | **不启动**，只在需要时发送 API 请求 |
| **HTTP API 路径** | 浏览器 → Vite 代理 → Koa 路由 → GatewayManager → Agent | 浏览器 → Vite 代理 → **远程 Agent(:8642)** |
| **聊天路径** | 浏览器 → Koa Socket.IO → AgentBridgeClient → GatewayManager → Agent | 浏览器 → Koa Socket.IO → **Koa fetch 直接调用远程 API** |
| **依赖** | 本地需安装 Hermes Agent、Python 运行环境 | 只需远程 Agent 可达，本地无需 Agent |
| **适用场景** | 单机开发、个人使用 | 多机部署、团队共享远程 Agent |
| **中断恢复** | ChatRunSocket + Koa 都中断则会话丢失 | 会话持久化到 SQLite，重启后可恢复 |
| **Web 终端** | ✅ 支持（本地 node-pty 直连） | ❌ 不支持（依赖本地 shell） |

### 路由决策树

```
用户发送聊天消息
  → chat.ts store.sendMessage()
  → 读取 appStore.deployMode
      ↓
  ├── deployMode === "local"  →  source = "cli"
  │     → Socket.IO emit('run', { source: "cli", ... })
  │     → Koa ChatRunSocket.handleRun()
  │     → resolveRunSource("cli") → return "cli"
  │     → handleBridgeRun()
  │     → AgentBridgeClient → GatewayManager (:18765) → 本地 Agent
  │     → 流式结果 → Socket.IO → 浏览器
  │
  └── deployMode === "remote"  →  source = "api_server"
        → Socket.IO emit('run', { source: "api_server", ... })
        → Koa ChatRunSocket.handleRun()
        → resolveRunSource("api_server") → return "api_server"
        → handleApiRun()
        → POST fetch("http://<远程IP>:8642/v1/responses")
        → 远程 Agent 处理
        → SSE 流 → 逐帧解析 → Socket.IO → 浏览器
```

### 功能边界

| 功能 | 本地模式 | 分离部署 |
|---|---|---|
| 聊天对话 | ✅ | ✅ |
| 会话管理 | ✅ | ✅ |
| 模型选择 | ✅ | ✅ |
| 文件上传/下载 | ✅ | ✅（受远程 Agent 限制） |
| 平台渠道配置 | ✅ | ✅ |
| 定时任务 | ✅ | ✅ |
| Web 终端 | ✅ | ❌ |
| 日志查看 | ✅ | ❌（本地日志不可达） |
| 文件浏览器（远程后端） | ✅ | ✅ |
| CLI Session 命令 | ✅ | ❌ |

### 本地模式详解

本地模式下 Koa 启动完整的 Agent 管理栈：

```
┌─ Koa 进程 ──────────────────────────────────┐
│                                               │
│  ChatRunSocket                                │
│    ↓ source === "cli"                         │
│  handleBridgeRun()                            │
│    ↓                                          │
│  AgentBridgeClient (Socket.IO 客户端)          │
│    ↓ ws://127.0.0.1:18765                     │
│  GatewayManager (Koa 子进程)                   │
│    ↓                                          │
│  Hermes Agent (Python 进程)                    │
│    ↓                                          │
│  run_agent.py → LLM → 工具调用 → 流式输出       │
│                                               │
└───────────────────────────────────────────────┘
```

- GatewayManager 监听 `127.0.0.1:18765`，是一个独立的 Koa 服务
- AgentBridgeClient 是 Web UI 的 Socket.IO 客户端，连接到 GatewayManager
- 所有 Agent 管理（启动/停止/重启）由 GatewayManager 控制
- Web 终端使用 node-pty 直接创建本地 shell 进程

### 分离部署模式详解

分离部署模式下 Koa **不启动** GatewayManager，聊天通过 HTTP fetch 直接调用远程 Agent API：

```
┌─ Koa 进程（无 GatewayManager）─────────────────┐
│                                                 │
│  ChatRunSocket                                  │
│    ↓ source === "api_server"                    │
│  handleApiRun()                                 │
│    ↓                                            │
│  POST fetch("http://<remote>:8642/v1/responses") │
│    ↓ Authorization: Bearer <API_KEY>            │
│  ┌─────────────────────────────────────────┐   │
│  │ 远程 Hermes Agent (:8642)                │   │
│  │  → /v1/responses 处理                   │   │
│  │  → SSE 流式返回                         │   │
│  └─────────────────────────────────────────┘   │
│    ↓                                            │
│  readSseFrames(res.body)                        │
│  → applyResponseStreamEvent()                  │
│  → Socket.IO emit('run.chunk', ...) → 浏览器   │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### 分离部署下的 HTTP API 路径

前端发起的 REST API 请求（非聊天）走另一条路径：

```
浏览器 → Vite 开发代理 (:5173) → remote Agent (:8642)
           ↑                            ↑
      /api/hermes/v1/models       VITE_HERMES_GATEWAY_URL
      /api/hermes/sessions        proxy target
      /health
```

Vite 代理将匹配 `/api`、`/v1`、`/health` 的请求转发到 `.env` 中配置的 `VITE_HERMES_GATEWAY_URL`。在分离部署模式下，这个目标就是远程 Agent，而不是本地 Koa。

#### REST API 与 Chat API 路径分离

```
请求类型         本地模式            分离部署模式
──────────────────────────────────────────────────────
HTTP REST API   Koa → local Agent   Vite proxy → remote Agent (:8642)
Socket.IO Chat  Koa → local Agent   Koa fetch → remote Agent (:8642)
```

### 配置步骤

#### 分离部署 - 生产环境

```bash
export HERMES_GATEWAY_URL=http://192.168.0.39:8642
export HERMES_GATEWAY_API_KEY=your-secret-key
hermes-web-ui start
```

#### 分离部署 - 开发环境

在 `.env` 中设置：

```env
VITE_HERMES_GATEWAY_URL=http://192.168.0.39:8642
VITE_HERMES_GATEWAY_API_KEY=your-secret-key
```

重启 dev server 后生效。

### 通过 UI 切换部署模式（v0.5.32+）

Web UI **设置 → 连接** 页面提供了部署模式切换开关，可在运行时动态切换，**无需重启服务**：

1. 打开 Web UI，进入 **设置** 页面
2. 点击 **连接** 标签页
3. 选择部署模式：
   - **本地模式**：使用本地 Koa + AgentBridge
   - **分离部署**：连接远程 Agent
4. 输入远程服务器 URL 和 API Key（切换远程模式时需要）
5. 点击 **保存** 生效

**切换原理**：

```
ConnectionSettings.vue
  → handleModeChange("local" | "remote")
  → setServerUrl() / localStorage.removeItem('hermes_server_url')
  → appStore.syncDeployMode()
      → deployMode = getBaseUrlValue() ? "remote" : "local"
      → 更新全局状态

chat.ts store.sendMessage()
  → const source = appStore.deployMode === 'remote' ? 'api_server' : 'cli'
  → 后续路由参见 [路由决策树](#路由决策树)
```

**注意**：切换部署模式不需要重启 Koa 服务，但分离部署模式下需确保远程 Agent 可通过网络访问，且 `.env` 或 `localStorage` 中正确配置了远程 URL 和 API Key。

#### 连接健康指示器（v0.5.32+）

**聊天标题栏**的部署模式徽章新增彩色圆点，实时反映连接健康状态：

| 圆点颜色 | 本地模式含义 | 分离部署模式含义 |
|---|---|---|
| 🟢 绿色 | Koa + Gateway 均正常运行 | 远程 Agent 可达 |
| 🟡 黄色（闪烁） | Koa 正常，Gateway 未运行 | （不适用） |
| 🔴 红色 | Koa 不可达 | 远程 Agent 不可达 |

**告警横幅**在聊天区顶部自动显示：
- 本地模式：Gateway 未运行时提示 `hermes gateway start`
- 分离部署：远程 Agent 不可达时引导用户检查连接设置

`/health` 端点（`GET /health`）现在返回真实的 `gateway` 和 `bridge` 状态：
```json
{
  "status": "ok",
  "gateway": "running",
  "gateway_pid": 27688,
  "gateway_detail": "✓ Gateway is running (PID: 27688)",
  "bridge": "running"
}
```

#### 连接测试增强（v0.5.32+）

**设置 → 连接** 页面的"测试连接"按钮现在执行更深入的验证：

| 模式 | 第一步 | 第二步 |
|---|---|---|
| **本地模式** | `GET /health`（检测 Koa 是否可达） | 检查 `gateway` 字段 — 若 Gateway 未运行则告警 |
| **分离部署** | `GET /health`（检测远端是否可达） | `POST /v1/responses` 发送极小测试请求 — 验证 API 端点是否正常响应 |

---

## 架构说明

### 核心技术架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                        浏览器 (Vue 3 + Vite)                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │  API 客户端   │  │ Socket.IO    │  │  Web 终端 (@xterm)       │  │
│  │  (client.ts)  │  │ (chat.ts)    │  │  (TerminalPanel)         │  │
│  └──────┬───────┘  └──────┬───────┘  └─────────┬────────────────┘  │
└─────────┼─────────────────┼────────────────────┼────────────────────┘
          │ HTTP API        │ Socket.IO (ws)     │ WebSocket (ws)
          │ (:5173)         │ (:8648)            │ (:8648)
          ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      BFF 层 (Koa :8648)                             │
│                                                                     │
│  ┌────────────────┐  ┌────────────────────┐  ┌──────────────────┐  │
│  │  Koa Routes     │  │  ChatRunSocket     │  │  PTY WebSocket   │  │
│  │  (REST API)     │  │  (Socket.IO 命名空间) │  │  (node-pty)      │  │
│  └───────┬────────┘  └─────────┬──────────┘  └────────┬─────────┘  │
│          │                     │                       │            │
│  ┌───────▼─────────────────────▼───────────────────────▼──────────┐ │
│  │                     Koa 代理中间件                              │ │
│  │  本地: GatewayManager → local Agent                            │ │
│  │  远程: HTTP fetch → remote Agent (:8642)                       │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  DB (SQLite) │  File Store │  Auth │  Credentials │  Logger   │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 两层代理（开发模式）

开发模式下存在 **两层代理**，其行为因部署模式而异：

| 代理层 | 端口 | 代理路径 | 本地模式目标 | 分离部署目标 | 适用请求 |
|---|---|---|---|---|---|
| **Vite 代理** | `:5173` | `/api/*`, `/v1/*`, `/health` | Koa `:8648` | 远程 Agent `:8642` | HTTP REST API（模型/会话/日志/任务等） |
| **Koa 代理** | `:8648` | `/api/hermes/*`, `/v1/*` | GatewayManager `:18765` | 远程 Agent `:8642` | Koa 内部转发（Socket.IO->fetch, 后端代理） |

> Socket.IO 聊天连接**不经过** Vite 代理，浏览器直连 Koa `:8648`。Koa 的 ChatRunSocket 再根据 `deployMode` 选择本地/远程路由。

**路径转换**（Koa 代理）：

```
客户端请求路径: /api/hermes/v1/responses
Koa 代理转发路径: /v1/responses          (去掉 /api/hermes 前缀)
```

---

## 项目结构

```
hermes-web-ui/
├── .env                          # 开发环境变量（含远程 Agent URL）
├── .env.example                  # 环境变量模板
├── package.json                  # 根 package（monorepo 脚本 + 服务端依赖）
├── vite.config.ts                # Vite 构建配置 + 开发代理规则
├── tsconfig.json                 # TypeScript 项目引用配置
│
├── bin/
│   └── hermes-web-ui.mjs         # CLI 入口（npm -g 安装后调用的二进制）
│
├── packages/
│   ├── client/                   # 前端（Vue 3 + Vite + Naive UI）
│   │   └── src/
│   │       ├── api/              # API 请求层
│   │       │   ├── client.ts     #   通用 fetch 封装（getBaseUrl, request）
│   │       │   ├── auth.ts       #   认证 API
│   │       │   └── hermes/       #   Hermes 相关 API
│   │       │       ├── chat.ts   #     Socket.IO 聊天连接管理
│   │       │       └── ...       #     会话、系统、Profile、文件等
│   │       ├── components/
│   │       │   └── hermes/
│   │       │       ├── chat/     #     聊天面板、Kanban 布局、终端
│   │       │       ├── settings/ #     设置页面（含 ConnectionSettings）
│   │       │       └── ...       #     渠道、任务、日志、模型等
│   │       ├── stores/hermes/    # Pinia 状态管理
│   │       │   ├── app.ts        #   全局状态（deployMode, models, health）
│   │       │   ├── chat.ts       #   聊天 store（sendMessage, sessions）
│   │       │   └── ...           #   会话、Profile、技能等
│   │       ├── views/hermes/     # 页面级组件
│   │       ├── router/           # 路由
│   │       ├── i18n/             # 国际化
│   │       └── styles/           # SCSS 样式
│   │
│   └── server/                   # 后端（Koa + Socket.IO + node-pty）
│       └── src/
│           ├── index.ts          # Koa 应用入口、中间件链
│           ├── config.ts         # 配置加载（环境变量、路径）
│           ├── routes/
│           │   ├── health.ts     # /health 端点
│           │   ├── auth.ts       # 认证路由
│           │   ├── upload.ts     # 文件上传
│           │   └── hermes/       # Hermes API 代理路由
│           │       └── index.ts  #   Koa 代理中间件（本地/远程路由）
│           ├── services/
│           │   ├── auth.ts       # 认证逻辑
│           │   ├── logger.ts     # 日志
│           │   └── hermes/       # Hermes 服务
│           │       ├── run-chat/ #   Socket.IO 聊天运行引擎
│           │       │   ├── index.ts           #   ChatRunSocket 类
│           │       │   ├── handle-api-run.ts  #   远程代理运行（分离部署）
│           │       │   ├── handle-bridge-run.ts #  本地 Bridge 运行
│           │       │   ├── compression.ts     #   上下文压缩
│           │       │   ├── sse-utils.ts       #   SSE 帧解析
│           │       │   └── ...                #   消息格式、用量计算等
│           │       ├── agent-bridge/          # Agent Bridge 客户端
│           │       ├── gateway-manager.ts     # Gateway 进程管理
│           │       ├── group-chat/            # 群聊服务
│           │       └── ...                    # Profile、文件、TTS 等
│           ├── controllers/       # Koa 控制器
│           └── db/                # SQLite 数据库层
│               └── hermes/        #   会话存储、用量存储
│
├── dist/                         # 构建产物（client + server）
├── docs/
│   ├── docker.md                 # Docker 部署文档
│   └── cli-chat-sessions.md      # CLI 会话说明
│
├── scripts/
│   ├── build-server.mjs          # 服务端构建脚本
│   └── setup.sh                  # 一键安装脚本
│
├── Dockerfile                    # Docker 镜像构建
├── docker-compose.yml            # Docker Compose 编排
├── nodemon.json                  # 开发时服务端热重载
│
├── DEVELOPMENT.md                # 开发规范
└── LICENSE                       # BSL-1.1 许可证
```

---

## 环境变量

### Web UI 运行时环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `PORT` | `8648` | Web UI 监听端口 |
| `BIND_HOST` | `0.0.0.0` | 绑定地址（IPv6 设为 `::`） |
| `AUTH_TOKEN` | 自动生成 | Bearer Token |
| `AUTH_DISABLED` | 未设置 | `1` 或 `true` 关闭认证 |
| `PROFILE` | `default` | 初始 Hermes Profile 名称 |
| `LOG_LEVEL` | `info` | 日志级别 |
| `BRIDGE_LOG_LEVEL` | `$LOG_LEVEL` | Bridge 日志级别 |
| `UPLOAD_DIR` | `$HERMES_WEB_UI_HOME/upload` | 上传目录 |
| `CORS_ORIGINS` | `*` | CORS 设置 |
| `MAX_DOWNLOAD_SIZE` | `200MB` | 最大下载文件大小 |
| `MAX_EDIT_SIZE` | `10MB` | 最大可编辑文件大小 |
| `WORKSPACE_BASE` | `/opt/data/workspace` | Workspace 浏览根目录 |

**数据目录**（以下二选一）：

| 变量 | 默认值 | 说明 |
|---|---|---|
| `HERMES_WEB_UI_HOME` | `~/.hermes-web-ui` | Web UI 数据目录（优先） |
| `HERMES_WEBUI_STATE_DIR` | `~/.hermes-web-ui` | 兼容别名 |

### 开发模式环境变量（`.env` 文件）

| 变量 | 默认值 | 说明 |
|---|---|---|
| `VITE_HERMES_GATEWAY_URL` | `http://127.0.0.1:8648` | Vite 代理 + Koa 代理的上游目标。分离部署时设为远程 Agent 地址 |
| `VITE_HERMES_GATEWAY_API_KEY` | 未设置 | 远程 Agent 的 API Key（与 `API_SERVER_KEY` 一致） |

### 分离部署环境变量（生产环境）

| 变量 | 说明 |
|---|---|
| `HERMES_GATEWAY_URL` | 远程 Hermes Agent 完整 URL（含端口） |
| `HERMES_GATEWAY_API_KEY` | 远程 Agent 的 API Key |

---

## CLI 命令

| 命令 | 说明 |
|---|---|
| `hermes-web-ui start` | 后台启动（守护进程模式） |
| `hermes-web-ui start --port 9000` | 自定义端口启动 |
| `hermes-web-ui stop` | 停止后台进程 |
| `hermes-web-ui restart` | 重启 |
| `hermes-web-ui status` | 查看运行状态 |
| `hermes-web-ui update` | 更新到最新版并重启 |
| `hermes-web-ui upgrade` | `update` 别名 |
| `hermes-web-ui -v` | 显示版本 |
| `hermes-web-ui -h` | 帮助 |

`update`/`upgrade` 先 `npm cache clean --force`，再 `npm install -g hermes-web-ui@latest` 并重启。

### 自动配置

启动时 BFF 服务器自动：
- 初始化数据目录、本地数据库和内置技能
- 启动 ChatRunSocket 使用的 Hermes agent bridge
- 启动成功后打开浏览器

---

## 开发指南

### 常用命令

```bash
npm run dev            # 同时启动前端 + 后端（concurrently）
npm run dev:client     # 仅启动前端（Vite :5173）
npm run dev:server     # 仅启动后端（Koa :8648, nodemon 热重载）
npm run build          # 类型检查 + 构建（client + server）
npm run test           # Vitest 单元测试
npm run test:coverage  # 带覆盖率的单元测试
npm run test:e2e       # Playwright 端到端测试
```

### 项目规范

详见 [DEVELOPMENT.md](./DEVELOPMENT.md)：

- 前端使用 Vue 3 Composition API `<script setup lang="ts">`
- 状态管理使用 Pinia setup stores
- API 请求使用 `packages/client/src/api/client.ts` 封装的 `request()`
- 字符串国际化添加到所有 locale 文件
- 组件样式使用 scoped SCSS
- 后端路由保持简洁，业务逻辑放在 controllers/services 中
- 认证统一在 `packages/server/src/services/auth.ts` 处理
- 聊天运行时在 `packages/server/src/services/hermes/run-chat/`

### 构建后验证

```bash
npm run build
# 验证 dist/ 目录已生成
ls dist/
# dist/server/  dist/client/
```

---

## 技术栈

| 层 | 技术 |
|---|---|
| **前端框架** | Vue 3 + TypeScript + Composition API |
| **构建工具** | Vite 8 + vue-tsc |
| **UI 组件库** | Naive UI |
| **状态管理** | Pinia |
| **路由** | Vue Router |
| **国际化** | vue-i18n |
| **样式** | SCSS |
| **Markdown** | markdown-it + highlight.js |
| **图表** | Mermaid |
| **编辑器** | Monaco Editor |
| **终端** | @xterm/xterm + node-pty |
| **后端框架** | Koa 2 |
| **实时通信** | Socket.IO (chat) + WebSocket (terminal) |
| **数据库** | SQLite（better-sqlite3 兼容） |
| **测试** | Vitest + Playwright |
| **容器化** | Docker / Docker Compose |

---

## 许可证

[BSL-1.1](./LICENSE)
