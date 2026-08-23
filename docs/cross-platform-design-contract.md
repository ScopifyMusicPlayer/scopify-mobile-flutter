# Scopify 跨端设计落地合同

这份合同是 M4 之前插入的设计落地阶段的验收边界。它把 Web 当前实现中的
Scopify 主题与组件配方变成 Mobile 可以直接消费的语义接口；线稿只保留页面构图、
状态承载和导航关系，不再作为生产视觉的唯一参考。

## 真源与职责

视觉真源按以下顺序解释：

1. Web 的主题契约：`frontend/packages/ui/themes/shadcn/scopify-default.css` 与
   `frontend/packages/ui/themes/scopify/scopify-default.css`。
2. Web 的已落地组件配方：`frontend/apps/web/components`，优先参考
   `GridCard`、`SongRow`、`Playlist/ActionStation`、`ui` 基础控件和 `VipSign`。
3. 本合同：记录跨端语义映射和移动端限制。
4. `docs/wireframes/mobile-wireframe-prototype.html`：只验收构图、状态槽位和入口关系。

Web 不负责复用 Mobile 的布局，Mobile 也不复制 Web 的 Tailwind 类名。两端共享的是
语义、明度层级、动作主次、圆角节奏和状态承载方式。

## Token 映射

| Web 语义 | Web dark 值 | Mobile 适配 | 规则 |
| --- | --- | --- | --- |
| `background` / `surface` | `#000000` | `AppTokens.canvas` | App 外壳和沉浸背景基底 |
| `card` / `surface-raised` | `#121212` | `AppTokens.surfaceBase` | 页面主内容面 |
| `secondary` / `surface-elevated` | `#181818` | `AppTokens.surfaceCard` | 媒体卡片和实体分组 |
| `popover` / `surface-overlay` | `#282828` | `AppTokens.surfaceRaised` | Modal、Sheet、抬升面 |
| `accent` / `surface-sunken` | `#0F0F0F` | `AppTokens.surfaceDeep` | 深色导航和下沉分组 |
| `foreground` | `#FFFFFF` | `AppTokens.textPrimary` | 标题、主内容、主动作文字 |
| `muted-foreground` | `#B3B3B3` | `AppTokens.textSecondary` | 副标题、歌手、辅助控件 |
| `scopify-content-subtle` | `#727272` | `AppTokens.textTertiary` | 时间、弱说明、禁用前状态 |
| `primary` / `brand` | `#1ED760` | `AppTokens.accent` | 只用于主播放、确认、选中和成功 |
| `scopify-brand-hover` | `#3BE477` | `AppTokens.accentHover` | Web hover；移动端只用于 pressed/反馈 |
| `border` | `rgba(255,255,255,.10)` | `AppTokens.divider` | 仅用于需要明确边界的控件 |
| `scopify-overlay` | `rgba(0,0,0,.80)` | `AppTokens.overlay` | Modal、Sheet 和沉浸可读性遮罩 |

品牌绿不作为大面积页面背景。首页时段渐变、详情 Hero 和播放器背景属于页面策略，
只能收口到这些 token，不得反向新增全局品牌色。

## 组件接口

### 主动作

- 圆形播放按钮：Web `ActionStation` 的 56px 绿色主动作；Mobile 使用
  `ScopifyPlayButton`，默认 56px，详情 sticky 状态可缩到 48px。
- 长主按钮：48px 高、胶囊、绿色底、黑色粗体文字；Mobile 使用
  `ScopifyPillButton`，不在页面内重新拼接 `FilledButton` 样式。
- 次级动作：44px 以上点击区域，默认 `textSecondary`，active 变 `accent`，不加实体卡片。

### 媒体与列表

- 媒体卡片：`surfaceCard`、12px 左右圆角、16px 内边距；封面先于文字，标题一行，
  副标题最多两行。
- 列表行：透明或极弱分隔，pressed 使用 `surfaceSoft`，当前播放标题使用 `accent`。
- 封面右下角播放动作可以在 Web hover 出现；Mobile 必须常驻或由详情入口承载，不能
  把关键操作藏在 hover 语义里。

### 状态、Modal 与反馈

- Loading 骨架匹配最终几何；已有内容刷新时保留内容，只显示轻量刷新反馈。
- Empty、Error 和游客门槛分别表达，不合并成同一个通用错误卡。
- Modal 使用 `surfaceRaised`、弱边界、约 12–16px 圆角和统一 overlay；写操作结果走
  App Shell 的 Toast，不在业务页面另造反馈层。
- 所有动效遵守 `MediaQuery.disableAnimationsOf`，优先 160–220ms，Sheet 300ms 左右。

## Seam 与目录归属

- `lib/app/theme/` 持有 token、Theme 和 motion；页面不直接声明品牌色、全局圆角或时长。
- `lib/components/shared/` 只放已经跨两个业务使用且语义相同的深模块，例如
  `ScopifyPillButton`、`ScopifyPlayButton`、`ScopifyIconAction`、`MediaArtwork`。
- 页面自己的渐变、图片提色和业务状态属于 page policy，不扩散为通用控件参数。
- M4 的签到、喜欢、关注和收藏写操作必须复用这些接口；写操作状态不能绕过统一按钮、
  Toast 和错误回滚约定。

## 线稿升级验收

- 原型 CSS 的核心变量与 Web dark theme 对齐；screen ID 仍然用于状态验收。
- 每个新增生产页面都要有“Web 组件配方 → Mobile 组件接口 → 线稿状态”的映射记录。
- 评审顺序固定为：信息层级 → 交互主次 → 数据状态 → 动效与视觉细节。
- 线稿可以继续展示静态状态，但不再使用 `PROTOTYPE — throwaway` 作为生产视觉免责说明；
  生产代码仍不得直接复制 HTML 布局。
