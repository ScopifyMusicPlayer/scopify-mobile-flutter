# Scopify Web 设计语言提取

> 目的：从 `frontend/apps/web` 的当前实现中提取可迁移到 Flutter 的视觉规则。这里继承的是视觉语言，不是桌面布局、Tailwind 类名或 React 组件结构。

## 1. 结论

Scopify 的核心风格可以概括为：**深色音乐画布、图片主导、Spotify 绿承担唯一主动作、弱边框分层、紧凑列表与宽松 Hero 并存、动效只强化可操作性。**

它不是通用 ShadCN 深色主题。Web 虽然保留了 ShadCN 的 CSS 变量，但真实页面大量稳定使用 `#121212`、`#181818`、`#282828`、`#1ED760`、`#B3B3B3` 和白色透明层；移动端应从这些实际用法建立语义 token，而不是直接复制 `--primary` 等默认变量。[全局变量](<../../web/app/globals.css#L21>)、[主布局](<../../web/components/MainLayout.tsx#L268>)

## 2. 审计方法与可信度

审计范围：`apps/web/app`、`apps/web/components`、全局样式和首页时间主题。完整 Folia 视觉器目录被排除，因为它是独立舞台系统，不能代表普通 App 页面。

颜色字面量扫描结果如下。计数只是代码出现次数，不等同于屏幕面积，但足以辨认稳定设计指纹：

| 颜色 | 出现次数 | 设计含义 |
| --- | ---: | --- |
| `#1ED760` | 119 | 主动作、播放、选中状态 |
| `#121212` | 65 | 页面与主面板基底 |
| `#B3B3B3` | 53 | 次级文字与播放器控制 |
| `#282828` | 50 | 悬浮/抬升面、模态面板 |
| `#1DB954` | 37 | 旧版绿色写法，应归并 |
| `#181818` | 20 | 媒体卡片默认面 |

可复核命令：

```powershell
rg -o --no-filename '#[0-9A-Fa-f]{3,8}' app components --glob '*.tsx' --glob '*.css' --glob '!components/lyrics/folia/**'
```

结论分三档：

- **核心规则**：跨页面、跨组件高频重复，必须进入 Flutter token。
- **页面表达**：Hero、时间渐变、图片遮罩等按页面使用，不做全局默认。
- **例外颜色**：日历红、VIP 金、成功绿、警告橙和错误红只服务对应语义，不能扩散成品牌色。

## 3. 设计原则

### 3.1 视觉语言继承，几何结构重做

移动端继承颜色、层级、字体性格、图片处理、动作主次与动效节奏；桌面侧栏、可调整双栏、64px 顶部导航、底部桌面播放条和 hover-only 操作不迁移。Web 主壳本身是黑色 8px 沟槽、`#0F0F0F` 侧栏与 `#121212` 主面板的桌面组合，这是平台结构而不是品牌规则。[MainLayout](<../../web/components/MainLayout.tsx#L268>)

### 3.2 一屏只有一个视觉主角

- 首页以时段渐变和内容封面为主角。
- 详情页以封面、歌手大图或专辑色为主角。
- 播放页以沉浸背景、唱片或歌词为主角。
- Spotify 绿只标记主播放、确认或明确选中态，不能铺成大面积背景。

Web 的歌手 Hero 使用图片全铺并向 `#121212` 渐隐，标题使用超粗大字；歌单和专辑则用大封面、深阴影、标签与元数据建立层级。[ArtistHero](<../../web/components/artist/ArtistHero.tsx#L19>)、[PlaylistHeader](<../../web/components/Playlist/Header.tsx#L44>)、[AlbumHeader](<../../web/components/album/AlbumHeader.tsx#L16>)

### 3.3 通过明度和透明度分层，少用实体边框

普通卡片使用 `#181818`，悬浮/强调时进入 `#282828`；轻交互使用 `white/5`、`white/10`、`white/20`。边框主要出现在输入、确认、模态和需要明确边界的胶囊上。媒体列表默认透明，只在 hover/pressed 时出现白色透明底。[GridCard](<../../web/components/home/GridCard.tsx#L35>)、[SongRow](<../../web/components/SearchContents/SongRow.tsx#L37>)、[SettingsUI](<../../web/components/settings/SettingsUI.tsx#L10>)

### 3.4 动作主次必须一眼成立

详情页主播放是 56px 绿色圆形；随机、收藏、下载/更多等次级动作是 32px 左右的中性图标，启用状态变绿并带小状态点。关注/订阅使用描边胶囊。移动端继续沿用这套层级，但不复制 V1 不支持的下载动作。[PlaylistActions](<../../web/components/Playlist/ActionStation.tsx#L139>)、[AlbumActions](<../../web/components/album/AlbumActions.tsx#L35>)、[ArtistActionBar](<../../web/components/artist/ActionBar.tsx#L61>)

## 4. Flutter 语义颜色

首轮只建立以下稳定 token；页面临时颜色不得直接进入 `AppTokens`。

| Flutter token | 值 | 用途 |
| --- | --- | --- |
| `canvas` | `#000000` | App 最外层、沉浸层基底 |
| `surfaceBase` | `#121212` | 一级页面、主内容面 |
| `surfaceDeep` | `#0F0F0F` | 更深的导航/分组面 |
| `surfaceCard` | `#181818` | 有实体感的媒体卡片 |
| `surfaceRaised` | `#282828` | 模态、悬浮、抬升态 |
| `surfaceSoft` | `rgba(255,255,255,0.05)` | 轻分组、pressed 背景 |
| `surfaceInteractive` | `rgba(255,255,255,0.10)` | 快捷行、选项、列表反馈 |
| `textPrimary` | `#FFFFFF` | 标题与核心内容 |
| `textSecondary` | `#B3B3B3` | 副标题、歌手、控制图标 |
| `textTertiary` | `#727272` | 时间、说明、禁用前状态 |
| `accent` | `#1ED760` | 主播放、确认、当前状态 |
| `accentHover` | `#3BE477` | Web hover 参考；移动端用于轻反馈 |
| `divider` | `rgba(255,255,255,0.10)` | 必要分隔线 |
| `overlay` | `rgba(0,0,0,0.72)` | 模态与沉浸可读性遮罩 |

`#1DB954`、`#1ED760`、`#1FDF64` 和 `#3BE477` 在 Web 中并存。移动端不应复制这种历史差异：以 `#1ED760` 为唯一基础绿，其余只通过状态 token 派生。

## 5. 字体与信息层级

Web 全局字体为 Arial，加 Microsoft YaHei、PingFang SC、Segoe UI 回退；整体特征是中性、紧凑、粗标题和高可读数字。[globals.css](<../../web/app/globals.css#L21>)

移动端建议建立以下语义层级：

| Token | 建议规格 | 场景 |
| --- | --- | --- |
| `display` | 30–34 / 800–900 / 紧字距 | 首页欢迎、资料名、详情标题 |
| `titleLarge` | 24–28 / 750–800 | 页面标题 |
| `title` | 20–22 / 700 | 区块标题 |
| `bodyStrong` | 15–16 / 600–700 | 歌名、卡片标题、主标签 |
| `body` | 14–15 / 400–500 | 正文与设置项 |
| `label` | 12–13 / 500–650 | 元数据、胶囊、Tab |
| `micro` | 10–11 / 500 | 时间、音质、弱状态 |

Web Hero 会使用 48–96px 超大标题，首页标题使用 24–30px。这种比例关系要保留，但数值必须按手机宽度重排，不能原样搬运。[ArtistHero](<../../web/components/artist/ArtistHero.tsx#L27>)、[HomePage](<../../web/app/(dashboard)/page.tsx#L56>)

规则：

- 标题优先粗体与紧字距，不用装饰字体。
- 正文最多三级明度，避免同一层级出现多个灰色。
- 时间、时长与播放数字使用等宽数字。
- VIP、状态与上层分类可以使用极小标签，但不能代替清晰标题。

## 6. 间距、圆角与阴影

Web 的基本节奏来自 8px 网格：页面常用 24/32px 内边距，区块间距约 32px，卡片内部 16px，列表行约 8–12px。移动端压缩为 16px 页面边距，并继续使用 4/8/12/16/24/32 的离散序列。

圆角统计中 `rounded-full`、`rounded-md`、`rounded-xl` 和 `rounded-lg` 占绝大多数；全局基础半径为 10px。[globals.css](<../../web/app/globals.css#L23>)

| Token | 建议值 | 场景 |
| --- | ---: | --- |
| `radiusSm` | 4px | 徽标、进度、小封面 |
| `radiusMd` | 8px | 列表行、输入、普通封面 |
| `radiusLg` | 12px | 卡片、对话框、内容面板 |
| `radiusXl` | 16px | 登录容器、底部 Sheet |
| `radiusPill` | 999px | Tab、状态、主按钮 |

阴影只给封面、主播放、浮层和模态。普通内容面靠明度分层，不给每个卡片都加阴影。Web 封面常用深黑大阴影，绿色播放按钮使用较小的抬升阴影。[PlaylistHeader](<../../web/components/Playlist/Header.tsx#L44>)、[GridCard](<../../web/components/home/GridCard.tsx#L56>)

## 7. 核心组件配方

### 7.1 主播放与确认按钮

- 圆形播放：52–56px、`accent` 背景、黑色实心播放图标、轻阴影。
- 长主按钮：48px 高、胶囊形、绿色底、黑色粗体文字。
- 播放器中央播放例外：使用白色圆形按钮，因为它处于沉浸控制组内，绿色留给随机/喜欢等状态。[PlayerBar](<../../web/components/PlayerBar.tsx#L385>)

### 7.2 次级图标

- 24–32px 视觉尺寸，至少 44–48px 点击区域。
- 默认 `textSecondary`，active 变 `accent`，危险操作单独使用 danger 色。
- 图标使用一致的圆润描边家族；只在播放、暂停、喜欢已选等状态使用填充。
- 不在沉浸播放器底部给每个图标都加文字，避免抢夺唱片和歌词焦点。

### 7.3 媒体卡片

- 专辑/歌单封面方形、歌手头像圆形。
- 实体卡片：`surfaceCard` + 16px 内边距；交互态 `surfaceRaised`。
- 轻卡片：透明底，只在 pressed 时显示 `surfaceSoft`。
- 标题一行，副标题最多两行；封面始终比文字更醒目。
- Web 的绿色播放按钮依赖 hover 出现；移动端的关键播放动作必须常驻或由明确的详情入口承载，不能照搬 hover-only。[GridCard](<../../web/components/home/GridCard.tsx#L35>)、[LibraryMediaGrid](<../../web/components/library/LibraryMediaGrid.tsx#L42>)

### 7.4 列表行

- 默认无边框或极弱分隔。
- pressed 使用 `white/5`，选中/正在播放的标题使用 `accent`。
- 标题白色，歌手/专辑 `textSecondary`，时长 `textTertiary`。
- 更多、喜欢等低频动作靠右，不能挤压主标题。[SongRow](<../../web/components/SearchContents/SongRow.tsx#L37>)、[TrackRow](<../../web/components/Playlist/TrackRow.tsx#L86>)

### 7.5 Chip、Tab 与状态

- 使用胶囊或小圆角，背景 `white/5–10`，必要时加 `white/10` 边框。
- active 通过更高明度、白色文字或绿色状态表达，不同时堆叠描边、阴影和大色块。
- 标签字号 11–13px，文字短而明确。

### 7.6 输入与设置

- 输入默认透明，边框 `#727272`，聚焦变白。
- 设置行保持“标题 + 说明 + 控件”三段层级，区块标题使用小号大写/宽字距。
- 保存作为底部居中绿色胶囊；确认模态使用黑色遮罩、`#282828` 面板、绿色主动作与透明描边次动作。[SettingsPage](<../../web/components/settings/SettingsPage.tsx#L39>)、[SettingsUI](<../../web/components/settings/SettingsUI.tsx#L241>)

### 7.7 异常、空态与骨架

- 空态是无实体卡片的居中标题 + 说明。
- 页面/区块错误保持上下文，只给一个清晰绿色恢复动作。
- 骨架匹配真实几何，使用约 `white/10` 的脉冲面；减少动态效果时静止。[LibraryEmptyState](<../../web/components/library/LibraryEmptyState.tsx#L7>)、[NetworkRetryState](<../../web/components/shared/NetworkRetryState.tsx#L17>)、[Skeleton](<../../web/components/ui/skeleton.tsx#L7>)

### 7.8 Toast 与模态

- Toast 固定安全区顶部、默认约 3 秒；这与移动端已确认的全局 Toast Host 一致。[RootLayout](<../../web/app/layout.tsx#L45>)
- 普通模态使用 50–80% 黑色遮罩、轻 blur、12px 左右圆角、弱边框和 200ms 淡入/缩放。[AlertDialog](<../../web/components/ui/alert-dialog.tsx#L30>)、[SettingsConfirm](<../../web/components/settings/SettingsUI.tsx#L276>)

## 8. 页面构图映射

| 移动页面 | 继承的 Web 风格 | 不迁移的桌面结构 |
| --- | --- | --- |
| 首页 | 时段渐变、白色透明快捷行、封面驱动卡片、粗区块标题 | 多列大网格、hover 才出现的播放 |
| 搜索 | 深色画布、强搜索入口、分类内容靠封面区分、紧凑结果行 | 桌面顶栏内的小搜索框、宽表格 |
| 我的 | Hero 向 `#121212` 渐隐、头像/昵称强层级、内容面板弱分隔 | 桌面资料页横排和超大 96px 标题 |
| 歌单/专辑/歌手 | 图片 Hero、深阴影封面、绿色 Action Station、透明曲目行 | 桌面多列元数据和 sticky 宽操作条 |
| 播客 | 与音乐共用色彩和卡片语言，但保留 Radio/Voice 类型差异 | 桌面列表/网格切换器 |
| 播放器 | 封面背景、中央主视觉、白色主播放、绿色状态、低对比底部工具 | 实体纯黑桌面 PlayerBar、横向三栏控制 |
| 登录 | 黑色画布、窄内容列、半透明容器、弱边框 | 多登录方式 Tab；移动端只保留二维码 |
| 设置 | `#121212` 页面、透明输入、细边框、绿色保存/恢复按钮 | 横向设置 Tab 和双栏表单 |

首页的时间主题不是随机渐变：八个时段都向 `#121212` 收口，因此移动端可以保留时间感，但必须让内容面稳定回到统一基底。[TIME_THEMES](<../../web/hooks/home/useHomeData.ts#L35>)

## 9. 动效节奏

| 类型 | Web 证据 | 移动规则 |
| --- | --- | --- |
| 颜色/透明度 | 200–300ms transition | 150–250ms |
| 播放按钮出现 | 300ms 上移 + 淡入 | 不依赖出现；pressed 轻缩放 |
| 图片 hover | 300–500ms scale 1.05 | 仅详情转场或轻微视差，默认静止 |
| 按钮反馈 | hover 1.05 / active 0.95 | pressed 0.97–0.99，避免过弹 |
| 模态 | 200ms fade/zoom；部分 400ms slide | Sheet 250–350ms，Dialog 180–240ms |

全局 CSS 已有 200ms view fade、300/400ms modal 动画；Header 的滚动磨砂层使用 300ms 透明度变化。[globals.css](<../../web/app/globals.css#L302>)、[Header](<../../web/components/Header.tsx#L27>)

所有动效必须尊重“减少动态效果”。动画用于说明层级和状态，不能延迟内容或遮掩布局跳动。

## 10. 不应复制到移动端的内容

- 桌面侧栏、可调整面板、窗口外黑色沟槽。
- hover 才可发现的关键动作。
- ShadCN light/dark 默认 token 作为品牌色来源。
- `#1DB954`、`#1ED760` 等重复硬编码继续扩散。
- 每个区块都做成卡片、强边框或玻璃面板。
- 完整播放器底部再铺一块抢眼的纯黑工具栏。
- 桌面表格的所有列、横向设置 Tab、下载等 V1 不支持的动作。
- Folia 的完整视觉器、调参面板和桌面歌词窗；V1 只采用已确认的原文 + 翻译歌词表达。

## 11. Flutter 落地边界

设计语言由 `lib/app/theme/` 统一拥有：

```text
lib/app/theme/
├─ app_tokens.dart   # 颜色、间距、圆角、阴影、时长
└─ app_theme.dart    # ColorScheme、TextTheme、组件主题
```

首批跨页面组件建议放在 `lib/shared/widgets/`：

```text
ScopifyPlayButton
ScopifyPillButton
ScopifyIconAction
MediaArtwork
MediaCard
MediaListTile
SectionHeader
ScopifyChip
ScopifySkeleton
ScopifyEmptyState
ScopifyErrorState
```

页面可以组合这些组件，但不能在 feature 内重新声明绿色、主背景、圆角或文字灰度。图片提色、首页时段渐变和播放器背景属于 feature policy，只消费主题 token，不反向污染全局主题。

## 12. 第一轮视觉验收

完成 Flutter 灰阶布局后，按以下顺序精修：

1. 建立颜色、字体、间距、圆角和动效 token。
2. 先统一主按钮、卡片、列表行、Chip、Toast、模态和骨架。
3. 再应用首页时段渐变、详情 Hero 和播放器沉浸背景。
4. 最后做 pressed、滚动磨砂、Sheet 和页面转场。

每张页面至少检查：主视觉是否唯一、绿色是否只承担主动作/状态、边框是否过多、文字灰度是否超过三级、关键动作是否依赖 hover、底部控制是否抢夺内容焦点。

## 13. 主要一手来源

- 全局字体、圆角、主题与动画：`frontend/apps/web/app/globals.css`
- App 壳、Header 与 PlayerBar：`frontend/apps/web/components/MainLayout.tsx`、`Header.tsx`、`PlayerBar.tsx`
- 首页与时段主题：`frontend/apps/web/app/(dashboard)/page.tsx`、`hooks/home/useHomeData.ts`
- 卡片与列表：`components/home/GridCard.tsx`、`components/SearchContents/SongRow.tsx`、`components/library/LibraryMediaGrid.tsx`
- 内容详情：`components/Playlist`、`components/artist`、`components/album`
- 登录与设置：`components/auth/LoginPage.tsx`、`components/settings`
- 基础状态组件：`components/ui/skeleton.tsx`、`components/ui/alert-dialog.tsx`、`components/shared/NetworkRetryState.tsx`
