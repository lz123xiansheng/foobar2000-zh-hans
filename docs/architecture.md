# foobar2000 中文汉化 — 技术架构文档

## 概述

foobar2000 macOS 版的界面由两层系统构成：
1. **NIB 文件**（编译过的 XML）：存储对话框、静态标签、窗口布局
2. **C++ 代码动态创建**：主菜单栏、大部分右键菜单、偏好设置面板由 C++ 代码在运行时通过 AppKit API 创建

这使得传统的 `.strings` 本地化文件无法覆盖全部界面，需要多层方案。

---

## 方案一：NIB 文件改写（底层覆盖）

### 原理
macOS 的 `.nib` 文件是 NIBArchive 格式的二进制文件，包含序列化的 `NSKeyedArchiver` 数据。通过 [nibarchive](https://pypi.org/project/nibarchive/) Python 库可以解析和重写。

### 关键代码
- `nib_patches/fb2k_zh_rebuild_v4.py`

### 处理流程
1. 用 nibarchive 递归遍历所有 NIB 对象的 ivars/values
2. 匹配 `NSString` 类型的值（字符串内容为英文字母组合）
3. 查翻译字典替换为中文
4. 重建 NIB 文件的 values 段（变长 varint 编码）
5. 处理 `NSLocalizableString` 对象（包含 key 和 table 两个 NSString）

### 覆盖范围
- 静态对话框（打开文件、属性、关于等）
- 窗口内固定标签
- 按钮默认标题
- 约 4796 个字符串

### 局限性
主菜单、右键菜单仍为英文 → 需要用方案二

---

## 方案二：运行时 Hook（核心方案）

### 原理
通过修改 foobar2000 的 Mach-O 二进制文件，添加 `LC_LOAD_DYLIB` 加载指令，使程序启动时自动加载自定义的动态库（dylib），然后利用 Objective-C 运行时进行 Method Swizzling。

### 注入工具
- `src/insert_dylib.c` — 自研 Mach-O 注入工具
- 支持 Fat Binary（同时处理 x86_64 + arm64）
- 自动移除 `LC_CODE_SIGNATURE` 防止签名校验冲突

### Hook 架构
- 文件: `src/fb2k_hook_v3.m`
- 使用 `__attribute__((constructor))` 在 dylib 加载时自动执行
- 利用 `class_getInstanceMethod` + `method_setImplementation` 进行方法交换

### 被 Hook 的 10 个 AppKit 方法

| 类 | 方法 | 用途 |
|------|------|------|
| NSMenuItem | `setTitle:` | 菜单项标题 |
| NSMenuItem | `setAttributedTitle:` | 富文本菜单标题 |
| NSMenuItem | `initWithTitle:action:keyEquivalent:` | 菜单项创建 |
| NSButton | `setTitle:` | 按钮标签 |
| NSButton | `setAlternateTitle:` | 按钮备用标签 |
| NSTextField | `setStringValue:` | 文本字段 |
| NSTextField | `setPlaceholderString:` | 占位符文本 |
| NSTabViewItem | `setLabel:` | 标签页标题 |
| NSBox | `setTitle:` | 分组框标题 |
| NSWindow | `setTitle:` | 窗口标题 |

### 翻译引擎

```objc
static NSString* T(NSString* s) {
    NSString* r = gMap[s];
    return r ?: s;  // 有翻译返回翻译，无翻译返回原文
}
```

gMap 包含约 570 条 `英文:中文` 键值对。

### 定时轮询机制
- 每 2 秒遍历所有窗口和菜单
- NSApplicationDidFinishLaunchingNotification → 7 阶段延时遍历（0.2s/0.5s/1s/2s/4s/8s/15s）
- NSMenuDidAddItemNotification/NSMenuDidChangeItemNotification → 触发即时遍历

### 时间复杂度
- 窗口遍历：O(N×D)，N=控件数，D=嵌套深度（最大 12）
- 菜单遍历：O(M×D)，M=菜单项数，D=子菜单深度（最大 8）
- 字典查询：O(1)（NSDictionary hash lookup）

---

## 方案三：Localizable.strings（辅助层）

### 原理
macOS 应用会按 `NSLocalizableString(key, comment)` 的方式在 `lproj` 目录中查找翻译文件。

### 文件位置
`deploy/zh-Hans.lproj/Localizable.strings`

### 覆盖范围
约 68 条由 NSLocalizableString 机制加载的文本。

---

## 部署流程

```
1. 安装 foobar2000.app
2. 将 fb2k_hook_v3.dylib 拷贝到 MacOS/ 目录
3. 将 Localizable.strings 拷贝到 zh-Hans.lproj/ 目录
4. 用 insert_dylib 注入 LC_LOAD_DYLIB（首次部署需要，后续升级只需替换 dylib）
5. codesign --remove-signature + codesign --force --deep --sign -
6. 启动应用
```

## 版本升级后恢复流程

```
1. 新版 foobar2000 替换了主二进制 → LC_LOAD_DYLIB 丢失
2. 新版 foobar2000 替换了 NIB 文件 → 汉化丢失
3. 运行 restore_foobar2000_zh.sh
   a. 重新拷贝 dylib
   b. 重新注入 LC_LOAD_DYLIB
   c. 重新部署 NIB 改写
   d. 重新签名
```

## 关键文件说明

| 文件 | 作用 |
|------|------|
| `fb2k_hook_v3.m` | 核心 Hook 实现，包含翻译字典和所有 Hook 逻辑 |
| `insert_dylib.c` | Mach-O LC_LOAD_DYLIB 注入工具 |
| `fb2k_zh_rebuild_v4.py` | NIB 文件批量汉化引擎 |
| `finalize_v3.py` | 二进制中 dylib 路径替换工具 |
| `find_missing_cstrings.py` | 从 Mach-O 的 __cstring 段提取待翻译字符串 |

## 安全说明

- **SIP 绕过**: 通过直接修改二进制文件（添加 LC_LOAD_DYLIB）绕过 macOS SIP，无需关闭系统保护
- **代码签名**: 使用 ad-hoc 签名（`codesign -s -`），不影响 Gatekeeper 的基本运行
- **风险**: 修改受签名保护的应用程序可能在系统更新后被覆盖