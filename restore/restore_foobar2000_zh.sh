#!/bin/bash
set -e

# ======================================================
# foobar2000 中文汉化包 — 版本升级后一键恢复脚本
# 适用版本: foobar2000 v2.26 (macOS)
# 汉化包版本: v3.3
# 
# 使用方法:
#   bash restore_foobar2000_zh.sh
#   
# 说明:
#   当 foobar2000 通过 App Store 或手动更新后，
#   汉化会被覆盖。运行此脚本一键恢复中文。
# ======================================================

# ====== 配置区 ======
# 如果 dylib 文件不在脚本同级目录，请修改以下路径
DYLIB_PATH="$(cd "$(dirname "$0")" && pwd)/fb2k_hook_v3.dylib"

# 如果是从 restore/ 目录运行，自动寻找上级 deploy/ 目录
if [ ! -f "$DYLIB_PATH" ]; then
    PARENT="$(cd "$(dirname "$0")/.." && pwd)"
    if [ -f "$PARENT/deploy/fb2k_hook_v3.dylib" ]; then
        DYLIB_PATH="$PARENT/deploy/fb2k_hook_v3.dylib"
    fi
fi
# ===================

FOOBAR_APP="/Applications/foobar2000.app"
MAIN_BIN="$FOOBAR_APP/Contents/MacOS/foobar2000"
DYLIB_DEST="$FOOBAR_APP/Contents/MacOS/fb2k_hook_v3.dylib"
LPROJ_SRC="$(cd "$(dirname "$0")/.." && pwd)/deploy/zh-Hans.lproj/Localizable.strings"
LPROJ_DEST="$FOOBAR_APP/Contents/Resources/zh-Hans.lproj"
INJECTOR="$(cd "$(dirname "$0")/.." && pwd)/deploy/insert_dylib"

echo "============================================"
echo " foobar2000 中文汉化包 v3.3 — 恢复工具"
echo " 版本升级后一键恢复"
echo "============================================"
echo ""

# Step 0: 检查
if [ ! -d "$FOOBAR_APP" ]; then
    echo "[错误] 未找到 foobar2000.app，请先安装 foobar2000"
    exit 1
fi
if [ ! -f "$DYLIB_PATH" ]; then
    echo "[错误] 未找到 fb2k_hook_v3.dylib"
    echo "请确保该脚本与 dylib 文件在同一目录"
    exit 1
fi

# Step 1: 关闭 foobar2000
echo "[1/5] 关闭 foobar2000..."
pkill -x foobar2000 2>/dev/null && sleep 1 || echo "(未运行)"
echo "  ✓"

# Step 2: 部署 dylib
echo "[2/5] 部署 fb2k_hook_v3.dylib..."
cp "$DYLIB_PATH" "$DYLIB_DEST"
echo "  ✓ $DYLIB_DEST"

# Step 3: 部署本地化文件
echo "[3/5] 部署中文本地化文件..."
if [ -f "$LPROJ_SRC" ]; then
    mkdir -p "$LPROJ_DEST"
    cp "$LPROJ_SRC" "$LPROJ_DEST/"
    echo "  ✓ Localizable.strings"
else
    echo "  ⚠ 未找到 Localizable.strings（跳过，不影响主要汉化）"
fi

# Step 4: 注入 LC_LOAD_DYLIB
echo "[4/5] 注入 LC_LOAD_DYLIB..."
if otool -L "$MAIN_BIN" 2>/dev/null | grep -q "fb2k_hook_v3.dylib"; then
    echo "  ✓ 已存在，无需重复注入"
else
    if [ ! -f "$INJECTOR" ]; then
        echo "  [错误] 未找到 insert_dylib 工具"
        echo "  请先从项目仓库下载: https://github.com/lz123xiansheng/foobar2000-zh-hans"
        exit 1
    fi
    "$INJECTOR" "@executable_path/fb2k_hook_v3.dylib" "$MAIN_BIN" "$MAIN_BIN.patched"
    mv "$MAIN_BIN.patched" "$MAIN_BIN"
    echo "  ✓ 注入完成"
fi

# Step 5: 重签名
echo "[5/5] 重签名..."
sudo codesign --force --deep --sign - "$FOOBAR_APP" 2>/dev/null || echo "  ⚠ 重签名失败（不影响运行）"
echo "  ✓"

echo ""
echo "============================================"
echo " 恢复完成！正在启动 foobar2000..."
echo "============================================"
open "$FOOBAR_APP"
echo ""
echo "如果遇到问题，请检查日志: /tmp/fb2k_zh_v3.log"