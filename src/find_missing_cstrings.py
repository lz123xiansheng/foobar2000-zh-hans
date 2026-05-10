#!/usr/bin/env python3
"""Extract likely UI strings from binary __cstring section, find those NOT in our map"""
import subprocess, re

BINARY = "/Applications/foobar2000.app/Contents/MacOS/foobar2000"

# Our current translation map (English keys only)
in_map = {
    "File","Edit","View","Playback","Library","Help","Window","foobar2000",
    "New Playlist","Open...","Open Audio CD...","Add Files...","Add Folder...",
    "Add Location...","Save Playlist","Save Playlist...","Save Copy of Playlist...",
    "Save All Playlists...","Preferences...","Page Setup...","Print...",
    "Quit foobar2000","Open","Open File...","New","Open Folder...",
    "Undo","Redo","Cut","Copy","Paste","Delete","Select All","Deselect All",
    "Find","Find...","Find and Replace...","Find Next","Find Previous",
    "Use Selection for Find","Jump to Selection","Spelling and Grammar",
    "Show Spelling and Grammar","Check Document Now","Check Spelling While Typing",
    "Check Grammar With Spelling","Correct Spelling Automatically",
    "Substitutions","Show Substitutions","Smart Copy/Paste","Smart Quotes",
    "Smart Dashes","Smart Links","Text Replacement","Transformations",
    "Make Upper Case","Make Lower Case","Capitalize","Speech",
    "Start Speaking","Stop Speaking","Paste and Match Style","Complete",
    "Show Sidebar","Hide Sidebar","Show Status Bar","Hide Status Bar",
    "Show Toolbar","Hide Toolbar","Show Tab Bar","Hide Tab Bar",
    "Enter Full Screen","Exit Full Screen","Layout","Create Layout...",
    "Edit Layout...","Delete Layout","Quick Setup","Layout Editing Mode",
    "Live Editing","Reset Layout","Colour","DUI",
    "Play","Pause","Stop","Next","Previous","Random","Shuffle","Repeat",
    "Repeat Track","Repeat Playlist","Repeat All","Order","Default",
    "Shuffle (tracks)","Shuffle (albums)","Shuffle (folders)","Mute",
    "Volume Up","Volume Down","Playback Statistics","Show Now Playing",
    "Playback Order","Media Library","Album List","Search",
    "Remove from Library","Rescan Library","Configure...",
    "Remove Dead Items","Remove Duplicates",
    "OK","Cancel","Apply","Close","Save","Don't Save","Yes","No",
    "Continue","Revert","Reset","Clear","Choose...","Browse...",
    "Add","Remove","Import","Export","Refresh","Update","Reload",
    "Back","Finish","Done","Submit","Select","Deselect",
    "Invert Selection","Next >","< Back",
    "Properties","Get Info","Metadata","Details","Artwork",
    "ReplayGain","Location","General",
    "Display","Playback","Output","DSP Manager","Components","Advanced",
    "Network","Keyboard Shortcuts","Shell Integration","UPnP","FFmpeg",
    "Decoding","Playlist","Default User Interface","Columns UI",
    "Theme","Colours and Fonts","Font","Size","Style","Custom","System",
    "Title bar","Status bar","Toolbar","Sidebar","Window Frame",
    "Transparency","Blur","Opacity","Output Device","Buffer Length",
    "Output Format","Sample Rate","Bit Depth","Channel",
    "Channel Configuration","Fading","Crossfader","Seek",
    "Cursor follows playback","Playback follows cursor",
    "Stop after current","Resume playback on startup","Preamp",
    "Processing","Source mode","Track","Album","Processing mode",
    "Prevent clipping according to peak","Music Folders","Add Folder",
    "Remove Folder","Scan","Rescan Now","Watching",
    "Monitor folders for changes","Tag Types","Exclude","Include",
    "Filter","Filter...","File Types","Exclude patterns",
    "Available DSPs","Active DSPs","Move Up","Move Down",
    "Configure selected DSP","Revert changes","Reset all",
    "Process Priority","Normal","High","Low","Full file buffering",
    "Full file buffering up to (kB)","FFmpeg Decoder Options",
    "Thread Count","Allow seeking in HTTP streams",
    "Proxy Server","No Proxy","HTTP Proxy","SOCKS Proxy",
    "Address","Port","Username","Password","Authentication","Restrict",
    "Global","Filter list","Add New","Edit","Reset All","Import...",
    "Export...","Key","Action","Description","Assign a shortcut",
    "Press a key combination...","Enable shell integration",
    "Context menu commands","Manage file type associations",
    "Playlist View","Columns","Sort","Group By","Auto-sort",
    "Selection viewers","Inline metadata editing",
    "About foobar2000","Version","License","Copyright",
    "Check for Updates...","Check for updates",
    "Equalizer","Preset","Auto level","Save Preset...",
    "Delete Preset...","Import Preset...","Export Preset...",
    "Statistics","First Played","Last Played","Play Count",
    "Rating","Added","Converter","Converter Setup...",
    "Output format","Output file name pattern","Output path",
    "Destination folder","Ask me later","Convert","Verify",
    "Minimize","Zoom","Bring All to Front","Show All","Hide Others",
    "Hide foobar2000","Close Window","Tile Window to Left of Screen",
    "Tile Window to Right of Screen","Console","Clear Console","Copy All",
    "Track Info","File Info","Title","Artist","Genre","Date","Year",
    "Composer","Comment","Track Number","Total Tracks","Disc Number",
    "Total Discs","Codec","Codec Profile","Duration","File Size",
    "Bitrate","Channels","Bits Per Sample","Encoding","Lossless","Lossy",
    "Name","Path","Type","Value","Format","Mode","None","All","Auto",
    "Manual","Off","On","True","False","Before","After","Left","Right",
    "Center","Top","Bottom","Middle","Horizontal","Vertical","Min","Max",
    "Always on Top","Open Containing Folder","Show in Finder",
    "Don't Send","Send Report","Report","Ignore","Retry","Abort","Skip",
    "Overwrite","Create","Rename","Duplicate","Move","Copy Files",
    "Move Files","Delete Files","Replace","Enable","Enabled","Disabled",
    "Disable","Split","Expand","Collapse","Next Track","Previous Track",
    "Play or Pause","Stop Playback",
    "Rating 1","Rating 2","Rating 3","Rating 4","Rating 5",
}

# Get cstring section
r = subprocess.run(["otool", "-V", "-s", "__TEXT", "__cstring", BINARY], capture_output=True, text=True)

all_cstrings = set()
for line in r.stdout.split('\n'):
    m = re.match(r'^[0-9a-f]+\s+(.+)$', line.strip())
    if m:
        s = m.group(1)
        if s and len(s) >= 2 and len(s) <= 120:
            all_cstrings.add(s)

# Filter for likely menu/UI strings
ui_like = set()
for s in all_cstrings:
    # Must start with uppercase letter or digit
    if not re.match(r'^[A-Z0-9]', s):
        continue
    # Must contain at least one letter
    if not re.search(r'[A-Za-z]', s):
        continue
    # Skip code symbols, paths, XML, SQL
    if any(kw in s for kw in ['/Volumes/', '<', '>', 'SELECT ', 'INSERT ', 'CREATE TABLE', '0x', '.c:', '.cpp:', '.h:']):
        continue
    if re.match(r'^[A-Z_]{4,}$', s) and '_' in s:  # MACROS
        continue
    if s.count('%') > 1:  # Format strings
        continue
    # Must look like human language
    if re.match(r'^[A-Za-z0-9 &.,:;/()\-+\'\"!?\[\]{}|=#@*]+$', s):
        ui_like.add(s)

# Find missing
missing = sorted(s for s in ui_like if s not in in_map)

# Group by likely category
menu_words = ['Menu', 'Play', 'View', 'File', 'Edit', 'Help', 'Window', 'Library', 'Layout', 'Order', 'Track', 'Album']
pref_words = ['Pref', 'Setting', 'Config', 'Option', 'Format', 'Output', 'Input', 'Device', 'Display', 'Color', 'Font', 'Size', 'Volume']
action_words = ['Show', 'Hide', 'Open', 'Close', 'Add', 'Remove', 'Delete', 'Copy', 'Move', 'Rename', 'Select', 'Choose']
label_words = ['Name', 'Title', 'Path', 'Type', 'Value', 'Date', 'Time', 'Number']

print(f"Total cstrings: {len(all_cstrings)}")
print(f"UI-like strings: {len(ui_like)}")
print(f"In map: {len(ui_like & in_map)}")
print(f"MISSING: {len(missing)}")
print()

# Print categorized
for s in missing:
    prefix = ""
    if any(w in s for w in menu_words): prefix = "MENU"
    elif any(w in s for w in pref_words): prefix = "PREF"
    elif any(w in s for w in action_words): prefix = "ACT"
    elif any(w in s for w in label_words): prefix = "LBL"
    else: prefix = "---"
    print(f'  //{prefix} @"{s}": @"",')