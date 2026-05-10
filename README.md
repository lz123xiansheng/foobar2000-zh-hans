# foobar2000 中文汉化包 (Chinese Localization Pack)

[![License](https://img.shields.io/badge/License-GPL%20v3%20%2B%20NC-blue)](LICENSE)

适用于 foobar2000 **v2.26** (macOS) 的完整中文汉化方案。

For foobar2000 **v2.26** (macOS) — Complete Chinese localization solution.

---

## 功能特点 / Features

- 主菜单全汉化（文件/编辑/视图/播放/媒体库/帮助/窗口）
- 偏好设置窗口 ~95% 汉化覆盖
- 右键菜单、DSP管理器、均衡器、转换器完整汉化
- 播放统计、网络设置、UPnP、ReFacets 等高级功能汉化
- 重启电脑不影响，翻译永久生效

---

## 快速开始 / Quick Start

### 一键部署 / One-Click Deploy

```bash
# 1. 关闭 foobar2000
pkill -x foobar2000 2>/dev/null; sleep 1

# 2. 部署汉化包
sudo cp deploy/fb2k_hook_v3.dylib /Applications/foobar2000.app/Contents/MacOS/

# 3. 部署本地化文件
sudo mkdir -p /Applications/foobar2000.app/Contents/Resources/zh-Hans.lproj
sudo cp deploy/zh-Hans.lproj/Localizable.strings /Applications/foobar2000.app/Contents/Resources/zh-Hans.lproj/

# 4. 注入动态库加载指令
sudo cp deploy/insert_dylib /usr/local/bin/
sudo insert_dylib @executable_path/fb2k_hook_v3.dylib /Applications/foobar2000.app/Contents/MacOS/foobar2000 /Applications/foobar2000.app/Contents/MacOS/foobar2000_patched
sudo mv /Applications/foobar2000.app/Contents/MacOS/foobar2000_patched /Applications/foobar2000.app/Contents/MacOS/foobar2000

# 5. 重签
sudo codesign --force --deep --sign - /Applications/foobar2000.app

# 6. 启动
open /Applications/foobar2000.app
```

> **注意**：如果之前已经部署过汉化，只需替换 dylib 文件即可（第 1-2 步 + 第 5 步），无需重复注入。

---

## 技术架构 / Architecture

本项目采用 **三层汉化体系**：

| 层级 | 技术 | 覆盖范围 |
|------|------|---------|
| NIB 文件改写 | Python nibarchive 库解析改写 .nib 文件 | 对话框、静态文本、按钮标签 |
| 运行时 Hook | Objective-C Method Swizzling + LC_LOAD_DYLIB | 动态菜单、程序化创建的 UI |
| Localizable.strings | macOS 标准本地化机制 | NSLocalizableString 系统文本 |

核心文件：

```
foobar2000-zh-hans/
├── deploy/               # 部署文件（dylib / 本地化字符串 / 注入工具）
│   ├── fb2k_hook_v3.dylib    # ★ 核心：运行时 Hook 动态库
│   ├── insert_dylib           # Mach-O 注入工具（编译版）
│   └── zh-Hans.lproj/         # 本地化字符串文件
├── src/                  # 全部源代码
│   ├── fb2k_hook_v3.m        # ★ 核心源码：10 个 AppKit 方法 Hook
│   ├── insert_dylib.c         # Mach-O 注入工具源码
│   ├── finalize_v3.py         # dylib 引用替换工具
│   └── find_missing_cstrings.py  # 二进制字符串提取工具
├── nib_patches/          # NIB 文件改写工具
│   └── fb2k_zh_rebuild_v4.py  # NIB 批量汉化引擎
├── restore/              # 版本升级后恢复脚本
│   └── restore_foobar2000_zh.sh
└── docs/
    └── architecture.md        # 完整技术文档
```

---

## 版本升级后恢复 / After App Update

更新 foobar2000 后，汉化会被覆盖。运行恢复脚本一键恢复：

```bash
bash restore/restore_foobar2000_zh.sh
```

脚本会自动完成全部部署步骤。

---

## 开源许可 / License

[GNU General Public License v3.0 with Non-Commercial Clause](LICENSE)

- ✅ 自由下载使用
- ✅ 自由修改和分发
- ❌ 禁止商业用途
- ✅ 二次开发后必须开源

---

## 致谢 / Credits

- [foobar2000](https://www.foobar2000.org/) — 优秀的音频播放器
- [nibarchive](https://pypi.org/project/nibarchive/) — NIB 文件解析库
- 汉化作者：lz123xiansheng

---

**适用版本**: foobar2000 v2.26 (build 46) macOS  
**汉化包版本**: v3.3  
**发布日期**: 2026-05-10