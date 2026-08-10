<div align="center">

<img alt="logo" height="100" width="100" src="docs/img/icon.ico" />
<h2> Scopify-mobile </h2>
<p> 一个仿 Spotify UI 的移动端播放器 </p>

[后端 API](https://vdoonnridu.apifox.cn/) | [发行版](https://github.com/MT-SUPER-POWER/Scopify/releases) | [版本日志](https://github.com/MT-SUPER-POWER/Scopify/blob/master/docs/CHANGELOG.md)

<br/>

[![Stars](https://img.shields.io/github/stars/MT-SUPER-POWER/Scopify?style=flat)](https://github.com/MT-SUPER-POWER/Scopify/stargazers)
[![Version](https://img.shields.io/github/v/release/MT-SUPER-POWER/Scopify)](https://github.com/MT-SUPER-POWER/Scopify/releases)
[![license](https://img.shields.io/github/license/mt-super-power/scopify)](https://github.com/mt-super-power/scopify/blob/master/license)
[![Issues](https://img.shields.io/github/issues/MT-SUPER-POWER/Scopify)](https://github.com/MT-SUPER-POWER/Scopify/issues)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/MT-SUPER-POWER/Scopify)

</div>

## 简介

这是一个基于 Flutter 配合网易云 node.js API 的一个客户端音乐播放器，是我初学 flutter 的第一个项目。

## 技术栈总览

- 应用与 UI：Flutter + Dart、Material 3、Scopify Tokens/Components。
- 路由：`go_router` + `go_router_builder`。
- 状态与数据：Flutter Riverpod 3、Dio、`json_serializable`。
- 本地存储：Sqflite、`SharedPreferencesAsync`、`flutter_secure_storage`。
- 播放：`just_audio`、`audio_service`、`audio_session`。
- UI 辅助：`cached_network_image`、`permission_handler`、`flutter_animate`、Slang。
- 测试：`flutter_test`、Mocktail、Alchemist、`sqflite_common_ffi`。

完整选择、边界和延后项目见 [docs/technical-stack.md](./docs/technical-stack.md)。

### 代码结构

仓库使用 Flutter 管理移动端应用：

新建或修改代码前，请先阅读：

- **[AGENTS.md](./AGENTS.md)** — 项目结构规范
- **[docs/structure.md](./docs/structure.md)** — 面向贡献者的结构说明与迁移进度

### 重要的三方库

> 特别感谢以下项目的开源：

1. [Folia](https://github.com/chthollyphile/folia-major/tree/main) — complete Playback Stage and desktop-lyric presentation source snapshot (AGPL-3.0)
2. [Netease Cloud Music API Enhanced](https://github.com/neteasecloudmusicapienhanced/api-enhanced)

### 参考文档

1. [Folia Source Snapshot](https://github.com/chthollyphile/folia-major/tree/main)
2. [Electron Doc](https://www.electronjs.org/zh/docs/latest/api/app)
3. [Netease Cloud Music API Doc](https://docs-neteasecloudmusicapi.focalors.ltd/#/)
4. [Electron Builder Help Doc - Not Official](https://github.com/QDMarkMan/CodeBlog/blob/master/Electron/electron-builder%E6%89%93%E5%8C%85%E8%AF%A6%E8%A7%A3.md)

## 部署方法

Scopify 现在把桌面客户端、Web 前端和后端分开管理。前端构建不依赖后端源码；Web 和桌面客户端只需要能访问一个独立运行的 NetEase API 后端。

### 1. Docker Compose 部署 Web

推荐用于本机、局域网或私有服务器部署。根目录的 `docker-compose.yml` 会启动 Web 和后端（需要已拉取 `backend/api-enhanced` submodule）：

- Web: `http://127.0.0.1:3000`
- Backend: `http://127.0.0.1:3838`

```bash
git clone https://github.com/MT-SUPER-POWER/Scopify.git
cd Scopify
docker compose up -d --build
```

查看状态和日志：

```bash
docker compose ps
docker compose logs -f frontend
```

可以在根目录创建 `.env` 覆盖 Web 端口和浏览器可访问的后端地址：

```env
FRONTEND_PORT=3000
BACKEND_PUBLIC_HOST=127.0.0.1
BACKEND_PUBLIC_PORT=3838
```

`BACKEND_PUBLIC_HOST` 是浏览器访问后端时使用的地址。如果 Web 部署在服务器上并给其他设备访问，请改成服务器 IP 或域名，而不是 `127.0.0.1`。

Docker Web 会在根 workspace 安装依赖，执行 `bun run build:web`，然后从 `frontend/apps/web` 运行 `next start`。Electron 使用的静态 Renderer 是另一个构建目标，不用于普通 Web 部署。

### 2. 桌面客户端连接独立后端

Release 安装包只包含桌面客户端，不内置或自动启动后端。使用前请先部署 backend，然后在 `frontend/apps/desktop/config/app.config.yml` 中配置构建时默认后端地址：

```yaml
backend:
  host: 127.0.0.1
  port: 3838
```

如果后端部署在远程服务器，把 `host` 改成服务器 IP 或域名。客户端会请求 `http://host:port`。

### 3. 后端部署

后端可以独立部署，不需要和前端在同一个仓库 checkout 中构建。你可以使用已有的 NetEase API Enhanced 服务，只要保证 Web 或客户端能访问到它。

如果需要从本仓库的后端子模块构建，再单独拉取 submodule：

```bash
git submodule update --init --recursive backend/api-enhanced
cd backend/api-enhanced
docker build -t scopify-backend .
docker run -d --name scopify-backend -p 3838:3838 -e HOST=0.0.0.0 -e PORT=3838 scopify-backend
```

### 4. 本地开发

```bash
bun install
bun run dev:web          # 仅 Next.js Web
bun run dev:desktop      # 仅 Electron（开发时使用 Web dev server）
bun run dev              # Web + Electron
bun run dev:full         # Web + Electron + backend
```

如果需要同时调试后端，先拉取后端子模块，然后再运行后端开发脚本：

```bash
git submodule update --init --recursive backend/api-enhanced
bun run dev:backend
```

`dev:web` 是开发服务；生产 Web 使用 `bun run build:web` + `bun run --cwd frontend/apps/web start`。桌面端使用 `bun run build:desktop` 构建静态 Renderer 和 Electron 主进程，打包时运行 `bun run build:win` 或 `bun run build:mac`。


## 单页展示

> 还有很多细节要打磨，目前只是初定设计，如果你有任何特别好的想法，请务必提 issue 或者 PR 来告诉我。

## TODO

- [ ] 歌单的评论区
- [ ] 云盘功能
- [ ] 拉去 github 的 release 自动更新客户端版本
- [ ] 设备管理区域
- [ ] 编辑歌单的部分还要做一个 Tag 的编辑功能
- [ ] 系统消息机制的完善
- [ ] 用户个人信息的编辑
  - [ ] 昵称检测 API(`/nickname/check`) 接入，提前告知用户是否可以修改为该昵称
- [ ] 好友功能的完善
  - [ ] Followers 和 Followings 的 Modal 展示
- [ ] 对正在播放的歌曲再次播放的话，可以重新请求（解决有些的时候的 bug 问题）
- [ ] 宽度比较小，高度高的情况下，在歌词 UI 有一部分头部内容没有渲染出来

### 提案

- [ ] 可选的 AI 歌曲主题生成：用户配置 Gemini 或 OpenAI-compatible API Key，根据歌曲歌词和封面生成视觉参数。该能力不属于当前 Folia 歌词舞台迁移范围。
- [ ] 将歌词舞台的双色主题库扩展为 Scopify 应用级主题系统；当前主题库仅作用于 Lyric Stage，不影响主应用界面。
- [ ] 本地音乐库管理
- [ ] 接入 QQ、AMLLDB、酷狗等多源歌词匹配
- [ ] Discord 显示正在使用我们的软件

## 版本号规则

> 版本号的发布规则 `x.y.z`

- `x`: 重大更新，可能包含不兼容的 API 修改
- `y`: 次要更新，添加了新功能，但保持向后兼容
- `z`: 修复 bug 和小的改进，不添加新功能

## 开源许可

- 本项目基于 [GNU Affero General Public License v3.0](https://www.gnu.org/licenses/agpl-3.0.html) 许可进行开源
