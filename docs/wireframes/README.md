# Mobile design prototypes

本目录保留两个互不覆盖的设计版本：

- [`mobile-wireframe-prototype.html`](./mobile-wireframe-prototype.html)：首轮低保真线稿与完整状态清单，冻结保留。
- [`mobile-visual-prototype-v2.html`](./mobile-visual-prototype-v2.html)：M3b 跨端视觉原型 V2；48 张画板的完整静态视觉稿。

V2 以 Git commit `3f48c849b525d2dab3595d1f4da8d3a36ad3e9ec` 时的 Web Scopify theme 与已落地组件为视觉真源，使用同一套深色表面、绿色状态色、圆角、媒体处理和信息密度。它覆盖 V1 的全部 33 张页面/状态，并补充启动门、二维码状态、资料编辑、游客操作门、创建歌单、拆分设置页和 Web 首页八时段主题。V2 的媒体素材保存在 `assets/v2/`，运行时不发起外部图片请求。

V2 是静态、只读的设计画廊，不执行登录、关注、评论、播放或设置保存。设备外壳为中性 Android，主画板采用 360 × 800 逻辑尺寸。

V2 的通用功能图标由工作区现有 `lucide-react 1.26.0` 生成，统一采用 Lucide 默认 24 × 24 网格和 2px 描边；Flutter 实现时映射到同名 Lucide Flutter 图标。许可保存在 `assets/v2/LUCIDE-LICENSE.txt`。

视觉精修按每批 6 张评审。第一批入口为 `?screen=review-one`，包含启动门、二维码状态、搜索发现、游客“我的”、我的播客和我的收藏；第二批入口为 `?screen=review-two`，包含登录/游客 Drawer、VIP 签到、睡眠定时、听歌识曲和检查更新。

## V1 低保真线稿

`mobile-wireframe-prototype.html` 是 Scopify Mobile 首轮页面阅览稿。

- **PROTOTYPE — throwaway/read-only**：只回答“页面和导航关系是否成立”。
- 不发网络请求，不保存数据，不执行喜欢、收藏、评论、删除或编辑。
- 页面中的内容都是固定 fixture，不应复制为生产数据模型。
- Flutter 实现应依据 [页面规格](../mobile-pages.md)，而不是直接翻译 HTML/CSS。
- 设备外壳使用 [picturepan2/devices.css](https://github.com/picturepan2/devices.css) v0.2.0 的 iPhone 14 Pro 样式（MIT）。页面通过 jsDelivr 加载固定版本，同时保留本地 CSS fallback，断网时仍可阅览。

## 预览

在 `frontend/apps/mobile` 下运行：

```powershell
python -m http.server 8000 --directory docs/wireframes
```

然后打开：

```text
http://localhost:8000/mobile-wireframe-prototype.html
http://localhost:8000/mobile-visual-prototype-v2.html
```

V2 支持页面名或分组形式的 `?screen=` 深链：

```text
http://localhost:8000/mobile-visual-prototype-v2.html?screen=home
http://localhost:8000/mobile-visual-prototype-v2.html?screen=search-results
http://localhost:8000/mobile-visual-prototype-v2.html?screen=my-music
http://localhost:8000/mobile-visual-prototype-v2.html?screen=playlist
http://localhost:8000/mobile-visual-prototype-v2.html?screen=player-disc
http://localhost:8000/mobile-visual-prototype-v2.html?screen=login
http://localhost:8000/mobile-visual-prototype-v2.html?screen=drawer
http://localhost:8000/mobile-visual-prototype-v2.html?screen=profile
http://localhost:8000/mobile-visual-prototype-v2.html?screen=settings
http://localhost:8000/mobile-visual-prototype-v2.html?screen=states
```

首页会根据本地小时自动选择与 Web 相同的八段氛围背景，也可以用 `?time=` 固定评审：

```text
night       00:00–04:59  #312e81 / 90%
dawn        05:00–06:59  #fda4af / 45% → #fb923c / 30%
morning     07:00–09:59  #7dd3fc / 60%
afternoon   10:00–13:59  #0ea5e9 / 65%
daylight    14:00–16:59  #22d3ee / 60%
sunset      17:00–18:59  #fb923c / 45% → #7e22ce / 30%
evening     19:00–21:59  #7e22ce / 80%
late-night  22:00–23:59  #0f172a / 90%
```

例如：

```text
http://localhost:8000/mobile-visual-prototype-v2.html?screen=home&time=sunset
http://localhost:8000/mobile-visual-prototype-v2.html?screen=time-themes
```

顶部筛选器可以只看某一页，URL 会保留 `?screen=` 参数。例如：

```text
http://localhost:8000/mobile-wireframe-prototype.html?screen=player
```

本轮新增的 Drawer / Profile 评审入口：

```text
http://localhost:8000/mobile-wireframe-prototype.html?screen=drawer
http://localhost:8000/mobile-wireframe-prototype.html?screen=drawer-song-recognition
http://localhost:8000/mobile-wireframe-prototype.html?screen=drawer-check-update
http://localhost:8000/mobile-wireframe-prototype.html?screen=profile
http://localhost:8000/mobile-wireframe-prototype.html?screen=recent
```

对应页面编号：

- `DRAWER-01A`：登录态 App Drawer。
- `DRAWER-01B`：游客锁定状态 App Drawer。
- `VIP-01`：Drawer 收起后的网易乐签 Modal，排版直接适配 Web `VipSignModal`。
- `SLEEP-01`：Drawer / 播放器共用的睡眠定时 Modal。
- `MATCH-01`：Drawer 收起后的听歌识曲 Modal；本地生成声纹，不上传原始录音。
- `UPDATE-01`：基于 GitHub Releases 的 Android 检查更新 Modal（功能实现后置）。
- `RECENT-01`：Drawer / My 共用、复用歌单结构的最近歌曲页面。
- `PROFILE-01A`：本人资料。
- `PROFILE-01B`：他人资料与真实关注入口。

直接双击 HTML 也能浏览，但本地 HTTP 预览更接近后续自动化截图环境。
