// @ai-generated: claude-sonnet-4
// fb2k_hook_v2.m - foobar2000 Mac Chinese Localization
// Strategy: Hook all menu creation paths + post-launch tree walk
// Confirms loading via /tmp/fb2k_zh.log

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <objc/runtime.h>

static NSDictionary *gTranslationMap = nil;
static FILE *gLogFile = NULL;
static BOOL gDidWalkMenu = NO;

#define LOG(fmt, ...) do { \
    if (gLogFile) { fprintf(gLogFile, "[fb2k_zh] " fmt "\n", ##__VA_ARGS__); fflush(gLogFile); } \
} while(0)

static NSString* translate_title(NSString *title) {
    if (!title || title.length == 0) return title;
    NSString *translated = gTranslationMap[title];
    if (translated) {
        LOG("TRANSLATE: '%s' -> '%s'", [title UTF8String], [translated UTF8String]);
    }
    return translated ?: title;
}

// ===== Hook 1: NSMenuItem setTitle: =====
static void (*original_setTitle)(id, SEL, NSString*) = NULL;
static void hooked_setTitle(id self, SEL _cmd, NSString *title) {
    original_setTitle(self, _cmd, translate_title(title));
}

// ===== Hook 2: NSMenuItem setAttributedTitle: =====
static void (*original_setAttributedTitle)(id, SEL, NSAttributedString*) = NULL;
static void hooked_setAttributedTitle(id self, SEL _cmd, NSAttributedString *title) {
    if (title) {
        NSString *str = [title string];
        NSString *t = translate_title(str);
        if (t != str) {
            NSDictionary *attrs = [title attributesAtIndex:0 effectiveRange:NULL];
            title = [[NSAttributedString alloc] initWithString:t attributes:attrs];
        }
    }
    original_setAttributedTitle(self, _cmd, title);
}

// ===== Hook 3: NSMenuItem initWithTitle:action:keyEquivalent: =====
static id (*original_initWithTitle)(id, SEL, NSString*, SEL, NSString*) = NULL;
static id hooked_initWithTitle(id self, SEL _cmd, NSString *title, SEL action, NSString *keyEquiv) {
    return original_initWithTitle(self, _cmd, translate_title(title), action, keyEquiv);
}

// Recursively translate all items in a menu
static void translate_menu(NSMenu *menu, int depth) {
    if (!menu || depth > 5) return;
    LOG("Walking menu: '%s' (%lu items)", [[menu title] UTF8String], (unsigned long)[menu numberOfItems]);
    for (NSMenuItem *item in [menu itemArray]) {
        NSString *oldTitle = [item title];
        NSString *newTitle = translate_title(oldTitle);
        if (newTitle != oldTitle) {
            LOG("  SET: '%s' -> '%s'", [oldTitle UTF8String], [newTitle UTF8String]);
            [item setTitle:newTitle];
        }
        if ([item hasSubmenu]) {
            translate_menu([item submenu], depth + 1);
        }
    }
}

// Post-launch menu walk (fires after app is fully initialized)
static void walk_all_menus(void) {
    if (gDidWalkMenu) return;
    gDidWalkMenu = YES;
    LOG("=== Starting post-launch menu walk ===");
    NSMenu *mainMenu = [NSApp mainMenu];
    if (mainMenu) {
        translate_menu(mainMenu, 0);
    }
    LOG("=== Menu walk done ===");
    // Schedule a follow-up walk for dynamically added items
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        LOG("=== Follow-up menu walk ===");
        NSMenu *mm = [NSApp mainMenu];
        if (mm) translate_menu(mm, 0);
    });
}

// Listen for menu changes
static void menu_did_change(NSNotification *note) {
    NSMenu *menu = note.object;
    if (!menu) return;
    LOG("Menu changed: '%s'", [[menu title] UTF8String]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        translate_menu(menu, 0);
    });
}

// Listen for app did finish launching
static void app_did_launch(NSNotification *note) {
    LOG("=== Application did finish launching ===");
    // Multiple attempts at different delays to catch all menu setups
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ walk_all_menus(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ gDidWalkMenu = NO; walk_all_menus(); });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ gDidWalkMenu = NO; walk_all_menus(); });
}

__attribute__((constructor))
static void fb2k_chinese_init(void) {
    // Open log file IMMEDIATELY to confirm dylib loading
    gLogFile = fopen("/tmp/fb2k_zh.log", "a");
    if (!gLogFile) return; // Can't even open log file, give up
    
    LOG("========================================");
    LOG("fb2k_hook_v2 loaded at PID=%d", getpid());
    LOG("========================================");
    
    @autoreleasepool {
        gTranslationMap = @{
            // Top-level menus
            @"File": @"文件", @"Edit": @"编辑", @"View": @"视图",
            @"Playback": @"播放", @"Library": @"媒体库", @"Help": @"帮助",
            @"Window": @"窗口",
            
            // File menu
            @"New Playlist": @"新建播放列表",
            @"Open...": @"打开...", @"Open Audio CD...": @"打开音频CD...",
            @"Add Files...": @"添加文件...", @"Add Folder...": @"添加文件夹...",
            @"Add Location...": @"添加位置...", @"Save Playlist...": @"保存播放列表...",
            @"Preferences...": @"偏好设置...", @"Page Setup...": @"页面设置...",
            @"Print...": @"打印...", @"Quit foobar2000": @"退出 foobar2000",
            
            // Edit menu
            @"Undo": @"撤销", @"Redo": @"重做", @"Cut": @"剪切",
            @"Copy": @"复制", @"Paste": @"粘贴", @"Delete": @"删除",
            @"Select All": @"全选", @"Deselect All": @"取消全选",
            
            // View menu
            @"Show Sidebar": @"显示侧边栏", @"Hide Sidebar": @"隐藏侧边栏",
            @"Show Status Bar": @"显示状态栏", @"Hide Status Bar": @"隐藏状态栏",
            @"Show Toolbar": @"显示工具栏", @"Hide Toolbar": @"隐藏工具栏",
            @"Enter Full Screen": @"进入全屏", @"Exit Full Screen": @"退出全屏",
            
            // Playback menu
            @"Play": @"播放", @"Pause": @"暂停", @"Stop": @"停止",
            @"Next": @"下一首", @"Previous": @"上一首",
            @"Random": @"随机播放", @"Repeat": @"重复",
            
            // Library menu
            @"Media Library": @"媒体库", @"Album List": @"专辑列表",
            @"Search": @"搜索", @"Remove from Library": @"从媒体库移除",
            @"Rescan Library": @"重新扫描媒体库",
            
            // Common
            @"Open Containing Folder": @"打开所在文件夹",
            @"Show in Finder": @"在Finder中显示",
            @"Properties": @"属性", @"Get Info": @"获取信息",
            @"DSP Manager": @"DSP管理器", @"Converter": @"转换器",
            @"Converter Setup...": @"转换器设置...", @"Equalizer": @"均衡器",
            @"Status Bar": @"状态栏", @"Toolbar": @"工具栏",
            @"Sidebar": @"侧边栏",
            
            // Dialogs
            @"OK": @"确定", @"Cancel": @"取消", @"Apply": @"应用",
            @"Close": @"关闭", @"Save": @"保存", @"Don't Save": @"不保存",
            @"Yes": @"是", @"No": @"否", @"Continue": @"继续",
            
            // About
            @"About foobar2000": @"关于 foobar2000",
            @"Check for Updates...": @"检查更新...",
            
            // Layout
            @"Layout": @"布局", @"Create Layout...": @"创建布局...",
            @"Edit Layout...": @"编辑布局...", @"Delete Layout": @"删除布局",
            
            // Playlist
            @"Rename Playlist...": @"重命名播放列表...",
            @"Remove Playlist": @"移除播放列表", @"Clear Playlist": @"清空播放列表",
            @"Filter...": @"过滤...",
            
            // Other
            @"Console": @"控制台", @"Always on Top": @"始终置顶",
            @"Minimize": @"最小化", @"Zoom": @"缩放",
            @"Bring All to Front": @"全部置于顶层",
            @"Keyboard Shortcuts...": @"键盘快捷键...",
            @"Reset Shortcuts": @"重置快捷键",
        };
        
        LOG("Translation map loaded: %lu entries", (unsigned long)gTranslationMap.count);
        
        // Swizzle: NSMenuItem setTitle:
        Method m1 = class_getInstanceMethod([NSMenuItem class], @selector(setTitle:));
        if (m1) {
            original_setTitle = (void*)method_getImplementation(m1);
            method_setImplementation(m1, (IMP)hooked_setTitle);
            LOG("Hooked: NSMenuItem setTitle:");
        }
        
        // Swizzle: NSMenuItem setAttributedTitle:
        Method m2 = class_getInstanceMethod([NSMenuItem class], @selector(setAttributedTitle:));
        if (m2) {
            original_setAttributedTitle = (void*)method_getImplementation(m2);
            method_setImplementation(m2, (IMP)hooked_setAttributedTitle);
            LOG("Hooked: NSMenuItem setAttributedTitle:");
        }
        
        // Swizzle: NSMenuItem initWithTitle:action:keyEquivalent:
        Method m3 = class_getInstanceMethod([NSMenuItem class], @selector(initWithTitle:action:keyEquivalent:));
        if (m3) {
            original_initWithTitle = (void*)method_getImplementation(m3);
            method_setImplementation(m3, (IMP)hooked_initWithTitle);
            LOG("Hooked: NSMenuItem initWithTitle:action:keyEquivalent:");
        }
        
        // Register for app launch notification
        [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationDidFinishLaunchingNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) { app_did_launch(n); }];
        
        // Register for menu change notifications
        [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidAddItemNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) { menu_did_change(n); }];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidChangeItemNotification
                                                          object:nil queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *n) { menu_did_change(n); }];
        
        LOG("All hooks installed. Waiting for app launch...");
    }
}

__attribute__((destructor))
static void fb2k_chinese_cleanup(void) {
    LOG("=== fb2k_hook_v2 unloaded ===");
    if (gLogFile) fclose(gLogFile);
}