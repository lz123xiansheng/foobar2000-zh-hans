# 更新日志 / Changelog

## v3.3 (2026-05-10)
- 新增 ~130 条翻译，覆盖 11 个类别
- **过滤器**: 匹配模式/播放次数最多/从未播放/评分最高等
- **音频文件格式**: DTS/DTS-HD/MLP/RTMP/HLS/WMA + 格式名称/文件类型掩码
- **DSP 管理器完整列表**: 直流偏移/硬限制器/Meier交叉馈送/反转立体声/跳过静音等
- **显示/解码/标签**: 附加修正文件夹/音调扫频/专辑封面/优先设置等
- **播放设置**: ShoutCast/HTTP代理/强制CONNECT/附加解码/切歌DSP重置等
- **缓冲/MP3/标签**: ID3v2兼容性/TPE2映射/慢速精准跳转/智能停止等
- **Opus/SoundCheck**: 头部增益/SoundCheck响度/iTunes标准/回放增益标准等
- **工具/文件操作**: 文件完整性校验/空文件夹检测/删除方式/保留时间等
- **统计/搜索**: 扫描线程/增益线程/非对称匹配/限定字段/EXTM3U等
- 修复: `Visualize with AudioUnit` 键名匹配（二进制中实际为 `Visualize with Audio Unit`）

## v3.2 (2026-05-??)
- 新增 ~100 条翻译
- 可视化子菜单完整翻译
- 布局预设汉化
- 播放选项扩展（停止后/重复模式等）
- 播放统计完整汉化
- DSP 名称列表汉化
- 网络/UPnP/ReFacets 汉化

## v3.1
- 新增 65 条翻译
- ReplayGain 子菜单完整汉化
- Enqueue（加入队列）系列菜单汉化
- 播放列表切换菜单汉化
- DSP 管理器界面汉化

## v3.0
- 完全重写：从 3 个 Hook 扩展到 10 个 AppKit 方法 Hook
- 新增 NSButton/NSTextField/NSTabViewItem/NSBox/NSWindow Hook
- 新增定时轮询（每 2 秒）+ 7 阶段延迟遍历
- 新增窗口树递归遍历
- 新增菜单变更通知监听
- 翻译条目从 50 条扩展到 250+ 条

## v2.0
- 基于 insert_dylib 的 LC_LOAD_DYLIB 注入方案
- NSMenuItem Hook 方法
- 基础菜单汉化

## v1.0
- NIB 文件直接改写方案（Python nibarchive）
- 146 个 NIB 文件共 ~4800 字符串汉化