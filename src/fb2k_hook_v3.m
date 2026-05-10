// @ai-generated: claude-sonnet-4
// fb2k_hook_v3.m - foobar2000 Mac Complete Chinese Localization
// Hooks: NSMenuItem, NSButton, NSTextField, NSTabViewItem, NSBox, NSWindow
// Timer poll + Full window tree walk + 250+ translation entries

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static NSDictionary *gMap = nil;
static FILE *gLog = NULL;
static NSTimer *gPollTimer = nil;

#define LOG(fmt, ...) do{if(gLog){fprintf(gLog,"[v3] " fmt "\n",##__VA_ARGS__);fflush(gLog);}}while(0)

static NSString* T(NSString*s){
    if(!s||!s.length)return s;
    NSString*r=gMap[s];
    if(r&&r!=s)LOG("TR: '%s'->'%s'",[s UTF8String],[r UTF8String]);
    return r?:s;
}

static void(*o1)(id,SEL,NSString*)=NULL;
static void(*o2)(id,SEL,NSAttributedString*)=NULL;
static id(*o3)(id,SEL,NSString*,SEL,NSString*)=NULL;
static void(*o4)(id,SEL,NSString*)=NULL;
static void(*o5)(id,SEL,NSString*)=NULL;
static void(*o6)(id,SEL,NSString*)=NULL;
static void(*o7)(id,SEL,NSString*)=NULL;
static void(*o8)(id,SEL,NSString*)=NULL;
static void(*o9)(id,SEL,NSString*)=NULL;
static void(*o10)(id,SEL,NSString*)=NULL;

static void h1(id s,SEL c,NSString*t){o1(s,c,T(t));}
static void h2(id s,SEL c,NSAttributedString*t){if(t){NSString*str=[t string];NSString*n=T(str);if(n!=str){NSDictionary*a=[t attributesAtIndex:0 effectiveRange:NULL];t=[[NSAttributedString alloc]initWithString:n attributes:a];}}o2(s,c,t);}
static id h3(id s,SEL c,NSString*t,SEL a,NSString*k){return o3(s,c,T(t),a,k);}
static void h4(id s,SEL c,NSString*t){o4(s,c,T(t));}
static void h5(id s,SEL c,NSString*t){o5(s,c,T(t));}
static void h6(id s,SEL c,NSString*t){o6(s,c,T(t));}
static void h7(id s,SEL c,NSString*t){o7(s,c,T(t));}
static void h8(id s,SEL c,NSString*t){o8(s,c,T(t));}
static void h9(id s,SEL c,NSString*t){o9(s,c,T(t));}
static void h10(id s,SEL c,NSString*t){o10(s,c,T(t));}

static void translate_view(NSView*v,int d){
    if(!v||d>12)return;
    if([v isKindOfClass:[NSButton class]]){NSButton*b=(NSButton*)v;NSString*t=T([b title]);if(t!=[b title])[b setTitle:t];t=T([b alternateTitle]);if(t!=[b alternateTitle])[b setAlternateTitle:t];}
    else if([v isKindOfClass:[NSTextField class]]){NSTextField*f=(NSTextField*)v;NSString*t=T([f stringValue]);if(t.length&&t!=[f stringValue])[f setStringValue:t];t=T([f placeholderString]);if(t.length&&t!=[f placeholderString])[f setPlaceholderString:t];}
    else if([v isKindOfClass:[NSBox class]]){NSBox*bx=(NSBox*)v;NSString*t=T([bx title]);if(t!=[bx title])[bx setTitle:t];}
    else if([v isKindOfClass:[NSTabView class]]){for(NSTabViewItem*item in[(NSTabView*)v tabViewItems]){NSString*l=T([item label]);if(l!=[item label])[item setLabel:l];}}
    else if([v isKindOfClass:[NSSegmentedControl class]]){NSSegmentedControl*sc=(NSSegmentedControl*)v;for(NSInteger i=0;i<sc.segmentCount;i++){NSString*l=T([sc labelForSegment:i]);if(l.length&&l!=[sc labelForSegment:i])[sc setLabel:l forSegment:i];}}
    for(NSView*sv in[v subviews])translate_view(sv,d+1);
}

static void walk_windows(void){
    for(NSWindow*w in[NSApp windows]){
        if([w isVisible]){NSString*t=T([w title]);if(t!=[w title])[w setTitle:t];translate_view([w contentView],0);}
    }
}

static void walk_menu(NSMenu*m,int d){
    if(!m||d>8)return;
    for(NSMenuItem*item in[m itemArray]){
        NSString*t=[item title];
        if(t.length&&![t hasPrefix:@"\x20\x0b"]){NSString*n=T(t);if(n!=t)[item setTitle:n];}
        if([item hasSubmenu])walk_menu([item submenu],d+1);
    }
}

static void walk_all(void){NSMenu*mm=[NSApp mainMenu];if(mm)walk_menu(mm,0);walk_windows();}

static void on_menu(NSNotification*n){dispatch_after(dispatch_time(DISPATCH_TIME_NOW,50000000),dispatch_get_main_queue(),^{walk_all();});}

static void start_timer(void){
    if(gPollTimer)return;
    gPollTimer=[NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer*t){walk_all();}];
    LOG("Timer started (2s)");
}

static void on_launch(NSNotification*n){
    LOG("App launched!");
    double ds[]={0.2,0.5,1.0,2.0,4.0,8.0,15.0};
    for(int i=0;i<7;i++)dispatch_after(dispatch_time(DISPATCH_TIME_NOW,ds[i]*NSEC_PER_SEC),dispatch_get_main_queue(),^{walk_all();});
    start_timer();
}

static void swizzle(Class cls,SEL sel,void**orig,IMP hook,const char*name){
    Method m=class_getInstanceMethod(cls,sel);
    if(m){*orig=(void*)method_getImplementation(m);method_setImplementation(m,hook);LOG("Hooked: %s",name);}
}

__attribute__((constructor))
static void init(void){
    gLog=fopen("/tmp/fb2k_zh_v3.log","a");
    LOG("====== fb2k_hook_v3 PID=%d ======",getpid());
    @autoreleasepool{
        gMap=@{
            // Menus
            @"File":@"文件",@"Edit":@"编辑",@"View":@"视图",@"Playback":@"播放",
            @"Library":@"媒体库",@"Help":@"帮助",@"Window":@"窗口",
            // File menu
            @"New Playlist":@"新建播放列表",@"Open...":@"打开...",
            @"Open Audio CD...":@"打开音频CD...",@"Add Files...":@"添加文件...",
            @"Add Folder...":@"添加文件夹...",@"Add Location...":@"添加位置...",
            @"Save Playlist":@"保存播放列表",@"Save Playlist...":@"保存播放列表...",
            @"Save Copy of Playlist...":@"保存播放列表副本...",
            @"Save All Playlists...":@"保存全部播放列表...",
            @"Preferences...":@"偏好设置...",@"Page Setup...":@"页面设置...",
            @"Print...":@"打印...",@"Quit foobar2000":@"退出 foobar2000",
            @"Open":@"打开",@"Open File...":@"打开文件...",
            @"New":@"新建",@"Open Folder...":@"打开文件夹...",
            // Edit menu
            @"Undo":@"撤销",@"Redo":@"重做",@"Cut":@"剪切",@"Copy":@"复制",
            @"Paste":@"粘贴",@"Delete":@"删除",@"Select All":@"全选",
            @"Deselect All":@"取消全选",@"Find":@"查找",@"Find...":@"查找...",
            @"Find and Replace...":@"查找和替换...",@"Find Next":@"查找下一个",
            @"Find Previous":@"查找上一个",@"Use Selection for Find":@"用所选查找",
            @"Jump to Selection":@"跳到所选",@"Spelling and Grammar":@"拼写和语法",
            @"Show Spelling and Grammar":@"显示拼写和语法",
            @"Check Document Now":@"立即检查文档",
            @"Check Spelling While Typing":@"输入时检查拼写",
            @"Check Grammar With Spelling":@"检查拼写和语法",
            @"Correct Spelling Automatically":@"自动纠正拼写",
            @"Substitutions":@"替换",@"Show Substitutions":@"显示替换",
            @"Smart Copy/Paste":@"智能拷贝/粘贴",@"Smart Quotes":@"智能引号",
            @"Smart Dashes":@"智能破折号",@"Smart Links":@"智能链接",
            @"Text Replacement":@"文本替换",@"Transformations":@"变换",
            @"Make Upper Case":@"转为大写",@"Make Lower Case":@"转为小写",
            @"Capitalize":@"首字母大写",@"Speech":@"语音",
            @"Start Speaking":@"开始朗读",@"Stop Speaking":@"停止朗读",
            @"Paste and Match Style":@"粘贴并匹配样式",@"Complete":@"自动完成",
            // View menu
            @"Show Sidebar":@"显示侧边栏",@"Hide Sidebar":@"隐藏侧边栏",
            @"Show Status Bar":@"显示状态栏",@"Hide Status Bar":@"隐藏状态栏",
            @"Show Toolbar":@"显示工具栏",@"Hide Toolbar":@"隐藏工具栏",
            @"Show Tab Bar":@"显示标签栏",@"Hide Tab Bar":@"隐藏标签栏",
            @"Enter Full Screen":@"进入全屏",@"Exit Full Screen":@"退出全屏",
            @"Layout":@"布局",@"Create Layout...":@"创建布局...",
            @"Edit Layout...":@"编辑布局...",@"Delete Layout":@"删除布局",
            @"Quick Setup":@"快速设置",@"Layout Editing Mode":@"布局编辑模式",
            @"Live Editing":@"实时编辑",@"Reset Layout":@"重置布局",
            @"Colour":@"颜色",@"DUI":@"DUI",
            @"Visualizations":@"可视化",@"Visualizations...":@"可视化...",
            @"Playlist Manager":@"播放列表管理器",@"Filter Panel":@"过滤面板",
            @"Cover Panel":@"封面面板",@"Biography View":@"简介视图",
            @"Item Properties":@"项目属性",@"Selection properties":@"选择属性",
            @"Album List Panel":@"专辑列表面板",
            @"Visualize with AudioUnit":@"AudioUnit 可视化",
            @"Visualize with Audio Unit":@"使用 AudioUnit 可视化",
            @"DSP":@"数字信号处理",
            @"PeakMeter":@"峰值表",@"Spectrum":@"频谱",
            @"Oscilloscope":@"波形示波器",@"Waveform":@"波形",
            @"Title/Track Artist":@"标题/曲目艺术家",
            @"Title/track artist":@"标题/曲目艺术家",
            @"Playlist Search":@"播放列表搜索",
            @"Internet Radio":@"网络电台",
            @"Internet Radio Bookmarks":@"网络电台书签",
            @"Internet Radio Search":@"网络电台搜索",
            // Layout presets
            @"Playlist Only":@"仅播放列表",
            @"Sidebar: Album List":@"侧边栏：专辑列表",
            @"Sidebar: Album List & Cover":@"侧边栏：专辑列表与封面",
            @"Sidebar: Album List & Playlists":@"侧边栏：专辑列表与播放列表",
            // Playback menu
            @"Play":@"播放",@"Pause":@"暂停",@"Stop":@"停止",
            @"Next":@"下一首",@"Previous":@"上一首",
            @"Random":@"随机播放",@"Shuffle":@"随机播放",
            @"Repeat":@"重复",@"Repeat Track":@"单曲循环",
            @"Repeat Playlist":@"列表循环",@"Repeat All":@"全部循环",
            @"Order":@"顺序",@"Default":@"默认",
            @"Shuffle (tracks)":@"随机播放(音轨)",
            @"Shuffle (albums)":@"随机播放(专辑)",
            @"Shuffle (folders)":@"随机播放(文件夹)",
            @"Mute":@"静音",@"Volume Up":@"增大音量",@"Volume Down":@"减小音量",
            @"Playback Statistics":@"播放统计",@"Show Now Playing":@"显示正在播放",
            @"Playback Order":@"播放顺序",
            @"ReplayGain":@"回放增益",@"Album Gain":@"专辑增益",
            @"Track Gain":@"音轨增益",@"Album Peak":@"专辑峰值",
            @"Track Peak":@"音轨峰值",@"Track gain":@"音轨增益",
            @"Track peak":@"音轨峰值",
            @"Use Album Gain":@"使用专辑增益",@"Use Track Gain":@"使用音轨增益",
            @"Write Album Gain":@"写入专辑增益",@"Write Track Gain":@"写入音轨增益",
            @"Enqueue":@"加入队列",@"Enqueue and Play":@"加入队列并播放",
            @"Enqueue as Next":@"作为下一首加入队列",
            @"Enqueue Random":@"随机加入队列",
            @"Enqueue as Next and Play":@"作为下一首加入队列并播放",
            @"Enqueue Random and Play":@"随机加入队列并播放",
            @"Switch to playlist":@"切换到播放列表",
            @"Switch to next playlist":@"切换到下一播放列表",
            @"Switch to previous playlist":@"切换到上一播放列表",
            @"Show now playing in playlist":@"在播放列表中定位正在播放",
            @"Stop After Current":@"当前曲目结束后停止",
            @"Repeat (playlist)":@"重复播放（播放列表）",
            @"Repeat (track)":@"重复播放（单曲）",
            @"Playback Follows Cursor":@"播放跟随光标",
            @"Cursor Follows Playback":@"光标跟随播放",
            @"Show Recently Played":@"显示最近播放",
            @"Show Recently Added":@"显示最近添加",
            @"Configure":@"配置...",
            @"Monitor Playing Tracks":@"监控正在播放的曲目",
            @"Export Statistics...":@"导出统计数据...",
            @"Import Statistics...":@"导入统计数据...",
            // Library menu
            @"Media Library":@"媒体库",@"Album List":@"专辑列表",
            @"Search":@"搜索",@"Remove from Library":@"从媒体库移除",
            @"Rescan Library":@"重新扫描媒体库",
            @"Configure...":@"配置...",
            @"Remove Dead Items":@"移除无效条目",@"Remove Duplicates":@"移除重复项",
            // Common buttons
            @"OK":@"确定",@"Cancel":@"取消",@"Apply":@"应用",@"Close":@"关闭",
            @"Save":@"保存",@"Don't Save":@"不保存",@"Yes":@"是",@"No":@"否",
            @"Continue":@"继续",@"Revert":@"恢复",@"Reset":@"重置",@"Clear":@"清空",
            @"Choose...":@"选择...",@"Browse...":@"浏览...",
            @"Add":@"添加",@"Remove":@"移除",@"Import":@"导入",@"Export":@"导出",
            @"Refresh":@"刷新",@"Update":@"更新",@"Reload":@"重新加载",
            @"Back":@"返回",@"Finish":@"完成",@"Done":@"完成",@"Submit":@"提交",
            @"Select":@"选择",@"Deselect":@"取消选择",@"Invert Selection":@"反选",
            @"Next >":@"下一步",@"< Back":@"上一步",
            // Properties
            @"Properties":@"属性",@"Get Info":@"获取信息",
            @"Metadata":@"元数据",@"Details":@"详细信息",
            @"Artwork":@"封面",@"ReplayGain":@"回放增益",
            @"Location":@"位置",@"General":@"常规",
            // Preferences tabs
            @"Display":@"显示",@"Playback":@"播放",
            @"Output":@"输出",@"DSP Manager":@"DSP管理器",
            @"Components":@"组件",@"Advanced":@"高级",
            @"Network":@"网络",@"Keyboard Shortcuts":@"键盘快捷键",
            @"Shell Integration":@"Shell集成",@"UPnP":@"UPnP",
            @"FFmpeg":@"FFmpeg",@"Decoding":@"解码",
            @"Playlist":@"播放列表",
            // General
            @"Default User Interface":@"默认用户界面",@"Columns UI":@"分栏界面",
            @"Theme":@"主题",@"Colours and Fonts":@"颜色和字体",
            @"Font":@"字体",@"Size":@"大小",@"Style":@"样式",
            @"Custom":@"自定义",@"System":@"系统",
            @"Title bar":@"标题栏",@"Status bar":@"状态栏",
            @"Toolbar":@"工具栏",@"Sidebar":@"侧边栏",
            @"Window Frame":@"窗口框架",@"Transparency":@"透明度",
            @"Blur":@"模糊",@"Opacity":@"不透明度",
            // Output
            @"Output Device":@"输出设备",@"Buffer Length":@"缓冲长度",
            @"Output Format":@"输出格式",@"Sample Rate":@"采样率",
            @"Bit Depth":@"位深度",@"Channel":@"声道",
            @"Channel Configuration":@"声道配置",
            // Playback options
            @"Fading":@"淡入淡出",@"Crossfader":@"交叉淡出",
            @"Seek":@"跳转",@"Cursor follows playback":@"光标跟随播放",
            @"Playback follows cursor":@"播放跟随光标",
            @"Stop after current":@"当前曲目后停止",
            @"Resume playback on startup":@"启动时恢复播放",
            @"Preamp":@"前置放大器",@"Processing":@"处理",
            @"Source mode":@"源模式",@"Track":@"音轨",@"Album":@"专辑",
            @"Processing mode":@"处理模式",
            @"Prevent clipping according to peak":@"根据峰值防止削波",
            // Library options
            @"Music Folders":@"音乐文件夹",
            @"Add Folder":@"添加文件夹",@"Remove Folder":@"移除文件夹",
            @"Scan":@"扫描",@"Rescan Now":@"立即重新扫描",
            @"Watching":@"监视",@"Monitor folders for changes":@"监视文件夹变化",
            @"Tag Types":@"标签类型",@"Exclude":@"排除",@"Include":@"包含",
            @"Filter":@"过滤",@"Filter...":@"过滤...",
            @"File Types":@"文件类型",@"Exclude patterns":@"排除模式",
            // DSP
            @"Available DSPs":@"可用DSP",@"Active DSPs":@"活动DSP",
            @"Move Up":@"上移",@"Move Down":@"下移",
            @"Configure selected DSP":@"配置所选DSP",
            @"Revert changes":@"恢复更改",@"Reset all":@"全部重置",
            // Advanced
            @"Process Priority":@"进程优先级",@"Normal":@"正常",
            @"High":@"高",@"Low":@"低",
            @"Full file buffering":@"全文件缓冲",
            @"Full file buffering up to (kB)":@"全文件缓冲上限(kB)",
            @"FFmpeg Decoder Options":@"FFmpeg解码器选项",
            @"Thread Count":@"线程数",
            @"Allow seeking in HTTP streams":@"允许HTTP流跳转",
            // Network
            @"Proxy Server":@"代理服务器",@"No Proxy":@"无代理",
            @"HTTP Proxy":@"HTTP代理",@"SOCKS Proxy":@"SOCKS代理",
            @"Address":@"地址",@"Port":@"端口",
            @"Username":@"用户名",@"Password":@"密码",
            @"Authentication":@"认证",@"Restrict":@"限制",
            // Keyboard
            @"Global":@"全局",@"Filter list":@"筛选列表",
            @"Add New":@"新增",@"Edit":@"编辑",
            @"Reset All":@"全部重置",@"Import...":@"导入...",
            @"Export...":@"导出...",@"Key":@"按键",@"Action":@"操作",
            @"Description":@"描述",@"Assign a shortcut":@"分配快捷键",
            @"Press a key combination...":@"按下组合键...",
            // Shell
            @"Enable shell integration":@"启用Shell集成",
            @"Context menu commands":@"右键菜单命令",
            @"Manage file type associations":@"管理文件类型关联",
            // Playlist settings
            @"Playlist View":@"播放列表视图",@"Columns":@"列",
            @"Sort":@"排序",@"Group By":@"分组",
            @"Auto-sort":@"自动排序",@"Selection viewers":@"选择查看器",
            @"Inline metadata editing":@"内联元数据编辑",
            // About
            @"About foobar2000":@"关于 foobar2000",
            @"Version":@"版本",@"License":@"许可证",
            @"Copyright":@"版权",@"Check for Updates...":@"检查更新...",
            @"Check for updates":@"检查更新",
            // Equalizer
            @"Equalizer":@"均衡器",@"Preset":@"预设",
            @"Auto level":@"自动电平",@"Save Preset...":@"保存预设...",
            @"Delete Preset...":@"删除预设...",@"Import Preset...":@"导入预设...",
            @"Export Preset...":@"导出预设...",
            // Statistics
            @"Statistics":@"统计",@"First Played":@"首次播放",
            @"Last Played":@"最后播放",@"Play Count":@"播放次数",
            @"Rating":@"评级",@"Added":@"添加日期",
            // Converter
            @"Converter":@"转换器",@"Converter Setup...":@"转换器设置...",
            @"Output format":@"输出格式",@"Output file name pattern":@"输出文件名模式",
            @"Output path":@"输出路径",@"Destination folder":@"目标文件夹",
            @"Ask me later":@"稍后询问",@"Convert":@"转换",@"Verify":@"验证",
            // Window menu
            @"Minimize":@"最小化",@"Zoom":@"缩放",
            @"Bring All to Front":@"全部置于顶层",
            @"Show All":@"显示全部",@"Hide Others":@"隐藏其他",
            @"Hide foobar2000":@"隐藏 foobar2000",
            @"Close Window":@"关闭窗口",
            @"Tile Window to Left of Screen":@"窗口靠左",
            @"Tile Window to Right of Screen":@"窗口靠右",
            // Console
            @"Console":@"控制台",@"Clear Console":@"清空控制台",
            @"Copy All":@"复制全部",
            // Track info
            @"Track Info":@"音轨信息",@"File Info":@"文件信息",
            @"Title":@"标题",@"Artist":@"艺术家",
            @"Genre":@"流派",@"Date":@"日期",@"Year":@"年份",
            @"Composer":@"作曲家",@"Comment":@"注释",
            @"Track Number":@"音轨号",@"Total Tracks":@"总音轨数",
            @"Disc Number":@"碟片号",@"Total Discs":@"总碟片数",
            @"Codec":@"编码",@"Codec Profile":@"编码配置",
            @"Duration":@"时长",@"File Size":@"文件大小",
            @"Bitrate":@"比特率",
            @"Channels":@"声道数",@"Bits Per Sample":@"采样位深",
            @"Encoding":@"编码格式",@"Lossless":@"无损",@"Lossy":@"有损",
            // Common labels
            @"Name":@"名称",@"Path":@"路径",@"Type":@"类型",
            @"Value":@"值",@"Format":@"格式",@"Mode":@"模式",
            @"None":@"无",@"All":@"全部",@"Auto":@"自动",
            @"Manual":@"手动",@"Off":@"关闭",@"On":@"开启",
            @"True":@"是",@"False":@"否",
            @"Before":@"之前",@"After":@"之后",
            @"Left":@"左",@"Right":@"右",@"Center":@"居中",
            @"Top":@"上",@"Bottom":@"下",@"Middle":@"中",
            @"Horizontal":@"水平",@"Vertical":@"垂直",
            @"Min":@"最小",@"Max":@"最大",
            // Misc
            @"Always on Top":@"始终置顶",
            @"Open Containing Folder":@"打开所在文件夹",
            @"Show in Finder":@"在Finder中显示",
            @"Don't Send":@"不发送",@"Send Report":@"发送报告",
            @"Report":@"报告",@"Ignore":@"忽略",@"Retry":@"重试",
            @"Abort":@"中止",@"Skip":@"跳过",@"Overwrite":@"覆盖",
            @"Create":@"创建",@"Rename":@"重命名",@"Duplicate":@"复制",
            @"Move":@"移动",@"Copy Files":@"复制文件",@"Move Files":@"移动文件",
            @"Delete Files":@"删除文件",@"Replace":@"替换",
            @"Enable":@"启用",@"Enabled":@"启用",@"Disabled":@"禁用",
            @"Disable":@"禁用",@"Split":@"分割",
            @"Expand":@"展开",@"Collapse":@"折叠",
            @"Next Track":@"下一首",@"Previous Track":@"上一首",
            @"Play or Pause":@"播放/暂停",@"Stop Playback":@"停止播放",
            @"Rating 1":@"评级1",@"Rating 2":@"评级2",@"Rating 3":@"评级3",
            @"Rating 4":@"评级4",@"Rating 5":@"评级5",
            @"Various Artists":@"群星",
            // More tools/actions
            @"File Operations":@"文件操作",@"Tools":@"工具",
            @"Utilities":@"工具",@"Utils":@"工具",
            @"Tagging":@"标签编辑",@"Tag writing":@"标签写入",
            @"Tag type":@"标签类型",@"Tag update":@"标签更新",
            @"Tag removal":@"标签移除",@"Remove tags":@"移除标签",
            @"Tag location":@"标签位置",@"Tag not found":@"标签未找到",
            @"Write statistics to file tags":@"写入统计到文件标签",
            @"Read statistics from file tags":@"从文件标签读取统计",
            @"Verify integrity":@"验证完整性",
            @"Verify album with AccurateRip":@"用AccurateRip验证专辑",
            @"Resampler":@"重采样器",@"Spectrogram":@"频谱图",
            @"VU Meter":@"VU表",@"Sweep":@"扫频",@"Tone":@"音调",
            @"Decoder shim":@"解码器适配",
            @"Restrict to...":@"限制为...",
            @"Add to Autoplaylist":@"添加到自动播放列表",
            @"Working...":@"处理中...",@"Success":@"成功",
            @"Warning":@"警告",@"Error":@"错误",
            @"Summary":@"摘要",@"Target":@"目标",
            @"Tab":@"标签页",@"VBR":@"可变比特率(VBR)",
            @"Updates":@"更新",@"Update check failure":@"更新检查失败",
            @"Volume":@"音量",@"Volume step (dB)":@"音量步进(dB)",
            @"Volume":@"音量",@"Volume step (dB)":@"音量步进(dB)",
            @"Upmix to 5.1":@"上混到5.1",@"Upmix to 7.1":@"上混到7.1",
            @"Upmix to 3.0 (FL FR C)":@"上混到3.0 (FL FR C)",
            @"Upmix to 4.0 (FL FR BL BR)":@"上混到4.0 (FL FR BL BR)",
            @"Upmix to 5.0 (FL FR C BL BR)":@"上混到5.0 (FL FR C BL BR)",
            @"Upmix to 5.1/side (FL FR C LFE SL SR)":@"上混到5.1/侧 (FL FR C LFE SL SR)",
            @"Upmix to 6.0 (FL FR BL BR SL SR)":@"上混到6.0 (FL FR BL BR SL SR)",
            @"Upmix to 7.1":@"上混到7.1",
            @"Downmix Channels":@"下混声道",
            @"Downmix channels to mono":@"下混到单声道",
            @"Downmix channels to stereo":@"下混到立体声",
            @"Chorus":@"合唱",@"Gain / Scale":@"增益/缩放",
            @"Resampler (ARDFTSRC)":@"重采样器 (ARDFTSRC)",
            @"Resampler (Speex)":@"重采样器 (Speex)",
            @"Classic ReplayGain":@"经典回放增益",
            @"Digital peak":@"数字峰值",@"Album Peak":@"专辑峰值",
            @"Album peak":@"专辑峰值",
            @"Copy album ReplayGain to SoundCheck":@"复制专辑回放增益到SoundCheck",
            @"Copy track ReplayGain to SoundCheck":@"复制音轨回放增益到SoundCheck",
            @"ReplayGain Scanner":@"回放增益扫描器",
            @"ReplayGain scanner":@"回放增益扫描器",
            @"System Integration":@"系统集成",
            @"System tray icon tooltip":@"系统托盘图标提示",
            @"Shutdown":@"关机",@"Hibernate":@"休眠",
            @"Add Folder":@"添加文件夹",@"Add Files":@"添加文件",
            @"Add Facet":@"添加分面",
            @"ReFacets":@"分面",
            @"Remote Control":@"远程控制",
            @"Allow remote control from":@"允许远程控制来源",
            @"Streaming to Devices":@"串流到设备",
            @"Play to Device":@"播放到设备",
            @"Saved Passwords":@"已保存的密码",
            @"Invalid network credentials":@"无效的网络凭据",
            @"Connection":@"连接",
            @"Device":@"设备",@"Renderer":@"渲染器",
            @"UPnP Device":@"UPnP设备",
            @"UPnP Media Server":@"UPnP媒体服务器",
            @"UPnP MediaRenderer":@"UPnP媒体渲染器",
            @"UPnP Volume Control":@"UPnP音量控制",
            // v3.3: 偏好设置侧边栏 + 过滤器 + 音频格式 + DSP + 显示/解码/播放/缓冲/标签/Opus/SoundCheck/工具/统计
            @"Assigned":@"已分配",@"Key":@"快捷键",
            @"Filters":@"过滤器",@"Devices":@"设备",
            @"Networking":@"网络",@"FFmpeg Decoder Wrapper":@"FFmpeg 解码器",
            @"UPnP":@"UPnP（通用即插即用）",
            @"Pattern":@"匹配模式",@"Missing ReplayGain":@"缺少回放增益",
            @"Most played":@"播放次数最多",@"Never played":@"从未播放",
            @"Played often":@"经常播放",@"Random order":@"随机顺序",
            @"Recently added":@"最近添加",@"Recently played":@"最近播放",
            @"Top rated":@"评分最高",
            @"Audio file formats":@"音频文件格式",@"Format name":@"格式名称",
            @"File type mask":@"文件类型掩码",
            @"Shorten":@"Shorten（无损压缩格式）",
            @"True Audio":@"True Audio（无损压缩格式）",
            @"MLP":@"MLP（无损压缩格式）",
            @"DTS":@"DTS（数字影院系统）",
            @"DTS-HD":@"DTS-HD（高清数字影院系统）",
            @"RTMP":@"RTMP（实时消息传输协议）",
            @"RTSP":@"RTSP（实时流传输协议）",
            @"HLS":@"HLS（HTTP 直播流）",
            @"WMA":@"WMA（Windows 媒体音频）",
            @"FFmpeg installation location":@"FFmpeg 安装位置",
            @"No FFmpeg found in system folders.":@"在系统文件夹中未找到 FFmpeg。",
            @"Convert mono to stereo":@"单声道转立体声",
            @"Convert stereo to 4 channels":@"立体声转四声道",
            @"DC Offset":@"直流偏移",@"Hard -6dB limiter":@"硬 -6dB 限制器",
            @"Meier Crossfeed":@"Meier 交叉馈送",
            @"Move stereo to rear channels":@"将立体声移至后置声道",
            @"Rear channels to side channels":@"后置声道转侧置声道",
            @"Reverse stereo channels":@"反转立体声声道",
            @"Rotate Channels":@"旋转声道",@"Sample Offset":@"采样偏移",
            @"Set Sample Rate":@"设置采样率",
            @"Side channels to rear channels":@"侧置声道转后置声道",
            @"Skip Silence":@"跳过静音",
            @"Additional correction file folders":@"附加修正文件文件夹",
            @"Tone/sweep sample rate":@"音调/扫频采样率",
            @"Recognize common media formats with wrong file extensions":@"识别常见媒体格式（含错误扩展名）",
            @"Present chapters/subsongs as separate playlist items":@"将章节/子歌曲显示为独立播放列表项",
            @"FFmpeg -strict level":@"FFmpeg 严格级别",
            @"FFmpeg AC3 -drc_scale":@"FFmpeg AC3 动态压缩比例",
            @"Autocomplete fields":@"自动补全字段",
            @"Legacy title formatting settings (deprecated, provided for compatibility with old components only)":@"旧版标题格式化设置（已弃用，仅为兼容旧组件保留）",
            @"Copy command":@"复制命令",@"Main window title":@"主窗口标题",
            @"Properties dialog":@"属性对话框",
            @"Multiline fields":@"多行字段",@"Multivalue fields":@"多值字段",
            @"Standard fields":@"标准字段",@"Title display format":@"标题显示格式",
            @"Standard sort patterns":@"标准排序模式",
            @"VBR bitrate updates per second":@"VBR 比特率每秒更新次数",
            @"Visualisations":@"可视化",
            @"Visualization refresh rate (Mac OS 14+)":@"可视化刷新率 (Mac OS 14+)",
            @"Album art":@"专辑封面",
            @"Maximum external art size (MB)":@"最大外部封面大小 (MB)",
            @"Embedded vs external":@"嵌入 vs 外部",
            @"Prefer larger":@"优先大尺寸",@"Prefer external":@"优先外部",
            @"Prefer embedded":@"优先嵌入",
            @"Library Selection Playlist":@"媒体库选择播放列表",
            @"Activate":@"激活",
            @"Quit foobar2000 when closing main window":@"关闭主窗口时退出 foobar2000",
            @"Allow seeking over HTTP":@"允许通过 HTTP 寻址",
            @"Codepage for ShoutCast metadata (0 = use defaults)":@"ShoutCast 元数据代码页 (0 = 使用默认)",
            @"Disable ShoutCast metadata with HTTP GET proxy":@"禁用 ShoutCast 元数据（HTTP GET 代理方式）",
            @"Keep reconnecting dropped connections for (seconds)":@"断线后保持重连时间（秒）",
            @"Force HTTP CONNECT with proxy servers":@"强制对代理服务器使用 HTTP CONNECT",
            @"Suppress HTTPS certificate checks for domains":@"对指定域名禁用 HTTPS 证书检查",
            @"Enable additional decoding (DTS, HDCD, etc)":@"启用附加解码 (DTS, HDCD 等)",
            @"Fast DSP reset when cycling tracks manually":@"手动切歌时快速重置 DSP",
            @"Flush playback queue on manual track change":@"手动切歌时清除播放队列",
            @"Show error message popups":@"显示错误信息弹窗",
            @"Album grouping pattern":@"专辑分组模式",
            @"Album sorting pattern":@"专辑排序模式",
            @"Reshuffle on manual track selection":@"手动选择音轨时重新洗牌",
            @"Slow but accurate seeking (affects some music formats only)":@"慢速但精准跳转（仅影响部分音乐格式）",
            @"Smart stop from lockscreen/keyboard; once enables stop-after-current, twice stops":@"从锁屏界面/键盘智能停止；按一次启用当前后停，按两次停止",
            @"Verify integrity of played tracks and report errors immediately":@"验证已播放曲目完整性并立即报告错误",
            @"Read-ahead for remote files (http, ftp, etc) (kB)":@"远程文件预读 (http, ftp 等) (kB)",
            @"Read-ahead for local files (kB)":@"本地文件预读 (kB)",
            @"Buffering":@"缓冲",
            @"ID3v2 revision and quirks":@"ID3v2 版本与特性",
            @"Write ID3v2.3 tags (more compatible)":@"写入 ID3v2.3 标签（兼容性更好）",
            @"Write ID3v2.4 tags (less compatible)":@"写入 ID3v2.4 标签（兼容性较差）",
            @"Use padding (faster tag updates, may be incompatible with buggy software)":@"使用填充（标签更新更快，可能与有问题的软件不兼容）",
            @"Map TPE2 to Album Artist (more compatible)":@"将 TPE2 映射为专辑艺术家（兼容性更好）",
            @"Write compatible date frames (non-standard-compliant)":@"写入兼容的日期帧（非标准合规）",
            @"Write rating as TXXX (less compatible)":@"将评分写为 TXXX（兼容性较差）",
            @"Opus":@"Opus（音频编码格式）",
            @"Header gain":@"头部增益",@"Leave null":@"留空",
            @"SoundCheck":@"SoundCheck（音量标准化）",
            @"Automatically write when writing ReplayGain (applies to: MP4/M4A, MP3, all formats using ID3v2 tags or MP4 container)":@"写入回放增益时自动写入（适用于：MP4/M4A、MP3、使用 ID3v2 标签或 MP4 容器的格式）",
            @"Do not write":@"不写入",
            @"SoundCheck target loudness":@"SoundCheck 目标响度",
            @"iTunes (-16dB LUFS)":@"iTunes 标准 (-16dB LUFS)",
            @"ReplayGain (-18dB LUFS)":@"回放增益标准 (-18dB LUFS)",
            @"Vorbis & FLAC":@"Vorbis 与 FLAC",
            @"Metadata writing mode:":@"元数据写入模式：",
            @"More compatible with various software - ALBUMARTIST, TRACKTOTAL, DISCTOTAL":@"与多种软件兼容性更好 - ALBUMARTIST, TRACKTOTAL, DISCTOTAL",
            @"Compatible with old foobar2000 versions - ALBUM ARTIST, TOTALTRACKS, TOTALDISCS":@"与旧版 foobar2000 兼容 - ALBUM ARTIST, TOTALTRACKS, TOTALDISCS",
            @"Preserve file creation/access/modification time when retagging":@"重新标签时保留文件创建/访问/修改时间",
            @"Automatic resampling preference - resampler DSP names, semicolon-delimited":@"自动重采样偏好 - 重采样器 DSP 名称(分号分隔)",
            @"File Integrity Verifier":@"文件完整性校验器",
            @"Maximum threads":@"最大线程数",
            @"Empty folder detection":@"空文件夹检测",
            @"Check for empty folders left after deleting files":@"检测删除文件后留下的空文件夹",
            @"Ignore files matching pattern (eg. *.log;*.txt;*.cue)":@"忽略匹配模式的文件（如 *.log;*.txt;*.cue）",
            @"Ignore hidden files matching pattern":@"忽略匹配模式的隐藏文件",
            @"Empty folders":@"空文件夹",@"Deletion type":@"删除方式",
            @"Automatically synchronize file tags with statistics (causes file tag rewrites during playback, disrecommended)":@"自动将文件标签与统计同步（会导致播放期间文件标签重写，不推荐）",
            @"Fail when peak value exceeds":@"当峰值超过时失败",
            @"Results dialog: advanced formatting of peak values":@"结果对话框：峰值高级格式化",
            @"Asymmetric matching":@"非对称匹配",
            @"Search index fields":@"搜索索引字段",@"Simple Search":@"简单搜索",
            @"Exclude fields":@"排除字段",@"Restrict to fields":@"限定搜索字段",
            @"Write EXTM3U playlists":@"写入 EXTM3U 播放列表",
            @"Include hidden files & subfolders when adding whole folders and in the Media Library":@"添加文件夹及媒体库时包含隐藏文件和子文件夹",
            @"Check for beta versions of foobar2000 when running a stable version":@"运行稳定版时检查 foobar2000 Beta 版本",
            @"Scanning thread count (0 = use all available)":@"扫描线程数 (0 = 使用全部可用)",
            @"Apply gain thread count (0 = use all available)":@"增益应用线程数 (0 = 使用全部可用)",
            @"Read size (MB) during multithreaded scan":@"多线程扫描时读取大小 (MB)",
            // v3.3 end
        };
        LOG("Map: %lu entries",(unsigned long)gMap.count);
        
        swizzle([NSMenuItem class],@selector(setTitle:),(void**)&o1,(IMP)h1,"NSMenuItem.setTitle:");
        swizzle([NSMenuItem class],@selector(setAttributedTitle:),(void**)&o2,(IMP)h2,"NSMenuItem.setAttributedTitle:");
        swizzle([NSMenuItem class],@selector(initWithTitle:action:keyEquivalent:),(void**)&o3,(IMP)h3,"NSMenuItem.initWithTitle:");
        swizzle([NSButton class],@selector(setTitle:),(void**)&o4,(IMP)h4,"NSButton.setTitle:");
        swizzle([NSButton class],@selector(setAlternateTitle:),(void**)&o5,(IMP)h5,"NSButton.setAlternateTitle:");
        swizzle([NSTextField class],@selector(setStringValue:),(void**)&o6,(IMP)h6,"NSTextField.setStringValue:");
        swizzle([NSTextField class],@selector(setPlaceholderString:),(void**)&o7,(IMP)h7,"NSTextField.setPlaceholderString:");
        swizzle([NSTabViewItem class],@selector(setLabel:),(void**)&o8,(IMP)h8,"NSTabViewItem.setLabel:");
        swizzle([NSBox class],@selector(setTitle:),(void**)&o9,(IMP)h9,"NSBox.setTitle:");
        swizzle([NSWindow class],@selector(setTitle:),(void**)&o10,(IMP)h10,"NSWindow.setTitle:");
        
        [[NSNotificationCenter defaultCenter]addObserverForName:NSApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*n){on_launch(n);}];
        [[NSNotificationCenter defaultCenter]addObserverForName:NSMenuDidAddItemNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*n){on_menu(n);}];
        [[NSNotificationCenter defaultCenter]addObserverForName:NSMenuDidChangeItemNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification*n){on_menu(n);}];
        
        LOG("All hooks ready");
    }
}

__attribute__((destructor))
static void done(void){LOG("Unloaded");if(gLog)fclose(gLog);}