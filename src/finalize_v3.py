#!/usr/bin/env python3
"""Replace v2 dylib reference with v3 in Mach-O binary (same path length)"""
import os, shutil, subprocess

SRC = "/Applications/foobar2000.app/Contents/MacOS/foobar2000"
DST = "/tmp/foobar2000_zh_v3/MacOS/foobar2000"
DLIB_SRC = "/Users/apple/vscode/fb2k_hook_v3.dylib"
DLIB_DST = "/tmp/foobar2000_zh_v3/MacOS/fb2k_hook_v3.dylib"
STRINGS_SRC = "/Users/apple/vscode/fb2k_zh_strings/Localizable.strings"
STRINGS_DST = "/tmp/foobar2000_zh_v3/Resources/zh-Hans.lproj/Localizable.strings"

os.makedirs(os.path.dirname(DST), exist_ok=True)
os.makedirs(os.path.dirname(STRINGS_DST), exist_ok=True)

# Read binary
with open(SRC, "rb") as f:
    data = f.read()

old = b"fb2k_hook_v2.dylib"
new = b"fb2k_hook_v3.dylib"
assert len(old) == len(new), f"Length mismatch: {len(old)} vs {len(new)}"

count = data.count(old)
print(f"Found {count} occurrences of v2 reference")

data = data.replace(old, new)

with open(DST, "wb") as f:
    f.write(data)

# Strip code signature
subprocess.run(["codesign", "--remove-signature", DST], check=False)

# Verify
r = subprocess.run(["otool", "-L", DST], capture_output=True, text=True)
has_v2 = False
has_v3 = False
for line in r.stdout.split("\n"):
    if "fb2k_hook_v3" in line:
        has_v3 = True
        print(f"  ✅ {line.strip()}")
    if "fb2k_hook_v2" in line:
        has_v2 = True
        print(f"  ❌ {line.strip()}")

# Copy dylib
shutil.copy2(DLIB_SRC, DLIB_DST)
# Copy strings
shutil.copy2(STRINGS_SRC, STRINGS_DST)

print(f"\n{'✅ ALL v3!' if has_v3 and not has_v2 else '⚠️ CHECK RESULT'}")
print(f"Binary: {DST}")
print(f"Dylib:  {DLIB_DST}")
print(f"Strings: {STRINGS_DST}")