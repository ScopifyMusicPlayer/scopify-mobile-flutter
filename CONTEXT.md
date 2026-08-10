# Scopify Mobile Context

Scopify Mobile is a standalone client in the Scopify family that provides music playback and user interactions on mobile devices.

## Client Boundaries

**Standalone Mobile Client**:
A Scopify client that people can use independently on a mobile device. It shares the backend with the Web and Electron clients but owns its interface, client state, platform integrations, and release lifecycle.
_Avoid_: companion app, remote controller, Web wrapper

**Mobile Backend Endpoint**:
The Shared Backend address used by the Standalone Mobile Client. It ships with a default value but remains editable in ordinary Network settings, with connection testing and default restoration available to self-hosting users.
_Avoid_: hard-coded backend, developer-only override, hidden server address

**Mobile Backend Transport Policy**:
Public Mobile Backend Endpoints require HTTPS. HTTP is accepted only for localhost and private-network endpoints used for local development or self-hosting, with the insecure transport made explicit to the user.
_Avoid_: public HTTP backend, silent cleartext fallback, HTTPS-only local development

## Authentication

**Mobile QR Login**:
The Standalone Mobile Client's only authentication flow. It establishes a device-local NetEase Session Credential after a backend-issued QR code is scanned and confirmed; it offers no phone, password, or credential-import alternative.
_Avoid_: phone login, password login, shared client session

**Mobile Guest Session**:
The unauthenticated Standalone Mobile Client mode that permits Home, Search, and public playback. My Hub and account mutations such as collecting, commenting, or editing require Mobile QR Login.
_Avoid_: mandatory startup login, anonymous account mutation, empty logged-out app

**QR Handoff**:
The user-controlled transfer of a Mobile QR Login QR image into a separate scanning context, such as an image or screenshot. It makes QR-only login practical without adding another identity flow.
_Avoid_: credential transfer, alternate login method

## Information Architecture

**Mobile Primary Navigation**:
The fixed three-item bottom navigation of the Standalone Mobile Client: Home, Search, and My. It is the complete first-release top-level navigation.
_Avoid_: separate Library tab, desktop sidebar navigation

**Mobile App Drawer**:
An App Shell overlay opened from a primary page's menu button or its permitted edge gesture. It exposes account identity and low-frequency global tools without replacing Mobile Primary Navigation or appearing on detail, immersive, or blocking surfaces.
_Avoid_: persistent sidebar, fourth primary tab, detail-page menu

**My Hub**:
The My primary destination, organized around the signed-in user's profile and personal content. It allocates existing user-facing capabilities through internal sections instead of adding bottom-navigation items.
_Avoid_: library-only tab, settings-only page, desktop profile route

**My Section Switcher**:
The internal tab control in My Hub with exactly three first-release sections: Music, Podcasts, and Favorites. Switching sections does not leave My or change the Mobile Primary Navigation selection.
_Avoid_: bottom-navigation expansion, a separate primary destination

**My Favorites Section**:
The My Hub section containing followed artists and collected albums only. Collected playlists belong to My Music rather than Favorites.
_Avoid_: all saved content, collected playlists, liked songs

**My Music Section**:
The My Hub section containing the user's personal music and playlists, including collected playlists.
_Avoid_: followed artists, collected albums, podcast subscriptions

## Playback

**Background Mobile Playback**:
The Standalone Mobile Client's continuous playback capability while it is not foregrounded, with platform lock-screen and notification media controls reflecting and commanding its device-local queue. It is core behavior, not a foreground-only enhancement.
_Avoid_: foreground-only playback, remote Web player

**Android-First Release**:
The first public Standalone Mobile Client release targets Android only. iOS follows after the Android core experience is stable and is not a first-release parity commitment.
_Avoid_: simultaneous platform launch, iOS parity promise

**Streaming-Only Playback**:
The Standalone Mobile Client plays music from an online stream and provides no user-managed offline tracks. Transient transport buffering and expiring playback-URL caches are not offline downloads.
_Avoid_: download library, offline mode, persistent music files

**Mobile Now Playing Screen**:
The Standalone Mobile Client's native full-screen playback surface, providing track information, transport controls, queue access, and synchronized lyrics. It is the first-release playback presentation and does not embed the Web renderer.
_Avoid_: WebView player, Folia Playback Stage, foreground-only player

**Mobile Song Comments**:
The first-release song-comment surface opened from Mobile Now Playing. Guests may read hot and paginated comments; authenticated users may like, publish, reply, and delete their own comments with behavior matching the Web client.
_Avoid_: read-only comments, separate mobile comment model, guest mutations

**Mobile Folia Parity**:
A future scope for bringing the complete Folia Playback Stage to the Standalone Mobile Client. It is outside the first release, and a reduced set of visualizers is not described as parity.
_Avoid_: first-release requirement, simplified Folia mode, partial parity

## UI & Interaction Terms / 界面与交互词汇

| 术语 | 含义 |
| --- | --- |
| App Shell | 承载一级导航、迷你播放器与跨页面反馈的移动端应用骨架；迷你播放器与底部导航为独立组件。 |
| 全局 Toast | 由 App Shell 在安全区顶部展示的短暂、非阻断性结果反馈；它不属于任何具体页面或播放器视图，但可携带有限的恢复动作。 |
| 迷你播放条 | 独立悬浮在底部导航上方的当前播放入口；它可单独出现或收起，不是底部导航的一部分。 |
| 局部状态 | 必须在触发位置持续可见、可恢复或可操作的状态，例如二维码加载、已扫码与过期。它不使用全局 Toast 取代。 |
| 播放失败通知 | 音频无法播放时给出的结果反馈。它保留全屏播放上下文，并作为顶部全局 Toast 告知自动跳过或停止；停止态可提供重试与下一首动作。 |
| 播放器中心模式 | 完整播放页中仅决定中心内容的状态：CD 或同步歌词。它不改变顶部、共享控制区、播放上下文或 route。 |
| Folia 式双行歌词 | V1 同步歌词的固定排版：原文为主行，翻译紧贴下方并弱化；没有翻译时收拢为单行，不提供罗马音或语言切换。 |
| 评论上滑入口 | 完整播放页最底部专属的向上手势槽，用于进入歌曲评论；它不与进度、播放控制或队列操作共用手势。 |
