# Flutter 乐签纸张 Shader 调研

日期：2026-08-25
范围：确认 Flutter 能否为「乐签」票面做 GPU 驱动的纸张材质；不涉及本轮静态 HTML 原型的实现。

## 结论

可以，且建议正式 Flutter 端采用 **`FragmentProgram` + `FragmentShader` + `CustomPaint`**。这是 Flutter 官方支持的 GLSL fragment shader 路径；不需要为纸纹增加第三方包。将 shader 只用于票面底图，封面、手写文字、爱心和按钮仍使用普通 Flutter Widget，能保留清晰文字与可访问交互。

项目本机为 Flutter `3.44.6` / Dart `3.12.2`，`pubspec.yaml` 当前没有 `shaders` 条目，也没有需要保留或替换的 shader 依赖。因此可直接以 Flutter 官方资产机制接入。

## 推荐实现

```text
VipMusicSign（业务页面）
└─ ClipPath（票根和两侧挖口的真实轮廓）
   └─ Stack
      ├─ CustomPaint（仅绘制票面纸底：Paint.shader）
      └─ 封面、手写信笺、数据、操作按钮（普通 Widget）
```

1. 在 `assets/shaders/scopify_ticket_paper.frag` 编写 GLSL，并在 `pubspec.yaml` 声明：

   ```yaml
   flutter:
     shaders:
       - assets/shaders/scopify_ticket_paper.frag
   ```

2. 应用启动或首次进入乐签前通过 `FragmentProgram.fromAsset()` 加载并缓存程序；`CustomPainter` 取得 `FragmentShader`，赋给 `Paint.shader` 后仅绘制票面矩形。Flutter CLI 会将声明的 `.frag` 编译并随应用打包。[官方 shader 资产与加载说明](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#adding-shaders-to-an-application)

3. shader 使用最少的输入：`uSize`、当前时间主题色、封面取色与稳定 seed。纸面应保持静态，不随帧流动：

   - 中性暖灰纸底；
   - 两层低对比颗粒与同方向细纤维；
   - 右上仅一小片、低透明度的时间色晕；
   - 左下仅一小片封面取色装饰；
   - 不向整张票面铺满时间渐变，也不扭曲正文或封面。

4. `CustomPainter.shouldRepaint` 只在尺寸、歌曲 seed、封面色或时间主题变化时返回 `true`；无需创建连续噪点动画。

## 为什么不用其他路径

| 路径 | 适合度 | 原因 |
| --- | --- | --- |
| `Paint.shader` + `CustomPaint` | 推荐 | 官方说明其可用于 `Canvas.drawRect` 等 Canvas API；同一套 custom shader 支持 Skia 与 Impeller，正好能只画票面底层。[官方 Canvas API](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#canvas-api) |
| `ImageFilter.shader` / `BackdropFilter` | 不作为主路径 | 会处理已渲染内容，容易把文字和封面一并滤掉；更重要的是官方明确该 API **仅支持 Impeller**，其他后端会抛错。[官方限制](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#imagefilter-api) |
| `ShaderMask` | 不适合纸纹本体 | 它是将 child 与 `Shader` 做混合的 Widget，适合渐隐或染色，不负责生成有细节的纸张表面。[Flutter API](https://api.flutter.dev/flutter/widgets/ShaderMask-class.html) |
| CSS / SVG 噪点贴图 | 只作静态原型替代 | 不会成为原生 Flutter UI 的 GPU 材质实现；正式端应以 `.frag` 为唯一票面效果来源。 |

Android API 29+ 默认启用 Impeller；更低版本或不支持 Vulkan 的设备会回退旧 OpenGL renderer。因此这里选择 `Paint.shader` 而非仅 Impeller 可用的 `ImageFilter.shader`，仍应在目标 Android 模拟器和一台回退设备上做截图核验。[Flutter Impeller 平台说明](https://docs.flutter.dev/perf/impeller#android)

## Folia 参考如何迁移

Folia 的 Nomand 纸张层不是可直接搬到 Flutter 的包：它是 Web 侧的 shader 实现。它将纸张外观拆成对比度、粗糙度、纤维，并固定了一组纤维/褶皱/水滴的形状参数；还因 UV 位移计算 overscan，避免边缘露底。[Folia 参数与 overscan](../../../web/components/lyrics/folia/src/components/visualizer/backgrounds/nomand/nomandShaderAdjustments.ts)

因此应迁移的是视觉模型，而不是复制 Web GLSL：Flutter 的票面无需图像 UV 扭曲或 overscan，只保留其中的「细纤维 + 低对比颗粒 + 克制褶皱」三层。初版建议将纸纹强度控制在肉眼近看可感知、缩略图不抢字的范围；如果截图依然显脏，先降低噪点对比度，而不是再叠加纹理。

## 性能与落地约束

- `FragmentProgram` 在 Skia 后端的首次加载/编译可能昂贵，官方建议在动画前预缓存；本页虽不做动画，仍应缓存 program，不能在每次 `build` 中加载。官方也建议跨帧复用 `FragmentShader`，不要每帧新建。[官方性能说明](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#performance-considerations)
- 官方 shader 仅支持 fragment shader（不支持 vertex shader），且 sampler 仅支持 `sampler2D`；本需求只需过程噪声和颜色，不受该限制。[官方 shader 限制](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#authoring-shaders)
- shader 输出使用预乘 alpha；Dart 设置主题色时应按该约定传入，避免透明纸纹在暗色背景上出现灰边。[官方颜色约定](https://docs.flutter.dev/ui/design/graphics/fragment-shaders#colors)
- 组件应留在乐签所属业务目录；目前没有第二个业务具有相同「票据纸张」语义，不提前抽进 `components/shared/`。

## 建议的下一步

先做一个仅有票面底图的 `scopify_ticket_paper.frag` + `CustomPaint` 垂直切片，再把乐签内容叠上去。验收只看三项：正文清晰、时间色只占小区域、Android Emulator 上滚动或进入页面无可见卡顿。通过后再调纸纤维密度，不要继续在 HTML/CSS 票面上迭代模拟材质。
