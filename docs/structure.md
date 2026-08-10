# Scopify Mobile 代码结构

> 本文只回答“代码放在哪里、各层如何协作”。技术选择见 [technical-stack.md](./technical-stack.md)，页面与交互见 [mobile-pages.md](./mobile-pages.md)，开发顺序见 [project-plan.md](./project-plan.md)。

## 1. 核心拆分思想

```text
go_router
   ↓
Page：路由入口与页面状态分发
   ↓
Layout：决定页面骨架、区域和响应式布局
   ↓
Components：填充 Layout 的具体内容
   ↓
Riverpod Provider / Notifier
   ↓
Thin API → Dio Runtime
```

- `pages/` 按业务组织页面，是用户能够导航到的 route 边界。
- 根 `layouts/` 只放 App Shell、通用详情、Modal、播放器等跨业务布局。
- `pages/<business>/layouts/` 放只属于该业务的局部布局。
- 业务组件先留在 `pages/<business>/components/`；只有出现真实的跨业务复用后才移动到 `components/shared/`。
- 普通远程数据留在所属业务中，使用薄 API、DTO 和 Riverpod，不增加只转发的 Repository、Interface 或 Adapter。
- Playback、Session、QR Login、Endpoint、听歌识曲等持续跨页面或持有平台生命周期的能力才进入 `modules/`。
- 目录按需求懒创建。树里出现的目录不是脚手架清单，当前业务没有对应代码时就不创建。

## 2. 目标结构

下面只展示结构角色和一个完整业务样例，不枚举所有页面文件：

```text
lib/
├─ main.dart
├─ app/                             # Composition Root
│  ├─ scopify_app.dart
│  ├─ bootstrap.dart
│  ├─ router/                       # go_router + typed routes
│  └─ theme/                        # Material 3、AppTokens、AppMotion
├─ layouts/                         # 真正跨业务的全局布局
│  ├─ app_shell_layout.dart
│  ├─ detail_layout.dart
│  ├─ modal_layout.dart
│  └─ player_layout.dart
├─ components/
│  └─ shared/                       # 已被多个业务实际复用的组件
├─ pages/
│  ├─ home/                         # 一个完整业务样例
│  │  ├─ home_page.dart
│  │  ├─ layouts/                   # 只属于 Home 的布局
│  │  ├─ components/                # 只属于 Home 的组件
│  │  ├─ providers/                 # 查询状态、刷新与页面派生状态
│  │  ├─ api/                       # 手写薄 API
│  │  └─ dto/                       # 后端原始 DTO 与 .g.dart
│  ├─ search/
│  ├─ my/
│  ├─ playlist/
│  ├─ player/
│  ├─ profile/
│  └─ settings/
├─ modules/                         # 有持续生命周期的深能力
│  ├─ playback/
│  ├─ session/
│  ├─ qr_login/
│  ├─ endpoint/
│  └─ recognition/
├─ shared/                          # 非 UI、且确实跨业务的基础能力
│  ├─ network/                      # Dio Runtime 与稳定 AppFailure
│  ├─ storage/                      # QueryCacheStore 等共享存储
│  ├─ formatting/
│  └─ accessibility/
└─ l10n/                            # 按业务 Namespace 的 Compact CSV
```

新业务只创建自己需要的部分。例如一个只有静态内容的 About 页面可以只有 `about_page.dart`；不能为了“结构完整”同时创建空的 `layouts/`、`components/`、`providers/`、`api/` 和 `dto/`。

## 3. Page、Layout 与 Component

### Page

Page 负责：

- 作为 typed route 的入口。
- 读取 Riverpod 页面状态。
- 在 Loading、Data、Empty、Error 等状态之间选择内容。
- 把业务组件填入对应 Layout。

Page 不负责：

- 直接请求 Dio。
- 定义整套视觉骨架。
- 保存一份与 Playback/Session Module 重复的状态。
- 堆放可复用组件实现。

### Layout

Layout 只决定几何关系和插槽，例如顶部区域、滚动内容、安全区、迷你播放器预留和底部操作区。它接收 Widget 或简单布局数据，不发请求、不读 Cookie、不执行业务 mutation。

```text
AppShellLayout                         # 全局
└─ HomePage
   └─ HomeLayout                      # Home 局部
      ├─ HomeGreeting                 # Home 组件
      ├─ RecommendationSection        # Home 组件
      └─ ScopifyNetworkImage          # Shared 组件
```

根 Layout 的准入条件：它构成 App Shell，或者至少被两个业务页面实际复用。否则留在业务自己的 `layouts/`。

### Component

- 页面第一次使用时放在业务目录。
- 同一业务多个页面复用，仍放该业务的 `components/`。
- 两个及以上业务需要相同语义和交互时，才移动到 `components/shared/`。
- 仅仅“长得相似”不是共享理由；共享组件必须拥有稳定、清楚的产品语义。

## 4. 数据与 Module 边界

### 普通查询

```text
Page / Component
      ↓
Riverpod Provider / Notifier
      ↓
同业务 Thin API
      ↓
共享 Dio Runtime
```

歌单详情、首页推荐、评论列表等普通数据不建立 `Repository → Interface → Adapter` 转发链。Provider 负责查询身份、缓存、刷新、分页和 mutation 后失效；API 只描述 endpoint、参数和 DTO。

### 深 Module

满足以下任一条件时才考虑 Module：

- 生命周期跨越多个 Page。
- 持续监听平台或设备状态。
- 必须保证全 App 只有一个所有者。
- 内部状态机、取消、恢复或安全边界值得被隐藏。

因此 Playback、Session、QR Login、Backend Endpoint 和 Recognition 使用深 Module。新建 Module 前必须说明它隐藏的复杂度；“以后可能复用”不构成理由。

## 5. 路由与全局布局

- `go_router` 是页面切换的唯一入口；Layout 和 Component 不能自行维护另一套路由表。
- Home、Search、My 三个一级页面使用各自保留栈。
- `AppShellLayout` 统一拥有 Drawer、三项底部导航、迷你播放器和全局反馈区域。
- 普通详情页面继承入口一级栈；沉浸播放器、登录阻断面和全局 Modal 按页面规格决定是否覆盖 Shell。
- Drawer 内需要覆盖当前页面的内容使用同一 Modal 机制；真正的信息详情才进入 typed route。

## 6. 测试结构

测试目录镜像被测试的业务，不反向决定生产目录：

```text
test/
├─ pages/
│  ├─ home/
│  ├─ search/
│  └─ player/
├─ modules/
│  ├─ playback/
│  └─ session/
└─ shared/
   ├─ network/
   └─ storage/
```

- Fixture 跟随实际消费它的测试；只有多个业务测试真实复用时才进入共享 Fixture。
- Fake 优先于 Mock，Mock 只用于平台边界。
- 当前不创建 `integration_test/` 或 Patrol 目录；Android Emulator 主流程稳定后再决定。

## 7. 明确禁止

- 同时出现 `pages/`、`screens/`、`views/` 三套页面概念。
- 为每个 endpoint 创建一个 API、Repository、Interface、Adapter 和 Provider 文件链。
- 把所有组件提前搬进 `shared`。
- Page 或 Layout 直接 import Dio、Sqflite、Secure Storage 或 AudioPlayer。
- 为尚未实现的里程碑批量生成空目录和占位文件。
- 用 `utils.dart`、`helpers.dart`、`common.dart` 长期收纳无法命名的杂项。
