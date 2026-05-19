# foobar2000 macOS 中文汉化 — 完整总结报告

> 适用版本：foobar2000 **v2.26** (build 46) for macOS  
> 汉化包版本：**v3.3**  
> 汉化完成度：**~95%**  
> 项目地址：[github.com/lz123xiansheng/foobar2000-zh-hans](https://github.com/lz123xiansheng/foobar2000-zh-hans)  
> 开源许可：GPL v3 + 非商业条款（传染式开源）  

---

## 目录

1. [项目概述](#1-项目概述)
2. [foobar2000 界面架构分析](#2-foobar2000-界面架构分析)
3. [功能按钮架构树](#3-功能按钮架构树)
4. [汉化方案 —— 三层体系](#4-汉化方案--三层体系)
5. [实施步骤详解](#5-实施步骤详解)
6. [技术难点与解决方案](#6-技术难点与解决方案)
7. [汉化经验总结](#7-汉化经验总结)
8. [版本升级后的处理](#8-版本升级后的处理)
9. [文件清单](#9-文件清单)

---

## 1. 项目概述

### 1.1 项目背景

foobar2000 是一款由 Peter Pawlowski 开发的高品质音频播放器，以其高度可定制性和优秀的音频处理能力著称。然而，foobar2000 **macOS 版**从 2024 年才正式发布，至今**没有官方中文支持**，而 Windows 版早已有完善的第三方汉化方案（如 Asion 汉化版）。

本项目旨在为 macOS 用户提供一套**完整的、可持久化的** foobar2000 中文汉化方案。

### 1.2 目标

- 主菜单栏 100% 汉化
- 偏好设置窗口 ~95% 汉化
- 右键上下文菜单汉化
- DSP 管理器、均衡器、转换器等子窗口汉化
- 重启电脑不影响汉化效果
- 版本升级后可一键恢复

### 1.3 汉化成果

| 模块 | 汉化程度 | 说明 |
|------|---------|------|
| 主菜单栏（文件/编辑/视图/播放/媒体库/窗口/帮助） | 100% | 全部菜单项及子菜单 |
| 偏好设置 — 侧边栏导航 | 100% | 显示/播放/输出/DSP/组件/高级/网络等 |
| 偏好设置 — 各页面控件 | ~95% | 按钮/标签/下拉框/复选框 |
| 右键菜单 | ~90% | 播放列表/音轨右键菜单 |
| DSP 管理器 | 100% | 可用 DSP 列表 + 活动 DSP |
| 均衡器 | 100% | 预设/自动电平/保存/加载 |
| 转换器 | 100% | 输出格式/路径/命名 |
| 播放统计 | 100% | 首次播放/最后播放/播放次数/评级 |
| 文件操作 | 100% | 文件完整性校验/空文件夹检测/重命名/删除 |
| 过滤器/ReFacets | 100% | 筛选/分面 |
| 网络/UPnP设置 | 100% | 代理/远程控制/流媒体/密码 |
| 关于窗口 | 100% | 版本/许可/版权 |
| 可视化子菜单 | 100% | AudioUnit/峰值表/频谱/波形 |
| SoundCheck/Opus 设置 | 100% | 头部增益/目标响度/标准化 |
| 高级设置 | ~90% | 缓冲/解码/标签/ID3v2 |

---

## 2. foobar2000 界面架构分析

### 2.1 架构总览

foobar2000 macOS 版的界面渲染机制非常特殊，它**混合了两种 UI 构建方式**：

```
┌─────────────────────────────────────────────────────┐
│                   foobar2000.app                     │
│                                                      │
│  ┌──────────────────────────────────────────────┐    │
│  │         Mach-O 二进制 (C++ 核心引擎)           │    │
│  │                                               │    │
│  │  ┌─────────────────┐  ┌───────────────────┐  │    │
│  │  │ C++ 主程序逻辑    │  │   C++ 菜单系统     │  │    │
│  │  │ (播放/解码/管理)  │  │  mainmenu_group   │  │    │
│  │  └─────────────────┘  │  contextmenu_group │  │    │
│  │                       └─────────┬─────────┘  │    │
│  │                                 │             │    │
│  │  ┌──────────────────────────────▼──────────┐  │    │
│  │  │   AppKit ObjC 桥接层                    │  │    │
│  │  │   (运行时通过 NSMenuItem/NSButton/       │  │    │
│  │  │    NSTextField 等创建 UI 控件)           │  │    │
│  │  └──────────────────────┬──────────────────┘  │    │
│  └─────────────────────────┼──────────────────────┘    │
│                            │                           │
│  ┌─────────────────────────▼──────────────────────┐    │
│  │            NIB 文件（静态布局）                  │    │
│  │  146 个 .nib 文件 → NSKeyedArchiver 序列化      │    │
│  │  存储：对话框/属性面板/静态标签/窗口初始布局      │    │
│  └──────────────────────────────────────────────┘    │
│                                                      │
│  ┌──────────────────────────────────────────────┐    │
│  │     zh-Hans.lproj/Localizable.strings         │    │
│  │     macOS 标准本地化机制（少量使用）            │    │
│  └──────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 2.2 关键发现

**核心问题**：foobar2000 的 C++ 引擎在**运行时动态创建 UI 控件**，而非像大多数 macOS 应用那样依赖 NIB 文件或 `.strings` 本地化文件。这意味着：

1. **NIB 文件**只覆盖了对话框、静态标签、初始窗口布局（约 4800 个字符串）
2. **主菜单栏**完全由 C++ 代码通过 `mainmenu_group` 类在运行时动态构造
3. **偏好设置页面**大部分控件也是代码动态创建的
4. **右键菜单**由 `contextmenu_group` 类动态生成

这就是为什么单靠修改 NIB 文件（最初的方案）只能实现部分汉化——菜单和大量动态 UI 根本不在 NIB 中。

### 2.3 控件类型分布

| 控件类型 | 来源 | 汉化方式 |
|---------|------|---------|
| NSMenuItem（菜单项） | C++ 动态创建 | Hook setTitle:/initWithTitle: |
| NSButton（按钮） | 混合（NIB + 动态） | Hook setTitle:/setAlternateTitle: |
| NSTextField（文本字段） | 混合 | Hook setStringValue:/setPlaceholderString: |
| NSTabViewItem（标签页） | NIB + 动态 | Hook setLabel: |
| NSBox（分组框） | NIB + 动态 | Hook setTitle: |
| NSWindow（窗口标题） | 动态 | Hook setTitle: |
| NSSegmentedControl（分段控件） | 动态 | 遍历 segments 翻译 |
| 普通 NSView 子类 | NIB | NIB 文件直接改写 |

---

## 3. 功能按钮架构树

### 3.1 主菜单树

```
foobar2000 主菜单
├── 文件 (File)
│   ├── 新建播放列表 (New Playlist)
│   ├── 打开... (Open...)
│   │   ├── 打开文件... (Open File...)
│   │   ├── 打开文件夹... (Open Folder...)
│   │   ├── 打开音频CD... (Open Audio CD...)
│   │   └── 打开位置... (Open Location...)
│   ├── 添加文件... (Add Files...)
│   ├── 添加文件夹... (Add Folder...)
│   ├── 添加位置... (Add Location...)
│   ├── ──── 分隔线 ────
│   ├── 保存播放列表 (Save Playlist)
│   ├── 保存播放列表... (Save Playlist...)
│   ├── 保存播放列表副本... (Save Copy...)
│   ├── 保存全部播放列表... (Save All...)
│   ├── ──── 分隔线 ────
│   ├── 偏好设置... (Preferences...)
│   ├── 页面设置... (Page Setup...)
│   ├── 打印... (Print...)
│   └── 退出 foobar2000 (Quit)
│
├── 编辑 (Edit)
│   ├── 撤销/重做 (Undo/Redo)
│   ├── 剪切/复制/粘贴/删除
│   ├── 全选/取消全选
│   ├── 查找/替换 (Find/Replace)
│   └── 拼写/语法/替换/变换/语音
│
├── 视图 (View)
│   ├── 显示/隐藏 侧边栏/状态栏/工具栏/标签栏
│   ├── 进入/退出 全屏
│   ├── 布局 (Layout)
│   │   ├── 快速设置 (Quick Setup)
│   │   ├── 创建/编辑/删除 布局
│   │   ├── 布局编辑模式/实时编辑/重置布局
│   │   └── 预设：
│   │       ├── 仅播放列表
│   │       ├── 侧边栏：专辑列表
│   │       ├── 侧边栏：专辑列表与封面
│   │       └── 侧边栏：专辑列表与播放列表
│   ├── 颜色 (Colour)
│   ├── 可视化 (Visualizations)
│   │   ├── AudioUnit 可视化
│   │   ├── 峰值表 (PeakMeter)
│   │   ├── 频谱 (Spectrum)
│   │   ├── 波形示波器 (Oscilloscope)
│   │   └── 波形 (Waveform)
│   ├── 播放列表管理器 / 过滤面板 / 封面面板
│   ├── 简介视图 / 项目属性
│   └── 专辑列表面板
│
├── 播放 (Playback)
│   ├── 播放/暂停/停止/下一首/上一首
│   ├── 播放顺序 (Playback Order)
│   │   ├── 默认/随机播放/随机播放(音轨/专辑/文件夹)
│   │   └── 重复(列表/单曲/全部)
│   ├── 当前曲目结束后停止
│   ├── 静音/增大音量/减小音量
│   ├── 回放增益 (ReplayGain)
│   │   ├── 使用专辑增益/音轨增益
│   │   ├── 写入专辑增益/音轨增益
│   │   └── 专辑峰值/音轨峰值
│   ├── 加入队列/作为下一首/随机加入
│   ├── 切换到播放列表
│   ├── 播放统计
│   │   ├── 显示正在播放
│   │   ├── 显示最近播放/最近添加
│   │   ├── 配置...
│   │   ├── 监控正在播放的曲目
│   │   └── 导出/导入 统计数据
│   ├── 播放跟随光标/光标跟随播放
│   └── ──── 其他 ────
│       ├── 重复播放（列表/单曲）
│       └── 停止后 (Stop After Current)
│
├── 媒体库 (Library)
│   ├── 搜索 (Search)
│   ├── 专辑列表 (Album List)
│   ├── 从媒体库移除 (Remove from Library)
│   ├── 重新扫描媒体库 (Rescan Library)
│   ├── 配置... (Configure...)
│   ├── 移除无效条目 (Remove Dead Items)
│   └── 移除重复项 (Remove Duplicates)
│
├── 窗口 (Window)
│   ├── 最小化/缩放
│   ├── 关闭窗口/全部置于顶层
│   ├── 显示全部/隐藏其他
│   ├── 隐藏 foobar2000
│   └── 窗口靠左/靠右
│
└── 帮助 (Help)
    └── 关于 foobar2000 / 检查更新
```

### 3.2 偏好设置架构树

```
偏好设置 (Preferences)
├── 显示 (Display)
│   ├── 默认用户界面 / 分栏界面
│   ├── 主题 / 颜色和字体
│   ├── 标题栏 / 状态栏 / 工具栏 / 侧边栏
│   ├── 窗口框架 / 透明度 / 模糊 / 不透明度
│   ├── 可视化 (Visualizations)
│   │   └── 可视化刷新率 (Mac OS 14+)
│   ├── 专辑封面 (Album Art)
│   │   ├── 最大外部封面大小 (MB)
│   │   ├── 嵌入 vs 外部
│   │   └── 优先：大尺寸 / 外部 / 嵌入
│   └── 标题显示格式 / 多行字段 / 多值字段 / 标准字段
│
├── 播放 (Playback)
│   ├── 淡入淡出 / 交叉淡出
│   ├── 前置放大器 / 处理模式
│   ├── 源模式：音轨 / 专辑
│   ├── 根据峰值防止削波
│   ├── ShoutCast / HTTP 代理 / HTTPS 证书
│   ├── 附加解码 (DTS / HDCD 等)
│   ├── 手动切歌时快速重置 DSP / 清除播放队列
│   ├── 专辑分组模式 / 排序模式
│   ├── 手动选择音轨时重新洗牌
│   ├── 慢速但精准跳转
│   ├── 智能停止（锁屏/键盘）
│   ├── 验证已播放曲目完整性
│   └── 远程文件预读 / 本地文件预读
│
├── 输出 (Output)
│   ├── 输出设备 / 缓冲长度
│   ├── 输出格式 / 采样率 / 位深度
│   └── 声道配置
│
├── DSP 管理器 (DSP Manager)
│   ├── 可用 DSP 列表
│   │   ├── 下混到单声道/立体声
│   │   ├── 上混到 5.1/7.1/3.0/4.0/5.0/6.0
│   │   ├── 合唱 / 增益/缩放
│   │   ├── 重采样器 (ARDFTSRC / Speex)
│   │   ├── 经典回放增益 / 数字峰值
│   │   ├── 单声道转立体声 / 立体声转4声道
│   │   ├── 直流偏移 / 硬 -6dB 限制器
│   │   ├── Meier 交叉馈送 / 反转立体声声道
│   │   ├── 旋转声道 / 采样偏移 / 设置采样率
│   │   └── 跳过静音 / 前后声道互换
│   ├── 活动 DSP 列表
│   └── 操作：上移 / 下移 / 配置 / 恢复 / 重置
│
├── 组件 (Components)
│   └── 已安装组件列表 / 管理
│
├── 网络 (Network)
│   ├── 代理服务器 (HTTP / SOCKS)
│   ├── 远程控制 (Remote Control)
│   ├── 串流到设备 (Streaming)
│   ├── UPnP 媒体服务器 / 媒体渲染器 / 音量控制
│   └── 已保存的密码
│
├── 键盘快捷键 (Keyboard Shortcuts)
│   ├── 全局 / 筛选列表
│   ├── 按键 / 操作 / 描述
│   └── 新增 / 编辑 / 重置 / 导入 / 导出
│
├── Shell 集成 (Shell Integration)
│   ├── 启用 Shell 集成
│   ├── 右键菜单命令
│   └── 管理文件类型关联
│
└── 高级 (Advanced)
    ├── 进程优先级 (正常/高/低)
    ├── 全文件缓冲 / 缓冲上限
    ├── FFmpeg 解码器选项 / 线程数
    ├── 缓冲 (Buffering) 设置
    ├── ID3v2 版本与特性
    │   ├── 写入 ID3v2.3 (兼容性更好)
    │   ├── 写入 ID3v2.4 (兼容性较差)
    │   ├── 使用填充
    │   ├── TPE2 映射为专辑艺术家
    │   └── 兼容的日期帧 / TXXX 评分
    ├── Opus 头部增益
    ├── SoundCheck 目标响度
    │   ├── iTunes 标准 (-16dB LUFS)
    │   └── 回放增益标准 (-18dB LUFS)
    ├── Vorbis & FLAC 元数据写入模式
    ├── ReplayGain 扫描器
    │   ├── 扫描线程数 / 增益应用线程数
    │   ├── 读取大小 (MB)
    │   └── 峰值超过时失败
    ├── 文件操作工具
    │   ├── 文件完整性校验器 / 最大线程数
    │   ├── 空文件夹检测
    │   └── 删除方式 / 保留 / 提示
    ├── 搜索索引
    │   ├── 简单搜索 / 非对称匹配
    │   ├── 排除字段 / 限定搜索字段
    │   └── 搜索索引字段
    ├── 播放统计自动同步
    └── 检查更新 / Beta 版本 / EXTM3U 播放列表
```

### 3.3 交互逻辑说明

foobar2000 的交互逻辑有几个重要特点：

1. **菜单即操作**：主菜单不仅是导航，更是操作的**直接入口**（如播放/暂停/下一首等）
2. **右键上下文驱动**：在不同区域（播放列表/专辑列表/音轨）右键，菜单内容动态变化
3. **DSP 链式处理**：DSP 管理器采用"可用 → 活动"的双栏设计，活动 DSP 按顺序链式处理音频
4. **偏好设置分层**：左侧树形分类导航，右侧内容面板即时切换
5. **布局系统**：用户可以创建多个布局预设，在实时编辑模式下拖拽调整

---

## 4. 汉化方案 —— 三层体系

### 4.1 方案总览

由于 foobar2000 的特殊架构，单层方案无法完成完整汉化。最终采用 **三层叠加** 策略：

```
汉化效果 = NIB 文件改写 + 运行时 Hook + Localizable.strings
```

### 4.2 第一层：NIB 文件改写（PASS 1 — 底座层）

**原理**：macOS 的 `.nib` 文件是 NIBArchive 格式的二进制文件，包含序列化的 `NSKeyedArchiver` 数据。通过 Python 的 `nibarchive` 库可以解析和重写。

**工具**：[fb2k_zh_rebuild_v4.py](nib_patches/fb2k_zh_rebuild_v4.py)

**流程**：
1. 递归遍历 NIB 对象树的 ivars/values
2. 匹配 `NSString` 类型的值（英文字母组合）
3. 查翻译字典替换为中文
4. 重建 NIB 文件的 values 段（变长 varint 编码）
5. 额外处理 `NSLocalizableString` 对象

**覆盖**：146 个 NIB 文件，约 4796 个字符串

### 4.3 第二层：运行时 Hook（PASS 2 — 核心层）

**原理**：通过修改 foobar2000 的 Mach-O 二进制文件，添加 `LC_LOAD_DYLIB` 加载指令，使程序启动时强制加载自定义 dylib。dylib 利用 Objective-C 运行时进行 **Method Swizzling（方法交换）**。

**工具链**：
- `insert_dylib.c` — 自研 Mach-O 注入工具（支持 Fat Binary）
- `fb2k_hook_v3.m` — 核心 Hook 实现（10 个 AppKit 方法 + 570 条翻译字典）

**被 Hook 的 AppKit 方法**：

| 方法 | 作用 | 触发时机 |
|------|------|---------|
| `NSMenuItem.setTitle:` | 菜单标题 | 菜单初始化时 |
| `NSMenuItem.setAttributedTitle:` | 富文本菜单标题 | 带格式菜单 |
| `NSMenuItem.initWithTitle:` | 菜单创建 | 新菜单项创建时 |
| `NSButton.setTitle:` | 按钮标签 | 按钮显示时 |
| `NSButton.setAlternateTitle:` | 备用按钮标签 | 状态切换时 |
| `NSTextField.setStringValue:` | 文本字段 | 文字设置时 |
| `NSTextField.setPlaceholderString:` | 占位符 | 输入框提示 |
| `NSTabViewItem.setLabel:` | 标签页标题 | 切换标签时 |
| `NSBox.setTitle:` | 分组框标题 | 分组框显示时 |
| `NSWindow.setTitle:` | 窗口标题 | 窗口打开时 |

**翻译引擎**：

```objc
static NSString* T(NSString* s) {
    NSString* r = gMap[s];  // 从 570 条映射字典中查找
    return r ?: s;          // 有翻译→中文，无翻译→原文
}
```

**定时轮询机制**：
```
NSApplicationDidFinishLaunching
    → 7 阶段延时（0.2s / 0.5s / 1s / 2s / 4s / 8s / 15s）
    → 每 2 秒定时器持续轮询
    → NSMenuDidAddItemNotification / NSMenuDidChangeItemNotification
```

### 4.4 第三层：Localizable.strings（PASS 3 — 辅助层）

**原理**：macOS 应用通过 `NSLocalizableString(key, comment)` 机制在 `lproj` 目录中查找翻译。

**文件**：`zh-Hans.lproj/Localizable.strings`（68 条）

### 4.5 三层关系图

```
┌─────────────────────────────────────────────────────────┐
│              用户看到的界面 = 中文 ✅                      │
│                                                         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  第三层：Localizable.strings（辅助兜底）            │  │
│  │  NSLocalizableString 机制 → 68 条系统级翻译        │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                 │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │  第二层：运行时 Hook（核心，覆盖动态 UI）            │  │
│  │  10 个 AppKit 方法 Swizzling + 570 条翻译字典      │  │
│  │  ↓ 拦截 setTitle:/setStringValue:/setLabel: 等调用  │  │
│  └────────────────────┬──────────────────────────────┘  │
│                       │                                 │
│  ┌────────────────────▼──────────────────────────────┐  │
│  │  第一层：NIB 文件改写（底座，覆盖静态 UI）            │  │
│  │  Python nibarchive → 146 个 .nib → 4796 字符串     │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 5. 实施步骤详解

### 5.1 完整实施流程

```
阶段 0：分析
├── 提取 foobar2000 所有 NIB 文件中的字符串
├── 用 strings 命令提取 Mach-O __cstring 段的菜单字符串
├── 对比字符串差异，确定汉化范围
└── 测试多种汉化方案（NIB 改写 / binary 替换 / DYLD 注入）

阶段 1：NIB 汉化
├── 编写 fb2k_zh_rebuild.py（NIB 解析+改写引擎）
├── 构建中英文翻译映射表
├── 批量处理 146 个 NIB 文件
├── 测试发现：菜单未汉化（C++ 动态创建）
└── v4 修复：追加 NSLocalizableString 支持

阶段 2：二进制注入
├── 发现 DYLD_INSERT_LIBRARIES 被 SIP 阻止
├── 编写 insert_dylib.c（Mach-O LC_LOAD_DYLIB 注入工具）
├── 编译 fb2k_hook_v3.dylib（10 个 AppKit 方法 Hook）
├── 注入 → 重签 → 启动
└── 验证：菜单/按钮/标签全部成功拦截

阶段 3：迭代完善
├── v3.0 → v3.3，逐步增加翻译条目（50 → 250 → 380 → 450 → 570）
├── 每版根据用户反馈补充缺失翻译
├── 优化定时轮询机制
└── 增加通知监听响应动态菜单
```

### 5.2 首次部署步骤

```bash
# 1. 关闭 foobar2000
pkill -x foobar2000 2>/dev/null; sleep 1

# 2. 部署 dylib（核心）
sudo cp deploy/fb2k_hook_v3.dylib /Applications/foobar2000.app/Contents/MacOS/

# 3. 部署本地化字符串
sudo mkdir -p /Applications/foobar2000.app/Contents/Resources/zh-Hans.lproj
sudo cp deploy/zh-Hans.lproj/Localizable.strings /Applications/foobar2000.app/Contents/Resources/zh-Hans.lproj/

# 4. 注入 LC_LOAD_DYLIB（首次需要，后续只需替换 dylib）
sudo cp deploy/insert_dylib /usr/local/bin/
sudo insert_dylib @executable_path/fb2k_hook_v3.dylib \
    /Applications/foobar2000.app/Contents/MacOS/foobar2000 \
    /Applications/foobar2000.app/Contents/MacOS/foobar2000_patched
sudo mv /Applications/foobar2000.app/Contents/MacOS/foobar2000_patched \
    /Applications/foobar2000.app/Contents/MacOS/foobar2000

# 5. 重签名
sudo codesign --force --deep --sign - /Applications/foobar2000.app

# 6. 启动
open /Applications/foobar2000.app
```

---

## 6. 技术难点与解决方案

### 难点 1：SIP 阻止 DYLD 注入

**现象**：设置 `DYLD_INSERT_LIBRARIES` 环境变量后，foobar2000 启动时 dylib 不被加载（SIP 会清除该环境变量）。

**解决**：直接修改 Mach-O 二进制文件，添加 `LC_LOAD_DYLIB` 指令。这相当于**永久性地将 dylib 注册为二进制文件的依赖**，绕过 SIP 检查。

关键代码（insert_dylib.c）：
```c
// 在 Fat Binary 的每个架构中添加 LC_LOAD_DYLIB
struct dylib_command dc = {
    .cmd = LC_LOAD_DYLIB,
    .cmdsize = sizeof(struct dylib_command) + name_size,
    .dylib = {
        .name.offset = sizeof(struct dylib_command),
        .timestamp = 2,
        .current_version = 0,
        .compatibility_version = 0
    }
};
// 还要先移除 LC_CODE_SIGNATURE 防止签名冲突
```

### 难点 2：颜色被破坏

**现象**：NIB 改写后，界面颜色变为灰白色，选中项变黑色。

**原因**：翻译映射表中包含了 `"System"` 这样的短词，这些词在 NIB 中同时也是颜色/字体/系统控件的标识符。NIB 改写引擎无差别替换了所有匹配 `[A-Za-z]{2,}` 模式的字符串。

**解决**：从翻译映射表中移除 `"System"` 等危险短词，增加最小长度校验。

### 难点 3：右侧滑动子菜单不翻译

**现象**：主菜单翻译成功，但鼠标指向某些菜单项时滑出的子菜单仍然是英文。

**原因**：这些子菜单在菜单渲染的**更晚阶段**才动态创建，单次遍历无法覆盖。

**解决**：引入多阶段遍历机制：
- 7 阶段延时触发（0.2s → 0.5s → 1s → 2s → 4s → 8s → 15s）
- 持续定时轮询（每 2 秒）
- 监听 `NSMenuDidAddItemNotification` 和 `NSMenuDidChangeItemNotification`

### 难点 4：设置窗口部分不翻译

**现象**：偏好设置窗口部分汉化成功，部分仍然是英文。

**原因**：设置窗口使用了多种控件类型——NSButton、NSTextField、NSTabViewItem、NSBox、NSSegmentedControl 等。初版只 Hook 了 NSMenuItem。

**解决**：从 3 个 Hook 扩展到 10 个 Hook，覆盖所有 AppKit 常见控件类型，并添加 `translate_view()` 递归遍历窗口的 `contentView` 子视图树。

---

## 7. 汉化经验总结

### 7.1 经验教训

1. **不要猜测架构**：最初以为 foobar2000 和其他 macOS 应用一样，修改 NIB 文件就能全部汉化。直到部署后发现菜单仍是英文，才去深入分析发现 C++ 动态创建菜单的机制。在动工之前先用 `otool`、`strings`、`class-dump` 等工具充分分析二进制。

2. **短词是地雷**：英文中的短词（如 "System"、"OK"、"No"、"On"）在 NIB 文件中可能同时代表颜色名、布尔值、系统标识符。无差别替换这些词会破坏应用功能。解决方案：对短词（≤4 字符）单独评估，必要时从 NIB 翻译中排除。

3. **SIP 是硬墙但不是绝路**：macOS 的 System Integrity Protection 会阻止 `DYLD_INSERT_LIBRARIES`，但可以通过直接修改 Mach-O 文件添加 `LC_LOAD_DYLIB` 来绕过。代价是每次应用更新都需要重新注入。

4. **翻译字典是增量迭代的**：不要试图一次性完成全部翻译。先用核心 50 条覆盖主要菜单，然后根据实际使用中发现的问题逐步补充。用户反馈是最高效的 QA 方式。

5. **日志是最佳调试工具**：在 dylib 中记录详细的翻译日志（写入 `/tmp/fb2k_zh_v3.log`）可以快速定位哪些字符串匹配失败、哪些控件类型未被覆盖。

### 7.2 推荐方法论

```
对任意 macOS 应用的汉化，推荐按此流程：
1. strings 提取二进制字符串 → 评估是否 C++ 动态创建
2. NIB 文件分析 → 检查 nibarchive 可解析性
3. 优先尝试 .strings 文件（最安全）
4. NIB 改写（次选，注意短词风险）
5. 运行时 Hook（最后手段，但不依赖 SIP 关闭）
6. 三层叠加 + 迭代完善（最彻底）
```

### 7.3 与 Windows 版汉化的对比

| 方面 | Windows 版 | macOS 版 |
|------|-----------|---------|
| 汉化方式 | 反编译资源 DLL，直接替换字符串表 | 运行时钩子 + NIB 改写 |
| 难度 | 较易（资源文件独立） | 较难（UI 由 C++ 动态创建） |
| 工具链 | Resource Hacker / Restorator | nibarchive + ObjC Runtime |
| 持久性 | 替换文件即永久 | LC_LOAD_DYLIB 永久，更新后需恢复 |
| 参考项目 | Asion 汉化版 | 本项目为首个公开方案 |

---

## 8. 版本升级后的处理

### 8.1 升级后会发生什么

foobar2000 版本升级时：
1. 主二进制文件被替换 → LC_LOAD_DYLIB 加载指令丢失
2. NIB 文件被替换 → 中文改写丢失
3. `zh-Hans.lproj` 文件夹可能被删除

**结果**：foobar2000 恢复为全英文。

### 8.2 一键恢复

汉化包附带了 `restore_foobar2000_zh.sh` 恢复脚本，执行一次即可恢复全部汉化：

```bash
bash /path/to/restore_foobar2000_zh.sh
```

脚本自动完成：关闭 app → 复制 dylib → 部署 lproj → 注入 LC_LOAD_DYLIB → 重签 → 启动。

---

## 9. 文件清单

### 汉化包结构

```
foobar2000-zh-hans/          ← GitHub 仓库根目录
├── README.md                ← 中英双语说明文档
├── LICENSE                  ← GPL v3 + 非商业条款
├── CHANGELOG.md             ← 完整版本更新日志
├── VERSION                  ← 版本信息
├── .gitignore
│
├── deploy/                  ← 部署文件（直接运行）
│   ├── fb2k_hook_v3.dylib   ★ 核心：运行时 Hook 动态库
│   ├── insert_dylib          ★ Mach-O 注入工具（编译版）
│   ├── deploy.sh             ★ 一键部署脚本
│   └── zh-Hans.lproj/
│       └── Localizable.strings  本地化字符串
│
├── restore/
│   └── restore_foobar2000_zh.sh  ★ 版本升级恢复脚本
│
├── src/                     ← 全部源代码
│   ├── fb2k_hook_v3.m       ★ 核心：10 个 AppKit 方法 Hook + 570 条翻译字典
│   ├── fb2k_hook_v2.m          v2 版 Hook（历史版本）
│   ├── insert_dylib.c          Mach-O LC_LOAD_DYLIB 注入工具源码
│   ├── finalize_v3.py          dylib 路径二进制替换工具
│   ├── find_missing_cstrings.py 二进制字符串提取工具
│   └── extract_all_strings.py   字符串提取工具
│
├── nib_patches/
│   └── fb2k_zh_rebuild_v4.py  NIB 文件批量汉化引擎
│
└── docs/
    └── architecture.md       完整技术架构文档
```

### 版本对照

| 汉化包版本 | 翻译条目数 | 说明 |
|-----------|-----------|------|
| v1.0 | ~4800 (NIB) | NIB 文件直接改写 |
| v2.0 | ~50 | 初版 Hook |
| v3.0 | ~250 | 10 个 Hook + 定时轮询 |
| v3.1 | ~380 | 新增 ReplayGain/Enqueue/可视化 |
| v3.2 | ~450 | 新增网络/UPnP/ReFacets/统计 |
| v3.3 | ~570 | 新增过滤器/音频格式/DSP/显示/解码/播放/缓冲/MP3/Opus/SoundCheck/工具/搜索 |

---

## 附录：获取帮助

- **GitHub 仓库**：[github.com/lz123xiansheng/foobar2000-zh-hans](https://github.com/lz123xiansheng/foobar2000-zh-hans)
- **报告问题**：在 GitHub 上提 Issue
- **调试日志**：`/tmp/fb2k_zh_v3.log`
- **适用版本**：foobar2000 v2.26 (macOS) — 未来版本可能需要适配

---

> **最后更新时间**：2026-05-10  
> **汉化作者**：lz123xiansheng  
> **开源许可**：GNU General Public License v3.0 with Non-Commercial Clause