#!/usr/bin/env python3
"""Extract ALL English strings from ALL NIB files + binary for comprehensive translation"""

import subprocess
import os
import sys
import re
from collections import defaultdict

NIB_DIR = "/Applications/foobar2000.app/Contents/Resources"
BINARY = "/Applications/foobar2000.app/Contents/MacOS/foobar2000"

# Import nibarchive
sys.path.insert(0, os.path.expanduser("~/Library/Python/3.11/lib/python/site-packages"))
sys.path.insert(0, "/Library/Python/3.11/lib/python/site-packages")

all_nib_strings = defaultdict(set)  # nib_name -> set of strings
all_strings = set()

# Extract from NIB files
try:
    from nibarchive import NIBArchive
except:
    try:
        from nibarchive.nibarchive import NIBArchive
    except:
        print("Cannot import nibarchive")
        sys.exit(1)

nib_files = sorted([f for f in os.listdir(NIB_DIR) if f.endswith('.nib')])
print(f"Processing {len(nib_files)} NIB files...")

for nib_name in nib_files:
    nib_path = os.path.join(NIB_DIR, nib_name)
    try:
        with open(nib_path, 'rb') as f:
            data = f.read()
        nib = NIBArchive(data)
        
        for obj in nib.objects:
            if not hasattr(obj, 'values'):
                continue
            for cn in obj.values.get('classes', []):
                if hasattr(cn, 'name') and cn.name in ('NSString', 'NSLocalizableString'):
                    if hasattr(cn, 'bytes'):
                        ns = cn.bytes.decode('utf-8', errors='replace')
                        s = ns.encode('ascii', errors='replace').decode('ascii')
                        # Only keep strings with actual English characters
                        if re.search(r'[A-Za-z]{2,}', ns):
                            all_nib_strings[nib_name].add(ns)
                            all_strings.add(ns)
    except Exception as e:
        pass  # Skip problematic files

# Extract from binary
print(f"\nExtracting strings from binary...")
strings_output = subprocess.run(['strings', BINARY], capture_output=True, text=True).stdout
binary_strings = set()
for s in strings_output.split('\n'):
    s = s.strip()
    if s and re.search(r'[A-Za-z]{2,}', s):
        # Filter out obviously non-UI strings (code symbols, paths, etc.)
        if not re.match(r'^[A-Z_]{3,}$', s):  # skip ALL_CAPS constants
            if not re.match(r'^[a-z_]+$', s):  # skip snake_case
                if not s.startswith('/'):  # skip paths
                    if not s.startswith('_'):  # skip internal symbols
                        if len(s) >= 2 and len(s) <= 80:
                            binary_strings.add(s)
                            all_strings.add(s)

print(f"\n=== Summary ===")
print(f"Total unique strings across all sources: {len(all_strings)}")
print(f"NIB files with strings: {len(all_nib_strings)}")
print(f"Binary strings: {len(binary_strings)}")

# Print by category
pref_nibs = [n for n in nib_files if 'Pref' in n or 'pref' in n or 'Config' in n or 'Properties' in n or 'Dialog' in n or 'About' in n or 'Setup' in n or 'Format' in n or 'Dialog' in n]
menu_nibs = ['MainMenu.nib']
other_nibs = [n for n in nib_files if n not in pref_nibs and n not in menu_nibs]

print(f"\n=== PREFERENCES/DIALOG NIBs ({len(pref_nibs)}) ===")
for n in sorted(pref_nibs):
    strings_set = all_nib_strings.get(n, set())
    if strings_set:
        print(f"\n--- {n} ({len(strings_set)} strings) ---")
        for s in sorted(strings_set)[:50]:
            print(f"  '{s}'")
        if len(strings_set) > 50:
            print(f"  ... ({len(strings_set) - 50} more)")

print(f"\n=== MAIN MENU NIB ===")
for n in menu_nibs:
    strings_set = all_nib_strings.get(n, set())
    if strings_set:
        print(f"\n--- {n} ({len(strings_set)} strings) ---")
        for s in sorted(strings_set):
            print(f"  '{s}'")

# Print binary strings that look like UI strings
print(f"\n=== BINARY UI STRINGS ===")
ui_strings = sorted([s for s in binary_strings if any(
    keyword in s for keyword in [
        'File', 'Edit', 'View', 'Play', 'Library', 'Media', 'Album',
        'Track', 'Playlist', 'Format', 'Convert', 'Output', 'Device',
        'Setting', 'Option', 'Sound', 'Audio', 'Music', 'Tag',
        'Metadata', 'Properties', 'Dialog', 'Window', 'Panel',
        'Select', 'Choose', 'Browse', 'Search', 'Filter',
        'Add', 'Remove', 'Delete', 'Import', 'Export',
        'Save', 'Load', 'Apply', 'Cancel', 'OK',
        'Start', 'Stop', 'Pause', 'Playback', 'Next', 'Prev',
        'Volume', 'Mute', 'Equalizer', 'DSP', 'Replay',
        'Buffer', 'Stream', 'Network', 'Proxy', 'Server',
        'Display', 'Layout', 'Color', 'Font', 'Theme',
        'Keyboard', 'Shortcut', 'Mouse', 'Click',
        'Advanced', 'General', 'Status', 'Progress',
        'Error', 'Warning', 'Message', 'Confirm',
        'Show', 'Hide', 'Enable', 'Disable',
        'All', 'None', 'Default', 'Custom',
        'Auto', 'Manual', 'Random', 'Repeat', 'Shuffle',
        'Reset', 'Clear', 'Copy', 'Paste', 'Undo', 'Redo',
        'Install', 'Update', 'Check', 'Version',
        'About', 'Help', 'Support',
    ]
)])
for s in ui_strings[:200]:
    print(f"  '{s}'")
if len(ui_strings) > 200:
    print(f"  ... ({len(ui_strings) - 200} more)")