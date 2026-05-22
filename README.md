<p align="center">
  <strong>Hermes Web UI</strong>
  <a href="./README_zh.md">中文</a>
</p>

<p align="center">
  A full-featured web dashboard for <a href="https://github.com/NousResearch/hermes-agent">Hermes Agent</a>.<br/>
  Manage AI chat sessions, monitor usage & costs, configure platform channels,<br/>
  schedule cron jobs, browse skills — all from a clean, responsive web interface.
</p>

<p align="center">
  <code>npm install -g hermes-web-ui && hermes-web-ui start</code>
</p>

<p align="center">
  <a href="https://www.npmjs.com/package/hermes-web-ui"><img src="https://img.shields.io/npm/v/hermes-web-ui?style=flat-square&color=blue" alt="npm version"/></a>
  <a href="https://github.com/EKKOLearnAI/hermes-web-ui/blob/main/LICENSE"><img src="https://img.shields.io/npm/l/hermes-web-ui?style=flat-square" alt="license"/></a>
  <a href="https://github.com/EKKOLearnAI/hermes-web-ui/stargazers"><img src="https://img.shields.io/github/stars/EKKOLearnAI/hermes-web-ui?style=flat-square" alt="stars"/></a>
</p>

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Deployment Modes](#deployment-modes)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [CLI Commands](#cli-commands)
- [Development](#development)
- [Tech Stack](#tech-stack)

---

## Features

### AI Chat

**Personal Chat**

- Real-time chat streaming over Socket.IO `/chat-run`; chat runs execute through the Hermes agent bridge
- Multi-session management — create, rename, delete, switch between sessions
- **Self-built session database** — local SQLite storage for Web UI sessions; Hermes state.db remains a read-only source for Hermes history APIs
- Session grouping by source (Telegram, Discord, Slack, CLI, etc.) with collapsible accordion
- Active session indicator — live sessions pin to top with spinner icon
- Sessions sorted by latest message time
- Markdown rendering with syntax highlighting and code copy
- Tool call detail expansion (arguments / result)
- File upload support
- File download support — download user-uploaded files and agent-generated files across local, Docker, SSH, and Singularity backends
- Session search — Ctrl+K search across the Web UI local session database; read-only Hermes history sessions are not included
- Global model selector — discovers models from `~/.hermes/auth.json` credential pool
- Per-session model display badge and context token usage

**Group Chat**

- Multi-agent chat rooms with real-time messaging via Socket.IO
- @mention routing — mention an agent to trigger a contextual reply
- Context compression — automatic conversation summarization when history exceeds token threshold
- Typing status and reply progress indicators
- Room creation, deletion, and invite code management
- Agent management — add/remove agents from rooms with per-agent profiles
- SQLite message persistence
- Mobile responsive with collapsible sidebar

### Platform Channels

Unified configuration for **8 platforms** in one page:

| Platform      | Features                                                               |
| ------------- | ---------------------------------------------------------------------- |
| Telegram      | Bot token, mention control, reactions, free-response chats             |
| Discord       | Bot token, mention, auto-thread, reactions, channel allow/ignore lists |
| Slack         | Bot token, mention control, bot message handling                       |
| WhatsApp      | Enable/disable, mention control, mention patterns                      |
| Matrix        | Access token, homeserver, auto-thread, DM mention threads              |
| Feishu (Lark) | App ID / Secret, mention control                                       |
| WeChat        | QR code login (scan in browser, auto-save credentials)                 |
| WeCom         | Bot ID / Secret                                                        |

- Credential management writes to `~/.hermes/.env`
- Channel behavior settings write to `~/.hermes/config.yaml`
- Per-platform configured/unconfigured status detection

### Usage Analytics

- Total token usage breakdown (input / output)
- Session count with daily average
- Estimated cost tracking & cache hit rate
- Model usage distribution chart
- 30-day daily trend (bar chart + data table)

### Scheduled Jobs

- Create, edit, pause, resume, delete cron jobs
- Trigger immediate execution
- Cron expression quick presets

### Model Management

- Auto-discover models from credential pool (`~/.hermes/auth.json`)
- Fetch available models from each provider endpoint (`/v1/models`)
- Add, update, and delete providers (preset & custom OpenAI-compatible)
- OpenAI Codex & Nous Portal OAuth login
- Provider URL auto-detection for non-v1 API versions (e.g. `/v4`)
- Provider-level model grouping with default model switching

### Multi-Profile

- Create, rename, delete, and switch between Hermes profiles
- Clone existing profile or import from archive (`.tar.gz`)
- Export profile for backup or sharing
- Profile-scoped configuration and cache isolation

### File Browser

- Browse files on remote backends (local, Docker, SSH, Singularity)
- Upload, download, rename, copy, move, and delete files
- Create directories
- View file content with syntax highlighting

### Skills & Memory

- Browse and search installed skills
- View skill details and attached files
- User notes and profile management

### Logs

- View agent / server / error logs
- Filter by log level, log file, and keyword
- Structured log parsing with HTTP access log highlighting

### Authentication

- Token-based auth (auto-generated on first run or set via `AUTH_TOKEN` env var)
- Optional username/password login — set via settings page after initial token auth
- Auth can be disabled with `AUTH_DISABLED=1`

### Settings

- Display (streaming, compact mode, reasoning, cost display)
- Agent (max turns, timeout, tool enforcement)
- Memory (enable/disable, char limits)
- Session reset (idle timeout, scheduled reset)
- Privacy (PII redaction)
- Model settings (default model & provider)
- **Deployment mode switching** — toggle local/separated deployment at runtime

### Web Terminal

- Integrated terminal powered by node-pty and @xterm/xterm
- Multi-session support — create, switch between, and close terminal sessions
- Real-time keyboard input and PTY output streaming via WebSocket
- Window resize support

---

## Quick Start

### npm (Recommended)

```bash
npm install -g hermes-web-ui
hermes-web-ui start
```

Open **http://localhost:8648**

### One-line Setup (Auto-detect OS)

Automatically installs Node.js (if missing) and hermes-web-ui on Debian/Ubuntu/macOS:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/EKKOLearnAI/hermes-web-ui/main/scripts/setup.sh)
```

### WSL

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/EKKOLearnAI/hermes-web-ui/main/scripts/setup.sh)
hermes-web-ui start
```

> WSL uses the same Web UI daemon startup flow as other local installs; no separate gateway service is started by Web UI.

### Docker Compose

Single-container deployment with integrated Hermes Agent:

```bash
# Use pre-built image (Recommended)
WEBUI_IMAGE=ekkoye8888/hermes-web-ui docker compose up -d

# Or build from source
docker compose up -d --build

docker compose logs -f hermes-webui
```

Open **http://localhost:6060**

- Persistent Hermes data is stored in `./hermes_data`
- Web UI auth token is stored in `./hermes_data/hermes-web-ui/.token`
- On first run with auth enabled, the token is printed to container logs
- All runtime settings are environment-variable driven in `docker-compose.yml`

For detailed notes and troubleshooting, see [`docs/docker.md`](./docs/docker.md).

### From Source (Development)

```bash
git clone https://github.com/EKKOLearnAI/hermes-web-ui.git
cd hermes-web-ui
npm install
npm run dev
```

- Frontend (Vite dev server): http://localhost:5173
- BFF Server (Koa): http://localhost:8648

### Hermes Agent Runtime Discovery

When Web UI starts backend chat features, it prefers a source checkout that
contains `run_agent.py` such as `~/.hermes/hermes-agent`. If no source checkout
is found, it falls back to the Python environment used by the installed
`hermes` command, then the system Python. This supports both source installs
and package installs such as `pip install hermes-agent`.

---

## Deployment Modes

Hermes Web UI supports two deployment modes:

| Mode | Description |
|---|---|
| **Local** | Web UI starts a local Hermes Agent Bridge; all chat and API requests handled by local Agent |
| **Separated (Remote)** | Web UI and Hermes Agent deployed on different machines, communicating via HTTP API |

### Local Mode (Default)

```
Browser → Koa (:8648)
  ├── HTTP API → Koa Route → local GatewayManager (:18765) → local Agent
  └── Socket.IO → ChatRunSocket → AgentBridgeClient → GatewayManager → local Agent
```

### Separated Deployment

```
Browser
  ├── HTTP API → Vite Proxy (:5173) → remote Agent (:8642)
  └── Socket.IO → Koa (:8648) → handleApiRun → remote Agent (:8642/v1/responses)
```

### Configuration

**Production** (npm install -g):

```bash
export HERMES_GATEWAY_URL=http://192.168.0.39:8642
export HERMES_GATEWAY_API_KEY=your-secret-key
hermes-web-ui start
```

**Development** (source):

Set in `.env`:

```env
VITE_HERMES_GATEWAY_URL=http://192.168.0.39:8642
VITE_HERMES_GATEWAY_API_KEY=your-secret-key
```

### Switch Mode via UI (v0.5.32+)

The **Settings → Connection** page allows runtime mode switching **without restarting the server**:

1. Open Web UI, go to **Settings → Connection**
2. Select mode:
   - **Local Mode**: use local Koa + AgentBridge
   - **Separated Deployment**: connect to remote Agent
3. Enter remote URL and API Key (required for remote mode)
4. Click **Save**

When mode changes, the chat run `source` field changes accordingly:
- Local mode: `source: "cli"` → `handleBridgeRun` (local Agent)
- Remote mode: `source: "api_server"` → `handleApiRun` (remote Agent)

---

## Architecture

### Core Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                     Browser (Vue 3 + Vite)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────────┐  │
│  │  API Client   │  │ Socket.IO    │  │  Web Terminal (@xterm)    │  │
│  │  (client.ts)  │  │ (chat.ts)    │  │  (TerminalPanel)          │  │
│  └──────┬───────┘  └──────┬───────┘  └─────────┬─────────────────┘  │
└─────────┼─────────────────┼────────────────────┼─────────────────────┘
          │ HTTP API        │ Socket.IO (ws)     │ WebSocket (ws)
          │ (:5173)         │ (:8648)            │ (:8648)
          ▼                 ▼                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    BFF Layer (Koa :8648)                              │
│                                                                      │
│  ┌────────────────┐  ┌────────────────────┐  ┌───────────────────┐  │
│  │  Koa Routes     │  │  ChatRunSocket     │  │  PTY WebSocket    │  │
│  │  (REST API)     │  │  (Socket.IO ns)    │  │  (node-pty)       │  │
│  └───────┬────────┘  └─────────┬──────────┘  └────────┬──────────┘  │
│          │                     │                       │             │
│  ┌───────▼─────────────────────▼───────────────────────▼──────────┐ │
│  │                    Koa Proxy Middleware                        │ │
│  │  Local: GatewayManager → local Agent                          │ │
│  │  Remote: HTTP fetch → remote Agent (:8642)                    │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  DB (SQLite) │  File Store │  Auth │  Credentials │  Logger   │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

### Two-Layer Proxy (Dev Mode)

#### Layer 1: Vite Dev Proxy

Defined in `vite.config.ts`, forwards browser HTTP API requests to Koa:

```javascript
proxy: {
  '/api':    { target: 'http://127.0.0.1:8648' },
  '/v1':     { target: 'http://127.0.0.1:8648' },
  '/health': { target: 'http://127.0.0.1:8648' },
}
```

Socket.IO connections **bypass** Vite proxy — browsers connect directly to Koa at `:8648`.

#### Layer 2: Koa Proxy Middleware

Defined in `packages/server/src/routes/hermes/index.ts`, forwards backend API requests:

- Local mode → `GatewayManager` (:18765)
- Remote mode → `VITE_HERMES_GATEWAY_URL` (remote Agent)

**Path transformation**:
```
Client request:  /api/hermes/v1/responses
Koa proxy path:  /v1/responses  (strips /api/hermes prefix)
```

### Chat Run Flow

#### Local Mode

```
User sends message
  → client chat.ts store.sendMessage()
  → Socket.IO emit('run', { source: "cli", ... })
  → Koa ChatRunSocket receives event
  → resolveRunSource() returns "cli"
  → handleBridgeRun()
  → AgentBridgeClient.send()
  → GatewayManager (:18765)
  → Hermes Agent process
  → stream results back via Socket.IO events
```

#### Remote Mode

```
User sends message
  → client chat.ts store.sendMessage()
  → Socket.IO emit('run', { source: "api_server", ... })
  → Koa ChatRunSocket receives event
  → resolveRunSource() returns "api_server"
  → handleApiRun()
  → POST fetch("http://192.168.0.39:8642/v1/responses")
  → remote Hermes Agent processes
  → SSE stream frames parsed
  → converted to Socket.IO events back to browser
```

---

## Project Structure

```
hermes-web-ui/
├── .env                          # Dev environment (remote Agent URL)
├── .env.example                  # Environment variable template
├── package.json                  # Root package (monorepo scripts + server deps)
├── vite.config.ts                # Vite build config + dev proxy rules
├── tsconfig.json                 # TypeScript project references
│
├── bin/
│   └── hermes-web-ui.mjs         # CLI entry point (npm -g binary)
│
├── packages/
│   ├── client/                   # Frontend (Vue 3 + Vite + Naive UI)
│   │   └── src/
│   │       ├── api/              # API request layer
│   │       │   ├── client.ts     #   Generic fetch wrapper (getBaseUrl, request)
│   │       │   ├── auth.ts       #   Auth API
│   │       │   └── hermes/       #   Hermes-specific APIs
│   │       │       ├── chat.ts   #     Socket.IO chat connection manager
│   │       │       └── ...       #     Sessions, system, profiles, files, etc.
│   │       ├── components/
│   │       │   └── hermes/
│   │       │       ├── chat/     #     Chat panel, Kanban layout, terminal
│   │       │       ├── settings/ #     Settings (includes ConnectionSettings)
│   │       │       └── ...       #     Channels, jobs, logs, models, etc.
│   │       ├── stores/hermes/    # Pinia state management
│   │       │   ├── app.ts        #   Global state (deployMode, models, health)
│   │       │   ├── chat.ts       #   Chat store (sendMessage, sessions)
│   │       │   └── ...           #   Sessions, profiles, skills, etc.
│   │       ├── views/hermes/     # Page-level components
│   │       ├── router/           # Routes
│   │       ├── i18n/             # Internationalization
│   │       └── styles/           # SCSS styles
│   │
│   └── server/                   # Backend (Koa + Socket.IO + node-pty)
│       └── src/
│           ├── index.ts          # Koa app entry, middleware chain
│           ├── config.ts         # Config loading (env vars, paths)
│           ├── routes/
│           │   ├── health.ts     # /health endpoint
│           │   ├── auth.ts       # Auth routes
│           │   ├── upload.ts     # File upload
│           │   └── hermes/       # Hermes API proxy routes
│           │       └── index.ts  #   Koa proxy middleware (local/remote routing)
│           ├── services/
│           │   ├── auth.ts       # Auth logic
│           │   ├── logger.ts     # Logger
│           │   └── hermes/       # Hermes services
│           │       ├── run-chat/ #   Socket.IO chat run engine
│           │       │   ├── index.ts             #   ChatRunSocket class
│           │       │   ├── handle-api-run.ts    #   Remote proxy run (separated)
│           │       │   ├── handle-bridge-run.ts #   Local bridge run
│           │       │   ├── compression.ts       #   Context compression
│           │       │   ├── sse-utils.ts         #   SSE frame parser
│           │       │   └── ...                  #   Message format, usage calc
│           │       ├── agent-bridge/          # Agent Bridge client
│           │       ├── gateway-manager.ts      # Gateway process management
│           │       ├── group-chat/             # Group chat service
│           │       └── ...                     # Profiles, files, TTS, etc.
│           ├── controllers/     # Koa controllers
│           └── db/              # SQLite database layer
│               └── hermes/      #   Session store, usage store
│
├── dist/                         # Build output (client + server)
├── docs/
│   ├── docker.md                 # Docker deployment guide
│   └── cli-chat-sessions.md      # CLI session explanation
│
├── scripts/
│   ├── build-server.mjs          # Server build script
│   └── setup.sh                  # One-line install script
│
├── Dockerfile                    # Docker image build
├── docker-compose.yml            # Docker Compose orchestration
├── nodemon.json                  # Dev server hot-reload
│
├── DEVELOPMENT.md                # Development guidelines
└── LICENSE                       # BSL-1.1 license
```

---

## Environment Variables

### Web UI Runtime

| Variable | Default | Description |
| --- | --- | --- |
| `PORT` | `8648` | Web UI listen port |
| `BIND_HOST` | `0.0.0.0` | Bind address (`::` for IPv6) |
| `AUTH_TOKEN` | auto-generated | Bearer token |
| `AUTH_DISABLED` | unset | `1` or `true` disables auth |
| `PROFILE` | `default` | Initial Hermes profile name |
| `LOG_LEVEL` | `info` | Server log level |
| `BRIDGE_LOG_LEVEL` | `$LOG_LEVEL` | Bridge log level |
| `UPLOAD_DIR` | `$HERMES_WEB_UI_HOME/upload` | Upload directory |
| `CORS_ORIGINS` | `*` | CORS setting |
| `MAX_DOWNLOAD_SIZE` | `200MB` | Max download size |
| `MAX_EDIT_SIZE` | `10MB` | Max editable file size |
| `WORKSPACE_BASE` | `/opt/data/workspace` | Workspace browsing root |

**Data directory** (use one):

| Variable | Default | Description |
| --- | --- | --- |
| `HERMES_WEB_UI_HOME` | `~/.hermes-web-ui` | Web UI data home (preferred) |
| `HERMES_WEBUI_STATE_DIR` | `~/.hermes-web-ui` | Compatibility alias |

### Dev Mode (`.env` file)

| Variable | Default | Description |
| --- | --- | --- |
| `VITE_HERMES_GATEWAY_URL` | `http://127.0.0.1:8648` | Vite proxy + Koa proxy upstream target. Point at remote Agent for separated deployment |
| `VITE_HERMES_GATEWAY_API_KEY` | unset | Remote Agent API Key (must match `API_SERVER_KEY`) |

### Separated Deployment (Production)

| Variable | Description |
|---|---|
| `HERMES_GATEWAY_URL` | Full URL of remote Hermes Agent (including port) |
| `HERMES_GATEWAY_API_KEY` | Remote Agent API Key, must match agent's `API_SERVER_KEY` |

---

## CLI Commands

| Command                           | Description                        |
| --------------------------------- | ---------------------------------- |
| `hermes-web-ui start`             | Start in background (daemon mode)  |
| `hermes-web-ui start --port 9000` | Start on custom port               |
| `hermes-web-ui stop`              | Stop background process            |
| `hermes-web-ui restart`           | Restart background process         |
| `hermes-web-ui status`            | Check if running                   |
| `hermes-web-ui update`            | Update to latest version & restart |
| `hermes-web-ui upgrade`           | Alias for `update`                 |
| `hermes-web-ui -v`                | Show version number                |
| `hermes-web-ui -h`                | Show help message                  |

### Auto Configuration

On startup the BFF server automatically:

- Initializes Web UI data directories, local databases, and bundled skills
- Starts the Hermes agent bridge used by `/chat-run`
- Opens browser on successful startup

---

## Development

### Commands

```bash
npm run dev            # Start frontend + backend concurrently
npm run dev:client     # Start frontend only (Vite :5173)
npm run dev:server     # Start backend only (Koa :8648, nodemon hot-reload)
npm run build          # Type-check + build (client + server)
npm run test           # Vitest unit tests
npm run test:coverage  # Unit tests with coverage
npm run test:e2e       # Playwright E2E tests
```

### Guidelines

See [DEVELOPMENT.md](./DEVELOPMENT.md):

- Frontend: Vue 3 Composition API `<script setup lang="ts">`
- State: Pinia setup stores
- API: `request()` helper in `packages/client/src/api/client.ts`
- i18n: Add strings to all locale files
- Styles: Scoped SCSS
- Backend: Thin routes, logic in controllers/services
- Auth: Centralized in `packages/server/src/services/auth.ts`
- Chat runtime: `packages/server/src/services/hermes/run-chat/`

### Build Verification

```bash
npm run build
# Verify dist/ was generated:
ls dist/
# dist/server/  dist/client/
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Vue 3 + TypeScript + Composition API |
| **Build** | Vite 8 + vue-tsc |
| **UI** | Naive UI |
| **State** | Pinia |
| **Router** | Vue Router |
| **i18n** | vue-i18n |
| **Styles** | SCSS |
| **Markdown** | markdown-it + highlight.js |
| **Charts** | Mermaid |
| **Editor** | Monaco Editor |
| **Terminal** | @xterm/xterm + node-pty |
| **Backend** | Koa 2 |
| **Realtime** | Socket.IO (chat) + WebSocket (terminal) |
| **Database** | SQLite (better-sqlite3 compatible) |
| **Test** | Vitest + Playwright |
| **Container** | Docker / Docker Compose |

---

## License

[BSL-1.1](./LICENSE)
