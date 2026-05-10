"""
foobar2000 Mac v2.26 汉化 — NIB 区段重建引擎
支持变长中文替换，彻底解决二进制原地替换的长度限制问题。
"""
import struct
import os
import shutil
import json
from nibarchive import NIBArchiveParser
from nibarchive.model import NIBValueType

MAGIC = b"NIBArchive"
HEADER_SIZE = 10 + 40  # magic + 10 int32 LE
NIB_SRC = "/Applications/foobar2000.app/Contents/Resources"
BACKUP_DIR = "/tmp/foobar2000_nib_backup"
OUT_DIR = "/tmp/foobar2000_zh.app/Contents/Resources"
INPUT_JSON = "/tmp/foobar2000_zh_strings.json"

# ============================================================
# 完整翻译词库 v3 — 不再受长度限制
# ============================================================
TRANSLATIONS = {
    # ---- 菜单栏 ----
    "About foobar2000": "关于 foobar2000",
    "Preferences...": "偏好设置...",
    "Preferences\u2026": "偏好设置\u2026",
    "Open\u2026": "打开\u2026",
    "Find\u2026": "查找\u2026",
    "Find and Replace\u2026": "查找和替换\u2026",
    "Hide foobar2000": "隐藏 foobar2000",
    "Hide Others": "隐藏其他",
    "Show All": "显示全部",
    "Quit foobar2000": "退出 foobar2000",
    "File": "文件",
    "Edit": "编辑",
    "View": "视图",
    "Playback": "播放",
    "Library": "媒体库",
    "Help": "帮助",
    "Window": "窗口",

    # ---- 文件菜单 ----
    "Open...": "打开...",
    "Open Audio CD...": "打开音频 CD...",
    "Open Network Location...": "打开网络位置...",
    "Add Files...": "添加文件...",
    "Add Folder...": "添加文件夹...",
    "Add Network Location...": "添加网络位置...",
    "New Playlist": "新建播放列表",
    "New AutoPlaylist": "新建自动播放列表",
    "Load Playlist...": "加载播放列表...",
    "Save Playlist...": "保存播放列表...",
    "Save Selection as...": "保存所选为...",
    "Save All Playlists": "保存所有播放列表",

    # ---- 编辑菜单 ----
    "Undo": "撤销",
    "Redo": "恢复",
    "Cut": "剪切",
    "Copy": "复制",
    "Paste": "粘贴",
    "Select All": "全选",
    "Invert Selection": "反选",
    "Remove": "移除",
    "Selection Properties": "所选属性",
    "Rename": "重命名",

    # ---- 查找/搜索 ----
    "Find...": "查找...",
    "Search": "搜索",
    "search...": "搜索...",
    "Find Next": "查找下一个",
    "Find Previous": "查找上一个",
    "Use Selection for Find": "用所选查找",
    "Jump to Selection": "跳到所选",

    # ---- 视图菜单 ----
    "Layout": "布局",
    "Enable Layout Editing Mode": "启用布局编辑模式",
    "Create Scratchbox": "创建临时窗格",
    "Refresh": "刷新",
    "Columns": "列",
    "Sort by": "排序方式",
    "Group by": "分组方式",
    "Filter": "过滤",
    "Sort": "排序",
    "Full Screen": "全屏",
    "Enter Full Screen": "进入全屏",
    "Exit Full Screen": "退出全屏",
    "Layout Editor": "布局编辑器",
    "Layout Presets": "布局预设",
    "Save Preset...": "保存预设...",
    "Load Preset...": "加载预设...",
    "Delete Preset": "删除预设",
    "Horizontal Splitter": "水平分割器",
    "Vertical Splitter": "垂直分割器",
    "Splitter Size:": "分割器大小:",

    # ---- 播放菜单 ----
    "Play": "播放",
    "Pause": "暂停",
    "Stop": "停止",
    "Previous": "上一首",
    "Next": "下一首",
    "Random": "随机",
    "Seek": "跳转",
    "Volume": "音量",
    "Order": "播放顺序",
    "Default": "默认",
    "Repeat (track)": "重复 (单曲)",
    "Repeat (playlist)": "重复 (列表)",
    "Repeat (off)": "重复 (关闭)",
    "Shuffle (tracks)": "随机 (曲目)",
    "Shuffle (albums)": "随机 (专辑)",
    "Shuffle (folders)": "随机 (文件夹)",

    # ---- 媒体库菜单 ----
    "Configure": "配置",
    "Rescan Now": "重新扫描",

    # ---- 帮助菜单 ----
    "Web site": "官方网站",
    "Forums": "论坛",
    "License & credits": "许可证与鸣谢",
    "Check For New Versions": "检查新版本",
    "foobar2000 Help": "foobar2000 帮助",

    # ---- 主菜单栏 ----
    "Main Menu": "主菜单",
    "Services": "服务",
    "Bring All to Front": "全部置前",
    "Spelling and Grammar": "拼写和语法",
    "Show Spelling and Grammar": "显示拼写和语法",
    "Check Document Now": "立即检查文档",
    "Check Spelling While Typing": "输入时检查拼写",
    "Check Grammar With Spelling": "检查拼写和语法",
    "Correct Spelling Automatically": "自动纠正拼写",
    "Substitutions": "替换",
    "Show Substitutions": "显示替换",
    "Smart Copy/Paste": "智能拷贝/粘贴",
    "Smart Quotes": "智能引号",
    "Smart Dashes": "智能破折号",
    "Smart Links": "智能链接",
    "Text Replacement": "文本替换",
    "Transformations": "变换",
    "Make Upper Case": "转为大写",
    "Make Lower Case": "转为小写",
    "Capitalize": "首字母大写",
    "Speech": "语音",
    "Start Speaking": "开始朗读",
    "Stop Speaking": "停止朗读",
    "Paste and Match Style": "粘贴并匹配样式",

    # ---- 通用按钮 ----
    "OK": "确定",
    "Cancel": "取消",
    "Apply": "应用",
    "Close": "关闭",
    "Save": "保存",
    "Delete": "删除",
    "Add": "添加",
    "Remove Selected": "移除所选",
    "Remove All": "移除全部",
    "Reset": "重置",
    "Browse...": "浏览...",
    "Browse": "浏览",
    "Clear": "清除",
    "Previous Page": "上一页",
    "Next Page": "下一页",
    "Back": "返回",
    "Yes": "是",
    "No": "否",
    "Retry": "重试",
    "Ignore": "忽略",
    "Enable": "启用",
    "Disable": "禁用",
    "Enabled": "已启用",
    "Disabled": "已禁用",
    "Connect": "连接",
    "Disconnect": "断开",
    "Execute": "执行",
    "Preview": "预览",
    "Reload": "重新加载",
    "Update": "更新",
    "Restart": "重启",
    "Start": "开始",
    "Resume": "继续",
    "Abort": "中止",
    "Continue": "继续",
    "Finish": "完成",
    "Skip": "跳过",
    "Minimize": "最小化",
    "Maximize": "最大化",
    "Zoom": "缩放",
    "Import": "导入",
    "Export": "导出",
    "Download": "下载",
    "Upload": "上传",
    "Duplicate": "复制",
    "Select": "选择",
    "Deselect": "取消选择",

    # ---- 偏好设置面板 ----
    "General": "常规",
    "Display": "显示",
    "Media Library": "媒体库",
    "Album List": "专辑列表",
    "Networking": "网络",
    "Advanced": "高级",
    "Components": "组件",
    "Output": "输出",
    "DSP Manager": "DSP 管理器",
    "Keyboard Shortcuts": "键盘快捷键",
    "Shell Integration": "Shell 集成",
    "Playback Statistics": "播放统计",
    "UPnP MediaRenderer Control": "UPnP 控制",
    "Preferences": "偏好设置",

    # ---- 输出设置 ----
    "Device:": "设备:",
    "Output format:": "输出格式:",
    "Buffer length:": "缓冲长度:",
    "Output device:": "输出设备:",

    # ---- DSP 面板 ----
    "Active DSPs": "已启用的 DSP",
    "Available DSPs": "可用的 DSP",
    "Move Up": "上移",
    "Move Down": "下移",
    "Configure selected": "配置所选",
    "Show all DSPs": "显示所有 DSP",
    "Convert mono to stereo": "单声道转立体声",
    "Convert stereo to 4 channels": "立体声转 4 声道",
    "Downmix channels to mono": "下混到单声道",
    "Downmix channels to stereo": "下混到立体声",
    "Equalizer": "均衡器",
    "Crossfader": "交叉淡化",
    "Advanced Limiter": "高级限幅器",
    "Skip Silence": "跳过静音",
    "Balance": "平衡",
    "Volume Control": "音量控制",
    "Fade In": "淡入",
    "Fade Out": "淡出",
    "Gap Killer": "间隙消除",
    "Noise Sharpening": "噪声锐化",
    "Reverse stereo channels": "反转立体声声道",
    "Sample offset": "采样偏移",
    "Scale Samples": "缩放采样",
    "Set samplerate": "设置采样率",
    "Tempo Shift": "变速",
    "Simple Surround": "简单环绕声",
    "Channel Mixer": "声道混音器",
    "Add Noise": "添加噪声",
    "Audio Stretch": "音频伸缩",
    "DC Offset": "直流偏移",
    "Meier Crossfeed": "Meier 交叉馈送",
    "Rotate Channels": "旋转声道",

    # ---- 播放列表 ----
    "Playlist": "播放列表",
    "Playlists": "播放列表",
    "Add Files": "添加文件",
    "Add Folder": "添加文件夹",
    "Add Location": "添加位置",
    "Add Network Location": "添加网络位置",
    "Add to Current Playlist": "添加到当前列表",
    "Send to New Playlist": "发送到新列表",

    # ---- 右键菜单 / 属性 ----
    "Metadata": "元数据",
    "Properties": "属性",
    "Details": "详细信息",
    "Location": "位置",
    "Origin": "来源",
    "Other info": "其他信息",
    "Album Art": "专辑封面",
    "ReplayGain": "回放增益",
    "Convert": "转换",
    "Converter": "转换器",
    "File Operations": "文件操作",
    "Copy Files": "复制文件",
    "Move Files": "移动文件",
    "Delete Files": "删除文件",
    "Rename Files": "重命名文件",
    "Verify Integrity": "验证完整性",
    "Tag": "标签",
    "Tags": "标签",

    # ---- 转换器 ----
    "Output path:": "输出路径:",
    "Processing": "处理中",
    "Destination folder:": "目标文件夹:",
    "File name pattern:": "文件名模式:",
    "Converting...": "正在转换...",
    "Please wait...": "请稍候...",

    # ---- 标签 / 列 ----
    "All": "全部",
    "Artist": "艺术家",
    "Album": "专辑",
    "Title": "标题",
    "Genre": "流派",
    "Date": "日期",
    "Track": "音轨",
    "Rating": "评分",
    "Codec": "编码",
    "Source": "来源",
    "Name": "名称",
    "Value": "值",
    "Type": "类型",
    "Size": "大小",
    "Length": "长度",
    "Duration": "时长",
    "Bitrate": "比特率",
    "Sample Rate": "采样率",
    "Channels": "声道",
    "Channel": "声道",
    "Format": "格式",
    "Path": "路径",
    "Extension": "扩展名",
    "None": "无",
    "Automatic": "自动",
    "Manual": "手动",
    "Custom": "自定义",

    # ---- 统计 ----
    "Playcount": "播放次数",
    "First Played": "首次播放",
    "Last Played": "最后播放",
    "Added time": "添加时间",
    "Modified time": "修改时间",
    "Statistics": "统计",
    "Export Statistics": "导出统计",
    "Import Statistics": "导入统计",

    # ---- 进度/状态 ----
    "Progress": "进度",
    "Remaining time": "剩余时间",
    "Elapsed": "已用时间",
    "Total": "总计",
    "Speed": "速度",
    "Ready": "就绪",
    "Done": "完成",

    # ---- 消息 ----
    "Error": "错误",
    "Warning": "警告",
    "Information": "信息",
    "Confirm": "确认",
    "Success": "成功",
    "Failed": "失败",
    "Question": "问题",
    "No items selected": "未选择项目",
    "No results found": "未找到结果",
    "Loading...": "加载中...",
    "Connecting...": "连接中...",
    "Are you sure?": "确定吗?",

    # ---- 关于 ----
    "foobar2000 for Mac": "foobar2000 Mac 版",
    "version": "版本",
    "copyright": "版权",
    "This software uses FFmpeg": "本软件使用 FFmpeg",
    "ffmpeg.org": "ffmpeg.org",

    # ---- 网络 ----
    "Internet Radio": "网络电台",
    "Server": "服务器",
    "Port": "端口",
    "Username": "用户名",
    "Password": "密码",
    "Connection": "连接",
    "Timeout": "超时",

    # ---- CD/Cue ----
    "Cue Sheet": "Cue 文件",
    "Embedded Cue": "内嵌 Cue",
    "Audio CD": "音频 CD",
    "Rip Audio CD": "抓取音频 CD",

    # ---- ReplayGain ----
    "Scan per-file track gain": "扫描音轨增益",
    "Scan per-album album gain": "扫描专辑增益",
    "Scan selection as single album": "扫描为单个专辑",
    "Scan as albums (by tags)": "按标签扫描专辑",
    "Track gain:": "音轨增益:",
    "Album gain:": "专辑增益:",
    "Track peak:": "音轨峰值:",
    "Album peak:": "专辑峰值:",

    # ---- 快捷键 ----
    "Keyboard": "键盘",
    "Shortcuts": "快捷键",
    "Add New": "添加新的",
    "Reset All": "全部重置",
    "+ add new": "+ 添加",
    "+ new": "+ 新建",
    "Action:": "操作:",
    "Custom:": "自定义:",
    "Group by:": "分组方式:",
    "Pattern:": "模式:",
    "Preset:": "预设:",

    # ---- 其他 ----
    "Console": "控制台",
    "Copy Selected": "复制所选",
    "Copy All": "复制全部",
    "Write Log": "写入日志",
    "Separator": "分隔符",
    "Select folder...": "选择文件夹...",
    "Target:": "目标:",
    "Source:": "来源:",

    # ---- 格式 (保持英文) ----
    "MP3": "MP3",
    "FLAC": "FLAC",
    "WAV": "WAV",
    "AAC": "AAC",
    "Opus": "Opus",
    "Ogg Vorbis": "Ogg Vorbis",
    "WavPack": "WavPack",
    "Apple Lossless": "Apple Lossless",
    "16-bit": "16 位",
    "24-bit": "24 位",
    "32-bit": "32 位",
    "32-bit floating-point": "32 位浮点",
    "8-bit": "8 位",
    "16-bit dithered": "16 位抖动",
    "APEv2": "APEv2",
    "ID3v1": "ID3v1",
    "ID3v2": "ID3v2",

    # ---- 基准测试 ----
    "Benchmark": "性能测试",
    "Run Benchmark": "运行测试",

    # ---- ReFacets ----
    "ReFacets": "ReFacets",
    "Filter by": "过滤方式",

    # ---- 杂项 ----
    "aliencat": "aliencat",
    "labelColor": "标签颜色",
    "textBackgroundColor": "文本背景色",
    "linkColor": "链接颜色",
}


# ============================================================
# Varint 编解码
# ============================================================
def read_varint(data, offset):
    result = 0
    shift = 0
    count = 0
    while True:
        current_byte = data[offset + count]
        count += 1
        result |= (current_byte & 0x7F) << shift
        shift += 7
        if current_byte & 0x80:
            break
    return result, count

def encode_varint(value):
    buf = bytearray()
    while value > 0x7F:
        buf.append(value & 0x7F)
        value >>= 7
    buf.append(value | 0x80)
    return bytes(buf)


# ============================================================
# Values 区段遍历器（记录每个 value 的精确字节范围）
# ============================================================
def walk_all_values(data):
    """遍历所有 values，返回 [(value_index, start, end, type_byte, is_data)]"""
    hdr = struct.unpack_from("<10i", data, 10)
    value_count = hdr[6]
    offset_values = hdr[7]

    pos = offset_values
    values_info = []

    for vi in range(value_count):
        start = pos
        _, cnt = read_varint(data, pos)
        pos += cnt
        type_byte = data[pos]
        value_type = NIBValueType.from_byte(type_byte)
        pos += 1

        is_data = (value_type == NIBValueType.DATA)

        if value_type == NIBValueType.INT8:
            pos += 1
        elif value_type == NIBValueType.INT16:
            pos += 2
        elif value_type == NIBValueType.INT32:
            pos += 4
        elif value_type == NIBValueType.INT64:
            pos += 8
        elif value_type in (NIBValueType.BOOL_TRUE, NIBValueType.BOOL_FALSE):
            pass
        elif value_type == NIBValueType.FLOAT:
            pos += 4
        elif value_type == NIBValueType.DOUBLE:
            pos += 8
        elif value_type == NIBValueType.DATA:
            data_len, cnt = read_varint(data, pos)
            pos += cnt + data_len
        elif value_type == NIBValueType.NIL:
            pass
        elif value_type == NIBValueType.OBJECT_REF:
            pos += 4

        values_info.append({
            'value_index': vi,
            'start': start,
            'end': pos,
            'type_byte': type_byte,
            'is_data': is_data,
        })

    return values_info


# ============================================================
# NIB 区段重建核心
# ============================================================
def rebuild_nib(src_path, dst_path, translations, nib_name=""):
    with open(src_path, 'rb') as f:
        data = bytearray(f.read())

    # --- Step 1: nibarchive 解析，找到所有 NSString 对象 ---
    parser = NIBArchiveParser(verify=False)
    with open(src_path, 'rb') as f:
        archive = parser.parse(f)

    # 建立 value_index -> 新中文 bytes 映射
    zh_map = {}  # value_index -> new_bytes
    for obj in archive.objects:
        cn = archive.class_names[obj.class_name_index]
        if cn.name not in ("NSString", "NSLocalizableString"):
            continue
        for v in archive.get_object_values(obj):
            d = v.data
            if not isinstance(d, bytes):
                continue
            try:
                en = d.decode('utf-8')
            except UnicodeDecodeError:
                continue
            if en not in translations:
                continue
            zh = translations[en]
            if zh == en:
                continue
            # niarchive 的 values_index 直接对应 values 数组索引
            zh_map[obj.values_index] = zh.encode('utf-8')

    if not zh_map:
        shutil.copy2(src_path, dst_path)
        return 0, 0

    # --- Step 2: 遍历二进制 values 区段 ---
    all_values = walk_all_values(data)
    hdr = struct.unpack_from("<10i", data, 10)
    hdr_list = list(hdr)

    # --- Step 3: 重建 values 区段 ---
    old_values_start = hdr_list[7]
    old_values_end = hdr_list[9]  # offset_class_names = values 区段结束
    old_values_bytes = data[old_values_start:old_values_end]

    new_values = bytearray()
    replacements = 0

    for vi in all_values:
        vi_start = vi['start'] - old_values_start  # 相对于 values 区段起始
        vi_end = vi['end'] - old_values_start
        raw_value = old_values_bytes[vi_start:vi_end]

        if vi['is_data'] and vi['value_index'] in zh_map:
            new_data = zh_map[vi['value_index']]
            # 重新构建 DATA value: [varint(keyidx)][0x08][varint(new_len)][new_data]
            # 从原始 value 中提取 key_index varint
            orig_data_len, data_len_varint_cnt = read_varint(raw_value, 0)
            # key_index varint 在 raw_value 最前面
            keyidx_varint_end = None
            pos2 = 0
            while pos2 < len(raw_value):
                if raw_value[pos2] & 0x80:
                    keyidx_varint_end = pos2 + 1
                    break
                pos2 += 1
            # raw_value 结构: [keyidx_varint][type_byte=0x08][data_len_varint][data]
            prefix = raw_value[:keyidx_varint_end + 1]  # keyidx varint + type byte
            new_data_len_varint = encode_varint(len(new_data))
            new_value = prefix + new_data_len_varint + new_data
            new_values.extend(new_value)
            replacements += 1
        else:
            new_values.extend(raw_value)

    # --- Step 4: 计算 class_names 区段的新偏移量 ---
    delta = len(new_values) - len(old_values_bytes)
    new_class_names_offset = old_values_end + delta

    # --- Step 5: 组装新文件 ---
    new_data = bytearray()
    new_data.extend(data[:old_values_start])       # MAGIC + HEADER + OBJECTS + KEYS
    new_data.extend(new_values)                     # 新的 VALUES 区段
    new_data.extend(data[old_values_end:])          # CLASS_NAMES 及之后

    # --- Step 6: 更新 HEADER 偏移量 ---
    struct.pack_into("<10i", new_data, 10,
                     hdr_list[0], hdr_list[1],
                     hdr_list[2], hdr_list[3],
                     hdr_list[4], hdr_list[5],
                     hdr_list[6], hdr_list[7],  # offset_values 不变
                     hdr_list[8], new_class_names_offset)

    with open(dst_path, 'wb') as f:
        f.write(new_data)

    return replacements, delta


# ============================================================
# 验证：nibarchive 能否正确重新解析
# ============================================================
def verify_nib(path):
    parser = NIBArchiveParser(verify=False)
    try:
        with open(path, 'rb') as f:
            archive = parser.parse(f)
        return len(archive.objects), len(archive.values), None
    except Exception as e:
        return 0, 0, str(e)


# ============================================================
# 主程序
# ============================================================
def main():
    print("foobar2000 Mac v2.26 汉化 v3 — NIB 区段重建引擎")
    print("=" * 56)

    # 验证翻译
    active = sum(1 for k, v in TRANSLATIONS.items() if v != k)
    print(f"翻译词条: {active}")

    # 准备输出目录
    os.makedirs(OUT_DIR, exist_ok=True)

    # 确保备份存在
    if not os.path.exists(BACKUP_DIR):
        print(f"创建备份: {BACKUP_DIR}")
        shutil.copytree(NIB_SRC, BACKUP_DIR)
    else:
        print(f"备份已存在: {BACKUP_DIR}")

    nib_files = sorted([f for f in os.listdir(BACKUP_DIR) if f.endswith('.nib')])
    print(f"NIB 文件: {len(nib_files)}")

    total_replacements = 0
    total_delta = 0
    files_patched = 0
    errors = []

    for fname in nib_files:
        src = os.path.join(BACKUP_DIR, fname)
        dst = os.path.join(OUT_DIR, fname)
        n, delta = rebuild_nib(src, dst, TRANSLATIONS, fname)
        if n > 0:
            total_replacements += n
            total_delta += delta
            files_patched += 1
            delta_str = f"+{delta}B" if delta >= 0 else f"{delta}B"
            print(f"  [{n:3d} repl, {delta_str:>6s}] {fname}")
        else:
            shutil.copy2(src, dst)

        # 验证
        obj_count, val_count, err = verify_nib(dst)
        if err:
            errors.append(f"{fname}: {err}")

    # 处理 Base.lproj/MainMenu.nib (主菜单栏)
    base_src = os.path.join(BACKUP_DIR, 'Base.lproj', 'MainMenu.nib')
    base_dst_dir = os.path.join(os.path.dirname(OUT_DIR), 'Base.lproj')
    os.makedirs(base_dst_dir, exist_ok=True)
    base_dst = os.path.join(base_dst_dir, 'MainMenu.nib')

    print(f"\n处理主菜单: Base.lproj/MainMenu.nib")
    n, delta = rebuild_nib(base_src, base_dst, TRANSLATIONS, "MainMenu.nib")
    if n > 0:
        total_replacements += n
        total_delta += delta
        files_patched += 1
        delta_str = f"+{delta}B" if delta >= 0 else f"{delta}B"
        print(f"  [{n:3d} repl, {delta_str:>6s}] MainMenu.nib (Base.lproj)")
    else:
        shutil.copy2(base_src, base_dst)
        print(f"  [  0 repl] MainMenu.nib (无翻译匹配)")

    obj_count, val_count, err = verify_nib(base_dst)
    if err:
        errors.append(f"MainMenu.nib: {err}")

    print(f"\n修补文件: {files_patched}/{len(nib_files) + 1}")
    print(f"总计替换: {total_replacements} 处")
    print(f"总计扩容: {total_delta} bytes")

    if errors:
        print(f"\n错误 ({len(errors)}):")
        for e in errors:
            print(f"  {e}")
    else:
        print("全部 NIB 文件解析验证通过")

    print(f"\n汉化输出: {OUT_DIR}")
    print(f"备份位置: {BACKUP_DIR}")
    print(f"\n部署命令:")
    print(f"  sudo cp {OUT_DIR}/*.nib {NIB_SRC}/")
    print(f"  sudo cp \"{os.path.dirname(OUT_DIR)}/Base.lproj/MainMenu.nib\" \"{NIB_SRC}/Base.lproj/\"")
    print(f"\n如果启动失败，可能需要重签:")
    print(f"  sudo codesign --force --deep --sign - /Applications/foobar2000.app")
    print(f"\n还原命令:")
    print(f"  sudo cp {BACKUP_DIR}/*.nib {NIB_SRC}/")


if __name__ == '__main__':
    main()