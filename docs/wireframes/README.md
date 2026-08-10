# Mobile wireframe prototype

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
