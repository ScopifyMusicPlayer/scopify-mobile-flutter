# Scopify Web 已实现能力与移动端接口清单

> 审计日期：2026-08-08
> 审计范围：`frontend/apps/web` 当前代码，而不是后端理论上支持的全部功能。
> 用途：为移动端 Dio 适配、页面规划和验收提供同一份能力基线。

## 1. 怎么读这份文档

状态定义：

- **已接通**：Web 中存在可到达的用户入口，并能追到对应接口或本地实现。
- **部分接通**：页面存在，但其中仍有占位动作、未覆盖状态或只完成了部分能力。
- **仅封装**：`lib/api` 中已有请求函数，但没有找到当前 Web UI 的活跃调用。
- **运行时专属**：只适用于 Web 或 Electron，不直接移植到独立 Flutter App。
- **移动 V1**：独立移动端首个可发布版本要覆盖。
- **后置**：保留接口和产品入口，但不阻塞移动 V1。

能力与页面之间使用稳定编号关联。页面规格见 [mobile-pages.md](./mobile-pages.md)，实施顺序见 [project-plan.md](./project-plan.md)。

## 2. 总览

| 能力编号 | 领域 | Web 当前能力 | 登录要求 | 移动端结论 |
| --- | --- | --- | --- | --- |
| AUTH-01 | 二维码登录 | 生成 key、获取后端返回的 Base64 二维码、轮询扫码状态 | 游客 | **移动 V1，唯一登录方式** |
| AUTH-02 | 会话 | 校验登录态、保存并附加网易云 Cookie、会话失效清理 | 混合 | **移动 V1** |
| HOME-01 | 首页 | 时段欢迎、日推入口、活动、声音、推荐歌单、推荐歌手 | 混合 | **移动 V1，保持 Web 区块顺序** |
| SEARCH-01 | 搜索 | 默认词、联想、综合及六类垂直结果、分页与播放 | 游客 | **移动 V1，Spotify 风格入口** |
| PLAY-01 | 在线播放 | 音源解析、失败降级、音质、可播检查相关封装 | 游客/会话增强 | **移动 V1** |
| PLAY-02 | 队列控制 | 播放/暂停、前后曲、随机、循环、音量、队列增删与调整 | 游客 | **移动 V1；移动端补后台控制** |
| PLAY-03 | 歌词 | 新版歌词、高潮时间、同步歌词与 Folia 舞台 | 游客 | **V1 原生同步歌词（Folia 式原文 + 翻译双行）；完整 Folia 后置** |
| LIB-01 | 我的音乐 | 我喜欢、最近歌曲、自建与收藏歌单 | 登录 | **移动 V1，归入“我的 / 音乐”** |
| LIB-02 | 歌单管理 | 创建、删除、编辑资料/标签/封面、加删歌曲 | 登录 | **移动 V1 分阶段接入** |
| LIB-03 | 收藏 | 关注歌手、收藏专辑及对应列表 | 登录 | **移动 V1，归入“我的 / 收藏”** |
| LIB-04 | 播客与声音 | 订阅、创建的声音单、喜欢的声音、详情、节目与文字稿 | 登录/公开详情 | **移动 V1，归入“我的 / 播客”** |
| CAT-01 | 歌单详情 | 元信息、曲目、播放、随机、列表内搜索、日推历史 | 混合 | **移动 V1** |
| CAT-02 | 歌手详情 | 资料、粉丝数、热门歌曲、专辑、关注 | 公开读/登录写 | **移动 V1** |
| CAT-03 | 专辑详情 | 资料、曲目、播放、收藏 | 公开读/登录写 | **移动 V1** |
| CAT-04 | 电台/声音详情 | 电台节目、收藏，声音单和声音文字稿 | 混合 | **移动 V1** |
| SOCIAL-01 | 歌曲评论 | 热门/普通评论、分页、点赞、发布、回复、删除自己的评论 | 公开读/登录写 | **移动 V1** |
| USER-01 | 用户资料 | 资料、公开歌单、最近播放、编辑自己的资料 | 混合 | **移动 V1 的共用 Profile 与编辑入口** |
| USER-02 | 网易乐签 | 签到、历史、日期详情，入口位于头像菜单 | 登录 | **移动 V1，归入 App Drawer 卡片与结果 Modal** |
| USER-03 | 用户关注 | 后端支持 `/follow`；Web Profile 按钮当前只在组件内切换状态，未接真实请求 | 登录 | **移动 V1 必须接真实关注/取消关注，不继承假状态** |
| MATCH-01 | 听歌识曲 | 客户端录音、本地生成声纹、`/audio/match` 返回候选歌曲 | 游客 | **移动 V1；Flutter 本地声纹生成先做技术验证** |
| UPDATE-01 | Android 检查更新 | GitHub Releases 版本差异、APK 下载、摘要校验与系统安装 | 游客 | **入口与线稿已确认，实现后置** |
| SETTINGS-01 | 设置 | 通用、网络、存储、桌面、快捷键 | 混合 | **移动重组为通用/播放/网络/存储/关于** |

## 3. 认证与会话

### AUTH-01 二维码登录 — 已接通

Web 入口为 `/login`，当前页面同时展示二维码、密码和短信三种模式。移动产品决定只保留二维码模式。

二维码流程必须作为一个完整状态机实现，而不是让页面依次拼三个请求：

1. `GET /login/qr/key` 获取 key。
2. `GET /login/qr/create?key=...&qrimg=true` 获取后端返回的 Base64 图片。
3. 使用同一个 key 轮询 `GET /login/qr/check`。
4. 扫码确认成功后保存返回的网易云会话凭据，再调用登录状态接口校验。
5. 过期、取消或离开页面时停止旧轮询；刷新二维码会创建新的 key。

移动端直接展示 `qrimg`，**不根据 key 在本地重新绘制二维码**。文案只要求“请使用网易云音乐扫码”；用户可以截图或保存图片后交给另一台设备/应用扫描。

移动端还需复用 Web `QrLogin` 的状态语义与轮询节奏：`801 → waiting`、`802 → scanned`、`800 → expired`、`803 → success`；二维码请求完成后约 3 秒再开始下一次检查。`scanned` 和 `expired` 是二维码区域本身的遮罩状态，不是底部 Toast；过期/网络失败统一提供“刷新二维码”并取消旧 key 轮询。

| 请求 | Web 调用 | 移动端用途 |
| --- | --- | --- |
| `GET /login/qr/key` | `getQRKey` | 开始一次二维码登录尝试 |
| `GET /login/qr/create` | `createQR` | 获取 Base64 二维码图像 |
| `GET /login/qr/check` | `checkQR` | 轮询等待扫码、确认、过期状态 |
| `POST /login/status` | `getLoginStatus` | 启动恢复与登录成功后的会话校验 |
| `GET /logout` | `logout` | 清除服务端会话；本地凭据无条件一并清除 |
| `GET /login/cellphone` | `loginByCellphone` | Web 可见，**移动端不适配为用户能力** |

### AUTH-02 会话和游客模式 — 已接通

- 游客可访问首页、搜索、公开详情、公开播放和评论读取。
- “我的”以及喜欢、收藏、关注、评论写入、资料编辑等动作触发二维码登录。
- 网易云 Cookie 是不透明的会话凭据，不能写入日志、错误报告或页面状态。
- 请求返回“HTTP 成功但业务码表示未登录”时也要触发统一失效流程。
- Web 使用 `localStorage`；移动端必须使用平台安全存储，页面和领域方法不能接收 Cookie 参数。

## 4. 首页

### HOME-01 首页信息流 — 已接通

Web 当前显示顺序如下，移动端首轮保持相同信息层级：

1. 时段欢迎语。
2. 每日推荐入口与快捷推荐歌单。
3. Featured Activities 活动轮播。
4. Recommended Voice Feed 推荐声音。
5. 数据失败时的就地重试提示。
6. “为你推荐”歌单。
7. 推荐歌手。

| 区块 | 数据/动作 | 接口 | 登录 |
| --- | --- | --- | --- |
| 每日推荐入口 | 打开今日推荐；详情内可播放与“不感兴趣” | `/recommend/songs`、`/recommend/songs/dislike` | 是 |
| 快捷推荐歌单 | 登录用户随机挑选最多 8 个推荐歌单 | `/recommend/resource` | 是 |
| 活动轮播 | 活动图片和跳转目标 | `/banner?type=0` | 否 |
| 推荐声音 | 可播放的 Recommended Voice Feed | `/v1/pc/voicelist/rcmd/list` | 否 |
| 推荐歌单 | 个性化公开歌单；可直接取全部歌曲播放 | `/personalized`、`/playlist/track/all` | 否 |
| 推荐歌手 | 热门歌手入口 | `/top/artists` | 否 |
| 个性化欢迎 | 登录后补全昵称和头像 | `/user/detail` | 是 |

首页具备骨架屏、缓存数据、局部失败和重试。移动端不应因为一个可选区块失败而清空整个首页。

## 5. 搜索

### SEARCH-01 搜索发现与结果 — 已接通

Web 搜索结果固定七类：`All / Songs / Artists / Playlists / Albums / Podcasts / Voices`。移动入口采用已确认的 Spotify 风格：大搜索框和双列分类卡；输入后切换到同样的七类筛选。

| 能力 | 接口 | Web 状态 | 移动 V1 |
| --- | --- | --- | --- |
| 默认搜索词 | `/v1/search/default/keyword/pc` | 顶部搜索已使用 | 是 |
| 输入联想 | `/search/suggest/pc` | 已使用 | 是 |
| 热搜列表 | `/search/hot` | 仅封装，未找到活跃 UI 调用 | 后置 |
| 综合搜索/最佳匹配 | `/search/pc/complex/page/v3` | 已使用 | 是 |
| 歌曲分页 | `/v1/search/song/pc` | 已使用 | 是 |
| 歌单分页 | `/v1/search/playlist/pc` | 已使用 | 是 |
| 专辑分页 | `/v1/search/album/pc` | 已使用 | 是 |
| 歌手分页 | `/v1/search/artist/pc` | 已使用 | 是 |
| 播客/声音单分页 | `/voicelist/search` | 已使用 | 是 |
| 声音分页 | `/search?type=2000` | 已使用 | 是 |

所有结果页都需要：加载、空结果、局部网络错误、重试、分页尾部和正在加载下一页状态。歌曲和声音可直接播放；歌单、专辑可直接播放或进入详情；歌手进入歌手详情。

## 6. 在线播放、队列与歌词

### PLAY-01 音源解析 — 已接通

| 能力 | 接口 | 说明 |
| --- | --- | --- |
| 首选音源 | `/song/url/v1?id=...&level=...` | 按选择的音质请求 |
| 灰色歌曲降级 | `/song/url/match?id=...` | 首选接口无 URL 或失败时自动降级 |
| 歌曲详情 | `/song/detail?ids=...` | 补齐标题、歌手、专辑和封面 |
| 喜欢数 | `/song/red/count` | 播放页互动统计 |
| 音质详情 | `/song/music/detail` | 已封装，未找到活跃 Web 调用 |
| 可播检查 | `/check/music` | 已封装，未找到活跃 Web 调用 |

Web 的音质映射包含 `standard / high / lossless / hires / spatial / dolby / jymaster / sky` 等层级。移动端必须由播放来源 Module 隐藏层级映射与 URL 降级，页面只选择产品定义的音质选项并接收可播放结果。

### PLAY-02 播放状态 — 已接通，移动端需平台化

Web 已有：

- 播放、暂停、上一首、下一首。
- 随机、列表循环、单曲循环。
- 音量与静音恢复。
- 当前队列、队列项删除、移到下一首、队列顺序调整。
- 播放 URL 或音频失败后的跳过/停止策略：有下一首时最多连续自动跳过两次，并通过根部顶部全局 Toast 提示；达到阈值或没有下一首时停止并显示顶部全局错误 Toast，移动端可在该 Toast 提供重试和下一首动作。
- 迷你播放条和完整播放界面入口。

移动 V1 在此基础上必须增加 Android 后台播放、通知栏与锁屏控制、耳机/蓝牙媒体按键及音频焦点处理。播放队列归移动设备本地所有，不与 Web/Electron 共享。

### PLAY-03 歌词 — 已接通，分层移植

| 能力 | 接口/实现 | 移动端结论 |
| --- | --- | --- |
| 新版歌词 | `/lyric/new` | V1 |
| 高潮时间 | `/song/chorus` | Web Folia 已使用；移动后置 |
| 同步滚动歌词 | Web 原生歌词与 Folia 共用数据 | V1 用原生 Flutter 页面，固定原文主行 + 翻译副行；不提供罗马音或字幕模式切换 |
| Folia 九种视觉效果 | Web Lyric Stage | 完整套件后置，不能把简化版称为 parity |
| Electron 桌面歌词窗 | `/desktop-lyrics` 与 runtime bridge | 不移植 |

## 7. 音乐库与歌单

### LIB-01 我的音乐 — 已接通

移动端“我的 / 音乐”包含：

- 我喜欢的音乐：`/likelist` 获取 ID，结合歌单/歌曲详情展示；`/like` 喜欢或取消喜欢。
- 最近播放歌曲：`/record/recent/song`。
- 自建歌单与收藏歌单：`/user/playlist` 返回后按所有者/`subscribed` 分类。
- 歌单详情及全量歌曲：`/playlist/detail`、`/playlist/track/all`。

Web 的 `/liked`、`/recent` 和侧边栏歌单库均有登录提示、加载、空状态与重试。移动端把它们收拢到 My Hub，而不是复制桌面侧边栏。

### LIB-02 歌单管理 — 已接通与仅封装并存

| 操作 | 接口 | Web 证据状态 | 移动端范围 |
| --- | --- | --- | --- |
| 创建公开/私密歌单 | `/playlist/create` | 侧边栏表单已接通 | V1 |
| 删除自己的歌单 | `/playlist/delete` | 侧边栏右键菜单已接通 | V1 |
| 修改名称、描述、标签 | `/playlist/update`、`/playlist/tags/update` | 编辑弹窗已接通 | V1 |
| 修改封面 | `POST /playlist/cover/update` | 编辑弹窗已接通 | V1 |
| 获取精品标签 | `/playlist/highquality/tags` | 表单已使用 | V1 |
| 加歌/删歌 | `/playlist/tracks?op=add|del` | 歌曲菜单与歌单表格已接通 | V1 |
| 收藏/取消收藏歌单 | `/playlist/subscribe?t=1|2` | **仅封装，未找到活跃 UI 调用** | 列表 V1；写操作集成前复核 |
| 歌单内搜索 | 客户端过滤 | 已接通 | V1 |
| 播放/随机播放 | 客户端队列 + `/playlist/track/all` | 已接通 | V1 |
| 分享 | 当前仅侧边栏复制网易云链接；详情“更多”仍有 TODO | 部分接通 | 后置 |
| 下载 | 仅有无处理器图标 | 未实现 | 不做；移动端是纯流媒体 |
| 曲目持久化重排 | 无接口调用；Web 只有本地播放队列重排 | 未实现 | 后置 |
| 歌单评论 | 无当前页面与接口封装 | 未实现 | 后置 |

每日推荐另有：`/recommend/songs`、`/recommend/songs/dislike`、`/history/recommend/songs`、`/history/recommend/songs/detail`。历史日推依赖账号权限，失败时要显示后端原因而不是伪造空列表。

## 8. 歌手、专辑与收藏

### CAT-02 / LIB-03 歌手 — 已接通

- 歌手资料：`/artist/detail`（代码中另有 `/artists/detail` 的旧封装）。
- 粉丝数：`/artist/follow/count`。
- 热门歌曲：`/v1/artist/songs`。
- 专辑列表：`/artist/album`。
- 关注列表：`/artist/sublist`。
- 关注/取消关注：`/artist/sub?t=1|0`，公开详情可读，写操作需登录。
- MV 列表：`/artist/mv` **仅封装，未找到活跃 UI 调用，移动后置**。

### CAT-03 / LIB-03 专辑 — 已接通

- 详情和曲目：`/album`。
- 收藏列表：`/album/sublist`。
- 收藏/取消收藏：`/album/sub?t=1|0`。
- 详情页支持整张播放、歌曲列表、跳转歌手和收藏登录门槛。

移动端“我的 / 收藏”只放关注歌手和收藏专辑。收藏歌单仍属于“我的 / 音乐”。

## 9. 播客、声音单、声音和电台

这里必须保持领域区分：

- **Voice List**：新的声音单容器，ID 为 `voiceListId`。
- **Voice**：Voice List 中的单条声音，可有歌词/文字稿。
- **DJ Radio**：旧电台容器，ID 为 `rid`。
- **DJ Program**：DJ Radio 内的节目，通常通过 `mainTrackId` 播放。
- 首页 `/v1/pc/voicelist/rcmd/list` 返回的是嵌入 DJ Program 的 Recommended Voice Feed，不应误叫“推荐声音单”。

### LIB-04 / CAT-04 — 已接通

| 能力 | 接口 | 移动端位置 |
| --- | --- | --- |
| 已订阅 Voice List | `/voicelist/my/subscribed` | 我的 / 播客 / 订阅 |
| 我创建的 Voice List | `/voicelist/my/created` | 我的 / 播客 / 创建 |
| 喜欢的声音 | `/content/my/liked/voice` | 我的 / 播客 / 喜欢的声音 |
| 播客推荐 | `/djradio/my/radio/recommend` | 播客订阅页补充区块 |
| Voice List 详情 | `/voicelist/detail` | 详情页 |
| Voice 详情 | `/voice/detail` | 播放或详情 |
| Voice 歌词/文字稿 | `/voice/lyric` | 文字稿面板 |
| 搜索 Voice List | `/voicelist/search` | 搜索 / Podcasts |
| 搜索 Voice | `/search?type=2000` | 搜索 / Voices |
| DJ Radio 详情 | `/dj/detail` | 电台详情 |
| DJ Programs | `/dj/program/v6` | 电台节目列表 |
| DJ Radio 订阅列表 | `/dj/sublist` | 详情收藏状态/兼容旧电台 |
| DJ Radio 订阅切换 | `/dj/sub?t=1|0` | 详情页，登录写入 |

“创建”目前指**查看自己创建的 Voice List 分类**；当前 Web API 文件没有创建 Voice List 的写接口，移动端不要误做一个无法提交的创建表单。

## 10. 歌曲评论

### SOCIAL-01 — 已接通，移动 V1 完整对齐

Web `/comment` 页面已实现：

- 热门评论与普通评论。
- 每页 20 条的分页读取。
- 游客读取。
- 登录后点赞/取消点赞、发布、回复、删除自己的评论。
- 登录门槛、提交中状态、失败反馈和返回歌曲/歌手详情。

| 操作 | 接口 | 登录 |
| --- | --- | --- |
| 读取评论 | `/comment/music` | 否 |
| 发布评论 | `/comment/add` | 是 |
| 回复评论 | `/comment?t=2&type=0` | 是 |
| 删除自己的评论 | `/comment?t=0&type=0` | 是 |
| 点赞/取消点赞 | `/comment/like?t=1|0&type=0` | 是 |

移动端评论从完整播放页进入。评论写入完成后应更新本地列表与计数，不让页面自行操作 Dio 或 Cookie。

## 11. 用户资料与账号工具

### USER-01 用户资料 — 已接通

| 能力 | 接口 | Web 状态 | 移动端 |
| --- | --- | --- | --- |
| 用户详情与统计 | `/user/detail` | 已接通 | V1 My Hub 头部与共用 Profile |
| 账号快照 | `/user/account` | 已接通 | V1 启动恢复 |
| 公开歌单 | `/user/playlist` | 已接通 | V1 |
| 最近播放歌单 | `/record/recent/playlist` | 自己的资料页已接通 | 后续扩展；首版 RECENT-01 只使用歌曲结构 |
| 最近歌曲 | `/record/recent/song`、`/user/record` | 已接通 | V1 |
| 最近专辑 | `/record/recent/album` | 仅封装，未找到当前入口 | 后置 |
| 编辑自己的资料 | `/user/update` | `/profile` 编辑弹窗已接通 | V1 |
| 关注列表/粉丝列表 | `/user/follows`、`/user/followeds` | 有封装；当前资料页主要显示计数 | 后置详情页 |
| 历史评论 | `/user/comment/history` | 仅封装 | 后置 |

Web `/me` 是硬编码的开发者/项目介绍页，不是账号资料页，**不移植为移动端“我的”**。真实用户资料入口是 `/profile`。

### USER-02 网易乐签 — 已接通，移动 V1

头像菜单已有签到入口，使用 `/vip/sign`、`/vip/sign/history` 和 `/vip/sign/detail`；`/vip/sign/info` 仅封装。移动 V1 将它放进 App Drawer 卡片：未签到时一键执行，已签到时只读打开同一个结果 Modal。

### USER-03 用户关注 — 后端存在，Web 未真实接入

用户关注后端使用 `/follow?id=...&t=1|0`。Web Profile 当前只维护按钮局部状态，没有调用该接口；移动端适配必须补齐真实 mutation、登录门槛、请求中去重、失败回滚和缓存更新。

### MATCH-01 听歌识曲 — 后端与 Web Demo 已存在，移动实现待验证

后端 `/audio/match` 读取 `duration` 与 `audioFP`，再把声纹作为 `rawdata` 请求网易云识曲接口；它不接收原始音频文件。现有 `public/audio_match_demo` 会录制约 3 秒、使用 8 kHz 采样，并通过 `ncm-afp` WASM 的 `GenerateFP(Float32Array)` 在浏览器本地生成声纹。结果位于 `data.result`，候选项提供歌曲信息与匹配起始时间。

移动端必须保留“原始采样留在设备、本地生成声纹、只提交 `duration + audioFP`”这条边界。Flutter 采用何种 native/FFI/WASM 兼容实现仍需技术验证；验证任务完成前，该能力不能仅凭接口存在就标记为移动端已实现。

### UPDATE-01 Android 检查更新 — 移动新增，功能后置

Web/Electron 的桌面更新实现不直接移植。移动端首个非 Play 分发方案使用 GitHub Releases：读取 latest release 与 APK Release Asset，展示版本差异和发布说明，下载后校验 Asset digest，再调用 Android 系统安装流程。当前只确认 App Drawer 入口、Modal 和状态合同，下载、安装权限处理与失败恢复后置。

## 12. 设置与运行时能力

### SETTINGS-01 Web 已有设置

Web `/setting` 当前包含：

- 通用：语言；Electron 下另有 GPU、开发者工具、关闭行为和开发环境前端地址。
- 网络：后端 host/port、连接测试、超时、随机中国 IP；Electron 下另有代理模式和代理 URL。
- 存储：播放缓存统计/清理；Electron 下另有缓存开关、目录、上限、页面 TTL、搜索 TTL 和清空。
- 桌面：日志、更新等 Electron 专属项。
- 快捷键：Web/Electron 窗口内快捷键注册与编辑。

移动端重组为五个页面分组：

1. 通用：语言、外观/跟随系统等移动配置。
2. 播放：默认音质、流量网络策略、后台播放相关说明与定时关闭。
3. 网络：可编辑公开后端地址、测试连接、恢复默认和传输安全提示。
4. 存储：临时播放缓存统计、上限和清理；不出现离线下载。
5. 关于：版本、许可证、源代码与隐私说明。

Mobile Backend Endpoint 规则：公共域名必须是 HTTPS；`localhost`、回环地址和私有局域网地址可以使用 HTTP，但界面必须明确显示“不安全本地连接”。公共 HTTP 不能静默放行或自动降级。

### 不移植的 Web/Electron 专属能力

- 桌面托盘页和托盘命令。
- 独立桌面歌词窗口。
- Electron 窗口关闭策略、GPU 开关、开发者工具。
- 桌面代理模式、日志路径和桌面自动更新实现。
- 桌面窗口内快捷键注册；移动端使用平台媒体控制和触摸交互。
- 浏览器历史滚动恢复的 DOM 实现；移动端只保留“返回时恢复列表位置”的用户体验要求。

## 13. Dio 适配清单

Dio 工作流按能力而不是按页面零散接入。下面的“适配”指生产 Adapter、DTO/映射、错误归一化、Fake Adapter 行为和 seam 级测试全部可用。

### P0：启动、游客与播放

- [ ] AUTH-01：`/login/qr/key`、`/login/qr/create`、`/login/qr/check`
- [ ] AUTH-02：`/login/status`、`/logout`、会话附加与失效清理
- [ ] SETTINGS-01：后端地址解析、传输安全校验、连接测试
- [ ] HOME-01：`/banner`、`/personalized`、`/v1/pc/voicelist/rcmd/list`、`/top/artists`
- [ ] SEARCH-01：默认词、联想、综合、歌曲、歌单、专辑、歌手、声音单、声音
- [ ] PLAY-01：`/song/detail`、`/song/url/v1`、`/song/url/match`、`/lyric/new`

### P1：个人库与详情

- [ ] 登录首页补充：`/recommend/resource`、`/recommend/songs`、`/user/detail`
- [ ] LIB-01：`/likelist`、`/like`、`/record/recent/song`、`/user/playlist`
- [ ] CAT-01：`/playlist/detail`、`/playlist/track/all`
- [ ] CAT-02：歌手详情、热门歌曲、专辑、关注列表与关注切换
- [ ] CAT-03：专辑详情、收藏列表与收藏切换
- [ ] LIB-04/CAT-04：Voice List、Voice、DJ Radio 和 DJ Program 相关接口
- [ ] USER-01：`/user/account`、`/user/update`、公开资料所需接口

### P2：写操作、社交与增强

- [ ] LIB-02：歌单创建、删除、更新、封面上传、标签、加删歌曲
- [ ] SOCIAL-01：评论读取、分页、发布、回复、删除、点赞
- [ ] 日推增强：不感兴趣与历史日推
- [ ] 播放增强：`/song/red/count`、`/song/music/detail`、`/check/music`、`/song/chorus`
- [ ] USER-02：网易乐签
- [ ] USER-03：`/follow` 真实关注/取消关注、登录门槛、失败回滚与 Profile 缓存更新
- [ ] MATCH-01：Flutter 端 3 秒采样、本地声纹生成、`/audio/match` 与结果播放闭环
- [ ] 经产品复核后接入仅封装能力：歌单订阅、MV、热搜、最近专辑、用户关注/粉丝列表详情、历史评论

### 后置：发布与分发

- [ ] UPDATE-01：GitHub Releases 检查、APK 下载进度、SHA-256 校验、未知来源安装权限与系统安装器

## 14. 明确不把“存在接口”当成“已经实现”

以下项目不能用于宣称 Web 已有完整能力：

- `/playlist/subscribe`：有函数，无已验证活跃 UI 调用。
- `/artist/mv`：有函数，无已验证活跃页面。
- `/search/hot`：有函数，当前搜索入口未使用。
- `/song/music/detail`、`/check/music`：有封装，当前播放主链路未使用。
- `/record/recent/album`、`/user/comment/history`：有封装，未找到当前入口。
- `/user/playlist/create`：旧/特殊查询封装，当前创建歌单实际使用 `/playlist/create`。
- Voice List 新建写操作：当前 API 文件不存在。
- 歌单详情“下载”和“更多”图标：仍有 TODO 或无处理器。
- 歌单曲目持久化重排、歌单评论：当前未实现。

## 15. 审计来源

主要入口和实现：

- Web 页面：`frontend/apps/web/app/(dashboard)` 与 `frontend/apps/web/app/(auth)/login`
- 请求封装：`frontend/apps/web/lib/api`
- 首页：`frontend/apps/web/hooks/home`、`frontend/apps/web/components/home`
- 搜索：`frontend/apps/web/hooks/search`、`frontend/apps/web/components/search`
- 个人库：`frontend/apps/web/hooks/library`、`frontend/apps/web/components/library`
- 播放：`frontend/apps/web/store/module/player`、`frontend/apps/web/components/PlayBar`
- 设置：`frontend/apps/web/components/settings`、`frontend/apps/web/hooks/settings`
- 听歌识曲：`backend/api-enhanced/module/audio_match.js`、`backend/api-enhanced/public/audio_match_demo`

本文件描述的是审计时刻的代码事实。若 Web 后续新增入口，先更新这里的状态和能力编号，再扩展移动端 Adapter 与页面。
