# Scopify Mobile 初期项目计划

> 当前仓库仍是 Flutter 空壳。第一目标不是一次实现全部能力，而是在 Windows 的 Android Emulator 中跑通一条结构正确、可持续扩展的页面链路。

## 文档职责

本计划只记录开发阶段、顺序和验收，不再重复结构、技术栈、页面细节或后端接口：

| 需要了解 | 对应文档 |
| --- | --- |
| 代码放在哪里 | [structure.md](./structure.md) |
| Flutter 技术选型 | [technical-stack.md](./technical-stack.md) |
| 页面、Drawer、Modal 与状态 | [mobile-pages.md](./mobile-pages.md) |
| 当前低保真设计 | [mobile-wireframe-prototype.html](./wireframes/mobile-wireframe-prototype.html) |
| Web 已有能力 | [web-capabilities.md](./web-capabilities.md) |
| Web 设计语言如何映射到 Flutter | [web-design-language.md](./web-design-language.md) |
| Mobile 领域词汇 | [CONTEXT.md](../CONTEXT.md) |

## 1. 当前阶段目标

第一次“跑通”定义为：

```text
Android Emulator
├─ Material 3 + AppTokens 正常加载
├─ go_router typed routes 正常工作
├─ Home / Search / My 三个一级页面可切换并保留各自栈
├─ 全局 Drawer 与 Modal 可打开、关闭并遵守页面边界
├─ Home / Search / My / 内容详情 / Player 线稿链路可达
├─ Fixture 数据能够展示 Loading / Data / Empty / Error
└─ Fake Playback 能串起歌曲入口、迷你播放器与完整播放器 UI
```

这一阶段不要求真实 Dio、真实登录、真实音频、后台服务、更新安装、真机或 iOS。

## 2. 开发原则

1. 先完成一个可以运行和导航的纵向切片，再扩页面数量。
2. 页面与布局先消费 Fixture；真实 API 接入不得迫使页面重写。
3. `pages / layouts / components` 是主要 UI 语言；业务内部按目录组织。
4. 业务组件默认留在自己的业务目录，发生真实跨业务复用后才进入 Shared。
5. 普通远程数据使用 Riverpod → Thin API → Dio，不建立转发文件链。
6. 只有持续持有设备或跨页面生命周期的能力进入深 Module。
7. 目录和文件按当前步骤懒创建，不一次搭完整空树。
8. 每个阶段先在 Android Emulator 验证；Android 首个发布稳定后再启动 iOS 规划。

## 3. M1 — Android Emulator 页面闭环

### 3.1 App 基础

- 建立 `ScopifyApp`、启动 bootstrap、Material 3 Theme、AppTokens 和 AppMotion。
- 建立 typed router 与三个一级页面保留栈。
- 建立全局 App Shell Layout，组合 Drawer、独立迷你播放器和三项底部导航。
- 建立通用 Detail、Modal 和 Player Layout；只创建当前页面实际使用的文件。

### 3.2 第一条页面链路

按以下顺序实现，不并行铺开全部页面：

1. Home：Fixture 推荐内容和进入内容详情的入口。
2. 内容详情：复用全局 Detail Layout，并能触发 Fake Playback。
3. Mini Player：展示 Fake 当前歌曲并进入完整播放器。
4. Player：CD/歌词中心模式、共享控制区、队列和评论入口占位。
5. Search：发现态、结果态和进入详情的入口。
6. My：游客态与音乐/播客/收藏三个内部区块。
7. Drawer 与 Modal：账号卡片、乐签、定时关闭、更新等入口按线稿展示，不接真实平台能力。

其余 V1 页面只在上述链路需要入口时增加 route 或轻量占位，不为“页面清单完整”提前生成业务目录。

### 3.3 状态与 Fixture

每个已实现页面至少可以稳定切换：

- 首次 Loading / Skeleton。
- Data。
- Empty。
- First-load Error。

只有页面真实存在局部区块或分页时，才增加 Partial Error、Pagination Error 等状态。Fixture 放在消费它的业务测试附近，不能先创建全局 Fixture 仓库。

### 3.4 M1 验收

- `flutter run` 能在 Android Emulator 冷启动并进入 Home。
- 三个一级页面、Drawer、Modal、详情页和 Player 的返回关系正确。
- 迷你播放器与底部导航是两个独立组件，显示/隐藏互不影响布局职责。
- 一级页面允许汉堡按钮与规定边缘手势打开 Drawer；阻断状态、详情页和沉浸页不能误开 Drawer。
- 小屏、常规屏和大字体下没有关键溢出。
- 页面只依赖 Provider/Fixture，不直接 import Dio、Sqflite、Secure Storage 或 AudioPlayer。
- 关键 Provider/Widget 测试通过；核心线稿页面有 Golden 基线。
- 不要求真实网络、账号、音频、通知栏或真机行为。

## 4. 后续里程碑

### M2 — 公共数据与前台播放

- Backend Endpoint 设置、连接探测与 Dio Runtime。
- 首页、搜索和公开内容详情接入真实只读数据。
- QueryCacheStore 与已确认的选择性持久缓存策略。
- 播放地址解析、歌词、前台音频、队列、循环、随机和失败恢复。
- Fixture 继续保留，供页面状态和测试使用。

### M3 — 登录与账号内容

- QR Login 状态机、安全凭据、Session 恢复与退出。
- My、Profile、最近播放、乐签和账号作用域缓存。
- Drawer 中设置、听歌识曲、检查更新等入口接入对应 Module；仍优先完成读取和状态展示。

### M4 — 写操作与评论

- 喜欢、关注、收藏和歌单编辑。
- 评论读取、分页、发布、回复、点赞和删除。
- mutation 的提交中、乐观更新、失败回滚、缓存失效和全局反馈。
- 写操作接真实账号前逐项进行产品复核，不因按钮已画出就默认授权实现。

### M5 — Android 播放平台化

- 后台播放、通知栏、锁屏、媒体按键和媒体会话恢复。
- 音频焦点、电话/导航打断、耳机拔出和录音识曲的 Session 切换。
- 音频临时缓存、睡眠定时、长时间播放、切网和进程回收。
- Android Emulator 主流程稳定后，再决定 Patrol 与真机 E2E。

### M6 — 发布硬化

- 无障碍、减少动态效果、大字体、触摸目标和屏幕尺寸 QA。
- 日志脱敏、HTTPS/私网 HTTP、权限、隐私和开源许可证检查。
- 冷启动、内存、Crash/ANR 和播放稳定性基线。
- GitHub Release 更新流程和首个 Android 发布。
- iOS 规划在 Android 核心体验稳定之后开始。

## 5. 每个页面切片的完成标准

一个页面或页面状态只有同时满足以下条件才算完成：

- typed route、入口、返回和所属一级栈正确。
- 使用全局或本地 Layout 表达结构，而不是把整页几何堆在 Page 中。
- 业务组件留在所属业务；Shared 组件存在真实跨业务消费者。
- Loading、Data、Empty、Error 中适用的状态可被 Fixture 稳定复现。
- 大字体和目标屏幕宽度无关键溢出，并支持减少动态效果。
- Widget 不直接访问网络、数据库、安全存储或播放插件。
- 至少有一个行为测试覆盖主要状态切换；重要视觉状态纳入 Golden。

## 6. 真实数据接入规则

M2 起按业务纵向接入，不先创建一个包含全部 endpoint 的 Backend 大模块：

```text
Page / Component
      ↓
Riverpod Provider / Notifier
      ↓
同业务 Thin API + DTO
      ↓
共享 Dio Runtime
```

- Provider 负责缓存身份、新鲜度、刷新、分页、mutation 与失效。
- API 只负责 endpoint、参数和 DTO，不发 Toast、不读 Widget 状态。
- Dio Runtime 统一处理 Endpoint、凭据、超时、错误、取消、追踪与日志脱敏。
- Playback、Session、QR Login、Endpoint 和 Recognition 继续使用深 Module。
- Fixture 与测试验证可观察结果，不要求为生产实现复制一套同名 Adapter 层。

## 7. 当前测试与验证

当前自动化只要求：

- 纯逻辑与缓存测试。
- Riverpod Provider/Notifier 测试。
- Widget 交互测试。
- 关键组件和页面 Golden。

当前人工 Smoke Test 只在 Android Emulator 执行，检查启动、导航、Drawer、Modal、页面状态和 Fake Playback UI。首个纵向切片稳定后再增加少量 SDK `integration_test`；Patrol、通知栏自动化、锁屏控制和真机矩阵延后。

## 8. 近期任务

按顺序执行：

- [ ] 建立最小 `app/`、Theme 和 typed router。
- [ ] 建立 App Shell Layout、三项底部导航、Drawer 与 Mini Player 空壳。
- [ ] 用 Fixture 完成 Home → Detail → Fake Playback → Player 链路。
- [ ] 增加 Search 与 My 一级页面。
- [ ] 增加 Drawer/Modal 中已确认的入口和线稿内容。
- [ ] 补 Provider、Widget 和 Golden 测试。
- [ ] 在 Android Emulator 按 M1 验收清单完整走一遍。
- [ ] M1 通过后再开始真实 Dio 与前台音频。
