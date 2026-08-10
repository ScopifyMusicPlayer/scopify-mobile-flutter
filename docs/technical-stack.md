# Scopify Mobile 技术栈决策

> 本文只记录已经确认的移动端技术选择。Web/Electron 技术栈用于说明需要的能力，不要求 Flutter 使用同名库。

## 选型原则

- 优先使用 Flutter 官方、稳定且容易调试的能力。
- 第三方库必须解决明确问题，不能因为 Web 使用了相似库就机械引入。
- 保留 Scopify 自己的组件、业务 Module 与测试边界，避免第三方框架成为产品架构中心。
- 每项选择都要适合当前维护者的 Flutter 学习阶段，并能从小型纵向切片逐步掌握。

## 已确认

| 能力 | 选择 | 边界 |
| --- | --- | --- |
| 应用框架 | Flutter + Dart | 独立原生移动客户端，不使用 WebView 承载主界面 |
| UI 底座 | Material 3 | 唯一 UI 底座；使用 Flutter 官方交互、手势、无障碍和平台行为 |
| 产品组件 | Scopify Tokens + Components | 自有视觉与业务组件；不引入 ShadCN、ForUI、Mix 或其他完整 UI Kit |
| 路由 | `go_router` + `go_router_builder` | Typed routes；三个一级 Tab 使用各自保留栈 |
| 状态、响应式缓存与依赖装配 | `flutter_riverpod` 3 | 唯一响应式状态方案；首版不叠加 Bloc、Signals、GetIt 或 TanStack Query 移植 |
| Riverpod 代码生成 | `riverpod_annotation` + `riverpod_generator` | 与 DTO 共用 `build_runner`；Provider 源文件按业务合并，不手写大批 Family 泛型 |
| 普通远程数据 | 薄 API + DTO + Riverpod Provider/Notifier | 继承 Web 已验证的数据分层；页面不直接发请求，普通 API 不增加只转发的 Repository/Adapter |
| HTTP Runtime | `dio` | 唯一 HTTP 客户端；手写薄 API 函数，首版不使用 Retrofit 或 Chopper |
| DTO JSON 序列化 | `json_annotation` + `json_serializable` + `build_runner` | DTO 按业务合并；首版不使用 Freezed 或 dart_mappable |
| 持久查询缓存 | `sqflite` + 单一 `QueryCacheStore` | 一个数据库、一张缓存表；Riverpod 管理状态与失效，业务 Provider 不直接接触 SQL |
| 普通设置 | `shared_preferences` + `SharedPreferencesAsync` | 只保存小型非敏感配置；Riverpod 是运行时响应式状态来源，页面不直接访问存储 |
| 加密凭据 | `flutter_secure_storage` + 单一 `CredentialStore` | 使用 Android Keystore 与 iOS Keychain；网络 Session 不启用生物识别门控 |
| 音频与后台媒体 | `just_audio` + `audio_service` + `audio_session` | 统一封装进单一 Playback Module；播放器插件不拥有产品队列和业务规则 |
| 网络图片 | `cached_network_image` + `flutter_cache_manager` + `ScopifyNetworkImage` | 一个全局缓存实例和一个共享组件入口；页面不散落 `Image.network` |
| 运行时权限 | `permission_handler` + 按业务即时申请 | 不在启动时批量索权；权限用途、拒绝状态和请求时机由对应业务 Module 管理 |
| 动画 | Flutter 内建动画 + `flutter_animate` + `AppMotion` | `flutter_animate` 是唯一第三方动画辅助库；路由、Hero 和复杂控制仍使用 Flutter 原生能力 |
| 国际化 | `flutter_localizations` + `slang` + `slang_flutter` | `slang_build_runner` 生成类型安全 API；按业务 Namespace 使用多语言 Compact CSV |
| 基础测试 | `flutter_test` + `mocktail` + `sqflite_common_ffi` + `alchemist` | Riverpod 使用内建 `ProviderContainer.test()`；Fake 优先，Mock 仅用于平台边界 |

### Material 3 与 Scopify 组件的关系

```text
Flutter Material 3
└─ AppTokens
   └─ components/shared
      └─ 业务 components
         └─ layouts
            └─ pages
```

Material 3 提供基础 Widget 行为，但不决定 Scopify 的最终外观。Drawer、迷你播放器、歌曲列表、完整播放器和乐签等产品界面由 Scopify 自己实现。只有真正跨业务复用的组件进入 `components/shared/`；其余组件留在对应业务目录。

### 普通远程数据流

```text
Page / Layout / Components
          ↓
Riverpod Provider / Notifier
          ↓
Thin API function
          ↓
HTTP runtime
          ↓
Backend
```

- API 函数只描述 endpoint、参数和响应 DTO，不读取页面状态、不发 Toast、不管理缓存。
- DTO 独立于 Widget；Provider/Notifier 负责缓存生命周期、刷新、分页、mutation、失效和页面派生状态。
- Provider Family 的类型化参数承担 Web Query Key 的身份作用。
- Playback、Session、QR Login、Backend Endpoint 和本地听歌识曲等有持续生命周期或平台状态的能力保留为深 Module，再由 Riverpod 暴露。
- 不为普通远程数据叠加只转发同名方法的 Repository、Interface 和 Adapter；测试通过 Provider override、Fake API 或受控 HTTP fixture 完成。

### Dio Runtime 边界

共享 Dio 实例集中处理动态 Backend Endpoint、超时、NetEase Session Credential、公共参数、业务码错误、会话过期、请求追踪、日志脱敏和取消。缓存、页面派生状态、Toast 与 mutation 后的失效不进入 Dio 层；它们属于对应 Riverpod Provider/Notifier。

### DTO 规则

- DTO 只表达后端原始请求/响应结构，不包含缓存、播放或 UI 逻辑。
- 同一业务的相关 DTO 放在一个源文件并生成一份 `.g.dart`，不为每个小型嵌套对象拆文件。
- 不稳定字段使用明确的 `JsonConverter`；页面不得散落动态类型转换。
- 页面异步状态使用 Riverpod `AsyncValue`，需要穷举的本地状态优先使用 Dart 3 `sealed class`。只有大量出现复杂联合类型和 `copyWith` 需求时才重新评估 Freezed。

### Riverpod Provider 生成规则

- 只读数据使用函数式 `@riverpod` Provider；包含 mutation 或用户命令时使用 class-based Notifier。
- Provider 参数承担 Web Query Key 的身份作用，优先使用有含义的类型和命名参数。
- 自动释放保持默认；只有明确需要跨页面保留的数据才使用 `keepAlive` 和统一缓存时效策略。
- 同一业务的 Provider 合并在少量源文件中，不为每个 endpoint 建立一个 Provider 文件。

### 缓存模型与 V1 基线

缓存采用“默认内存、白名单持久化、媒体独立缓存、账号作用域隔离”的原则。Riverpod 管理查询状态、新鲜度、刷新和失效；Dio 不承担业务查询缓存。跨启动持久化只保存明确批准的数据，不把全部 Provider 状态自动写入磁盘。

每个查询缓存键至少包含 Backend Endpoint、账号作用域、数据类型、请求参数和缓存 Schema 版本，避免不同服务端、不同账号或不同参数之间串用数据。退出登录只清除账号作用域缓存；切换 Backend Endpoint 必须切换缓存分区。mutation 成功后主动失效或更新受影响的缓存键。

| 缓存对象 | 存储 | 新鲜期 | 最长保留或容量 | 主要失效规则 |
| --- | --- | ---: | ---: | --- |
| 首页推荐、发现页 | 内存 + 持久查询缓存 | 5 分钟 | 6 小时 | 下拉刷新、账号或 Endpoint 切换 |
| 歌单、专辑、歌手资料 | 内存 + 持久查询缓存 | 30 分钟 | 7 天 | 对象修改后按 ID 失效 |
| 歌单、专辑曲目列表 | 内存 + 持久查询缓存 | 15 分钟 | 24 小时 | 曲目增删或排序后失效 |
| 歌词、翻译歌词 | 内存 + 持久查询缓存 | 24 小时 | 30 天 | 歌曲或歌词版本变化 |
| 搜索联想、搜索结果 | 仅内存 | 1 分钟 / 5 分钟 | 当前 App 进程 | 查询参数变化后自然淘汰 |
| 评论和高频动态列表 | 仅内存 | 1 分钟 | 当前 App 进程 | 发布、删除或互动后失效 |
| 个人资料、收藏、关注、我的歌单 | 内存 + 账号持久查询缓存 | 2 分钟 | 24 小时 | 修改后失效；退出登录清除 |
| 最近播放 | 内存 + 账号持久查询缓存 | 1 分钟 | 6 小时 | 本地立即更新并与服务端校准 |
| 乐签 | 仅内存 | 2 分钟 | 当前 App 进程 | 新增、编辑或删除后更新 |
| GitHub Release 版本信息 | 仅内存 | 30 分钟 | 当前 App 进程 | 手动检查更新时绕过缓存 |
| 封面、头像、背景图 | 独立图片缓存 | 按 URL 与响应头 | V1 建议 256 MB，LRU 淘汰 | URL 或资源版本变化 |
| 音频流临时片段 | 独立临时媒体缓存 | 当前播放期间 | V1 建议 512 MB、最长 24 小时，LRU 淘汰 | 空间不足、地址过期或超时 |
| Android 更新 APK | 临时下载区 | 当前下载流程 | 安装、取消或下次启动前 | 校验完成并结束流程后删除 |

- 数据超过新鲜期后可以先展示旧值并后台刷新；超过最长保留时间后必须重新请求。
- 播放签名 URL、二维码登录状态、二维码图片和听歌识曲原始 PCM 只存在于当前流程内存，不跨启动持久化。
- Cookie、Token 和登录凭据属于安全持久化，不属于缓存；设置和 Backend Endpoint 属于配置持久化，也不属于缓存。
- 离线歌曲是用户可管理的产品资产，不属于临时音频缓存，未来单独设计生命周期与容量规则。
- 逻辑磁盘区域限定为持久查询缓存、图片缓存、音频临时缓存和更新临时下载；不为页面或 endpoint 创建散乱的独立缓存文件。

### 持久查询缓存实现

V1 使用稳定的 `sqflite`，不依赖 Riverpod 3 仍处于实验状态的 offline persistence API，也不为单张可丢弃的缓存表引入 Drift。统一数据库文件为 `scopify_query_cache.db`，由一个共享 `QueryCacheStore` 管理。

`query_cache` 表至少记录 `cache_key`、`endpoint_id`、`account_id`、`scope`、`payload_json`、`fresh_until`、`expires_at`、`last_accessed_at` 和 `schema_version`。业务 Provider 只调用缓存模块提供的读取、写入、删除和按作用域清理能力，不建立按业务拆分的 Repository、DAO 或数据库表。

如果未来开发真正的离线曲库或其他本地业务数据，再单独评估 Drift；不把临时查询缓存扩张为产品数据库。

### 普通设置存储

主题、语言、Backend Endpoint、音质、播放偏好、动画与界面偏好、缓存容量配置和引导完成状态使用 `shared_preferences` 的 `SharedPreferencesAsync` API。启动阶段先加载设置，再创建依赖这些设置的主题、Dio 和路由状态，避免启动后出现主题闪烁或请求发往错误 Endpoint。

Riverpod Provider/Notifier 是运行期间唯一的响应式设置来源，Widget 不直接调用 `shared_preferences`。不使用旧版 `SharedPreferences`，也不叠加 `SharedPreferencesWithCache` 的进程内缓存；Riverpod 已承担内存状态，多 Isolate 或后台 Engine 场景通过异步 API 读取平台侧最新值。

登录凭据、API 查询结果、业务内容和大型 JSON 不得进入普通设置存储。

### 加密凭据存储

网易云 Session Cookie、未来可能出现的 Access/Refresh Token、凭据 Schema 版本和凭据所属 Backend Endpoint 标识统一通过一个 `CredentialStore` 写入 `flutter_secure_storage`。Session Module 是凭据生命周期的所有者，Widget、普通业务 Provider、薄 API 和 Dio 拦截器不得各自直接操作安全存储。

退出登录时删除安全凭据，并清理相同账号作用域的持久查询缓存。普通设置、API 查询结果、用户资料和业务内容不得进入安全存储。

V1 不为网络凭据启用指纹、Face ID 或设备密码门控，避免启动恢复、后台播放和静默 Session 刷新被交互式验证阻断。未来如增加生物识别，应作为可选的 App UI 隐私锁，只在冷启动或离开一段时间后恢复前台时触发，不阻断后台媒体与网络 Session。

### 音频、后台播放与系统媒体会话

- `just_audio` 是唯一音频播放引擎，负责 URL/文件音源、缓冲、进度、Seek 和底层播放状态。
- `audio_service` 提供 AudioHandler、后台播放、通知栏、锁屏、耳机按钮以及 Android Auto/Apple CarPlay 的系统媒体入口。
- `audio_session` 统一管理 Android Audio Focus、iOS Audio Session、电话等音频打断和耳机拔出事件。

三者统一封装进 Playback Module。完整产品队列、当前歌曲、随机历史、循环规则、音质切换、限时播放 URL 获取与刷新、连续失败跳过和恢复策略由 Playback Module 持有；Riverpod 只暴露响应式快照与用户命令，Widget 不直接控制 `AudioPlayer` 或 `AudioHandler`。

不使用面向简单播放器的 `just_audio_background`，也不为当前纯音乐移动端引入以广泛视频/编解码支持为主的 `media_kit`。网易云播放 URL 不进入跨启动状态；恢复播放前必须重新获取有效 URL。

### 网络图片与磁盘缓存

封面、头像和背景图统一通过 `components/shared/ScopifyNetworkImage` 加载。该组件封装 `cached_network_image` 的 Widget/ImageProvider 入口以及 Scopify 的圆角、占位、错误状态和淡入表现；业务页面不得各自散落 `Image.network` 和缓存配置。

`flutter_cache_manager` 提供唯一全局图片缓存实例，文件进入系统 Cache 目录，由 HTTP Cache-Control/ETag、最长未使用时间和最大对象数量共同控制清理。缓存是可重建数据，操作系统随时删除它都不能影响业务正确性。

V1 图片规格为头像最大 256 px、列表与网格封面最大 512 px、详情页和播放器背景最大 1080 px；组件必须向解码器传递合适的内存/磁盘目标尺寸，避免将超大原图完整解码进列表内存。

256 MB 是图片缓存的目标容量，而不是 `flutter_cache_manager` 原生保证的硬字节上限。V1 先通过最长未使用时间和最大对象数量控制；实现存储设置页时根据真实封面大小验证是否值得增加精确字节统计与清理，不提前自建另一套图片缓存器。

### 权限策略

V1 使用 `permission_handler` 统一跨平台权限 API，但不建立收纳所有业务决策的全局权限中心。权限归实际使用它的深 Module 管理：Recognition Module 管理麦克风，Update Module 管理 Android APK 安装授权，Playback Module 管理媒体服务声明与状态。

- 听歌识曲只在用户点击开始识曲并看到用途说明后请求麦克风权限；拒绝后允许重试，永久拒绝时提供前往系统设置入口。
- 后台播放在 Android Manifest 声明前台媒体服务及 `FOREGROUND_SERVICE_MEDIA_PLAYBACK`，不向用户弹出运行时授权。
- Android 媒体会话通知不为了播放而主动请求普通通知权限；未来增加非媒体通知时再按对应功能请求。
- 图片、音频缓存和 APK 下载都使用 App 私有目录，不请求外部存储权限。只有用户点击安装 APK 时才引导其授权“安装未知应用”。
- V1 不读取本地曲库，因此不声明照片、视频或媒体库读取权限。

不引入附带 Riverpod、ScreenUtil 或现成弹窗 UI 的二次权限封装。系统权限调用由 `permission_handler` 完成，Scopify 自己的解释、拒绝与设置引导界面使用产品组件实现。

### 动画

V1 使用 Flutter 内建动画能力和唯一第三方辅助库 `flutter_animate`。简单的 Fade、Slide、Scale、Shimmer、顺序入场与轻量循环使用 `flutter_animate` 减少样板代码；Hero、`go_router` 页面 Transition 和需要精确生命周期控制的复杂动画继续使用 Flutter 原生 API。

所有时长、曲线和减弱动画规则由统一 `AppMotion` Tokens 提供，页面不得散落魔法时长和任意曲线。动画必须响应系统减少动态效果设置：移动与缩放可降级为淡入淡出，连续装饰动画停止或静态化，功能正确性不得依赖动画完成回调。

不再引入功能重叠的 `animations` 包。V1 不引入 Lottie 或 Rive；只有未来出现明确的对应设计资产与交互需求时再评估。

### 国际化

V1 支持 `zh-CN`、`zh-TW` 和 `en-US`，与 Web 已有语言保持一致。Flutter/Material/Cupertino 自带控件由 SDK 的 `flutter_localizations` 本地化，产品文案使用 `slang` 与 `slang_flutter`；`slang_build_runner` 复用项目已有 `build_runner` 生成类型安全访问 API。

翻译资源按业务 Namespace 拆分，每个业务使用一份 Compact CSV 横向保存全部语言，例如 `home.i18n.csv` 同时包含 `zh-CN`、`zh-TW` 和 `en-US`，而不是每个业务再创建三份语言文件。调用使用 `context.t.home.dailyRecommendations` 等生成 API，不在 Widget 中散落字符串 Key。

Mobile 初始词条从 Web 已有的 `common`、`home`、`playlist`、`profile`、`settings` 等业务消息迁移，并将 `{{name}}` 等模板参数转换为 Slang 的类型化参数。日期、数字和复数使用国际化格式化能力，不在页面中手拼语言差异。

当前 Locale 与用户覆盖选择属于普通设置，由 Settings Provider 和 `SharedPreferencesAsync` 持久化；翻译库不再维护第二份设置状态。V1 不使用 `easy_localization`，也不叠加另一套 ARB/gen_l10n 产品文案生成流程。

### 基础测试

- `flutter_test` 承担纯逻辑、Widget 交互和基础 Golden 测试运行。
- Riverpod 3 使用内建 `ProviderContainer.test()`、Provider override 和内存依赖，不引入 `riverpod_test`。
- `mocktail` 仅用于难以用小型 Fake 表达的平台边界，例如 Dio Adapter、音频引擎、权限和安全存储；不使用需要生成 Mock 文件的 Mockito。
- `sqflite_common_ffi` 在开发机与 CI 提供真实的内存 SQLite，用于验证 `QueryCacheStore` 的键、TTL、作用域清理和 Schema 行为，不用 Mock SQL 来证明 SQL 正确。
- `alchemist` 组织共享组件与页面的 Golden 场景，至少覆盖浅色/深色、三种 Locale、普通/大字号以及 Loading/Empty/Error 等关键状态。

播放队列、随机历史、循环规则、URL 过期与失败恢复优先写纯逻辑测试；Provider 测试覆盖异步状态、刷新、mutation 失效和 Session 清理；Widget 与 Golden 测试验证 Drawer、Modal、路由入口和线稿视觉。测试文件按对应业务组织，不建立一个收纳全部 Fixture 和 Mock 的巨大测试工具目录。

### 当前验证阶段

第一阶段以 Windows 上的 Android Emulator 跑通完整纵向切片为目标，不引入 Patrol、`patrol_cli` 或额外原生测试 Runner。自动化重点放在运行快速的单元、Provider、Widget 和 Golden 测试；启动、路由、登录、播放、Drawer、Modal 和听歌识曲权限先在模拟器中完成手工 Smoke Test。

首个纵向切片稳定后，可以用 Flutter SDK 的 `integration_test` 固化少量纯 App 主流程。需要自动操作系统权限弹窗、通知栏、锁屏媒体控制和安装授权时，再评估 Patrol 与真机 E2E；该延后不影响 Playback、Permission 等 Module 保持可测试边界。

## 延后确认

- Patrol 与真机 E2E 测试方案；等待 Android Emulator 主流程稳定后再决定。
