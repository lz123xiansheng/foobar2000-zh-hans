#!/bin/bash
set -e

# ======================================================
# foobar2000 中文汉化包 — 部署脚本
# 适用版本: foobar2000 v2.26 (macOS)
# 汉化包版本: v3.3
# ======================================================

PKG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FOOBAR_APP="/Applications/foobar2000.app"
DYLIB_DEST="$FOOBAR_APP/Contents/MacOS/fb2k_hook_v3.dylib"
MAIN_BIN="$FOOBAR_APP/Contents/MacOS/foobar2000"
LPROJ_DEST="$FOOBAR_APP/Contents/Resources/zh-Hans.lproj"

echo "============================================"
echo " foobar2000 中文汉化包 v3.3 — 部署工具"
echo "============================================"
echo ""

# 检查 foobar2000 是否已安装
if [ ! -d "$FOOBAR_APP" ]; then
    echo "[错误] 未找到 foobar2000.app，请先安装 foobar2000"
    exit 1
fi

# 关闭正在运行的 foobar2000
echo "[步骤 1/5] 关闭 foobar2000..."
pkill -x foobar2000 2>/dev/null && sleep 1 || echo "(未运行)"
echo "  ✓ 已关闭"

# 部署动态库
echo "[步骤 2/5] 部署 fb2k_hook_v3.dylib..."
cp "$PKG_DIR/deploy/fb2k_hook_v3.dylib" "$DYLIB_DEST"
echo "  ✓ 已部署到: $DYLIB_DEST"

# 部署本地化文件
echo "[步骤 3/5] 部署中文本地化文件..."
mkdir -p "$LPROJ_DEST"
cp "$PKG_DIR/deploy/zh-Hans.lproj/Localizable.strings" "$LPROJ_DEST/"
echo "  ✓ 已部署到: $LPROJ_DEST/Localizable.strings"

# 检查是否需要注入 LC_LOAD_DYLIB
echo "[步骤 4/5] 检查 LC_LOAD_DYLIB 注入状态..."
if otool -L "$MAIN_BIN" 2>/dev/null | grep -q "fb2k_hook_v3.dylib"; then
    echo "  ✓ LC_LOAD_DYLIB 已存在，无需重新注入"
else
    echo "  → 需要注入 LC_LOAD_DYLIB..."
    INJECTOR="$PKG_DIR/deploy/insert_dylib"
    if [ ! -f "$INJECTOR" ]; then
        echo "  [错误] 未找到 insert_dylib 工具"
        exit 1
    fi
    "$INJECTOR" "@executable_path/fb2k_hook_v3.dylib" "$MAIN_BIN" "$MAIN_BIN.patched"
    mv "$MAIN_BIN.patched" "$MAIN_BIN"
    echo "  ✓ LC_LOAD_DYLIB 注入完成"
fi

# 重签名
echo "[步骤 5/5] 重签名..."
sudo codesign --force --deep --sign - "$FOOBAR_APP" 2>/dev/null || echo "  ⚠ 重签名失败（不影响使用，可能触发系统安全提示）"
echo "  ✓ 重签名完成"

echo ""
echo "============================================"
echo " 部署成功！正在启动 foobar2000..."
echo "============================================"
open "$FOOBAR_APP"

echo ""
echo "日志文件: /tmp/fb2k_zh_v3.log"
echo "如需查看调试信息: tail -f /tmp/fb2k_zh_v3.log"