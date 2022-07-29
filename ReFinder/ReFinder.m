//
//  ReFinder.m
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//
//

#import "ReFinder.h"

ReFinder *plugin;
NSUserDefaults *defaults;
NSMutableDictionary *finderDictionary;
static NSUserDefaults *preferences = nil;
static NSDictionary *preferencesDict = nil;

@implementation ReFinder
+ (instancetype)sharedInstance {
    static ReFinder *plugin = nil;
    if (plugin == nil) {
        plugin = [[ReFinder alloc] init];
    }
    return plugin;
}
+ (void)load {
    defaults = [NSUserDefaults standardUserDefaults];
    plugin = [ReFinder sharedInstance];
    [plugin loadSections];
    
    NSUInteger osx_ver_min = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSUInteger osx_ver_maj = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
    
    NSLog(@"[REFINDER] : %@ loaded into %@ on macOS %ld.%ld", [plugin class], [[NSBundle mainBundle] bundleIdentifier], (long)osx_ver_maj, (long)osx_ver_min);
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] init];
    [reFinderItem setTitle:@"ReFinder"];
    
    NSMenu *mainFinderMenu = [[[[NSApp mainMenu] itemArray] firstObject] submenu];
    [mainFinderMenu addItem:[NSMenuItem separatorItem]];
    [mainFinderMenu addItem:reFinderItem];
    [mainFinderMenu setSubmenu:[plugin reFinderMenu] forItem:reFinderItem];
}
- (NSMenu *)reFinderMenu {
    NSMenu *reFinderSubMenu = [[NSMenu alloc] initWithTitle:@"ReFinder"];
    NSMenuItem *restartItem = [[NSMenuItem alloc] init];
    [restartItem setTitle:@"Restart Finder"];
    [restartItem setTarget:plugin];
    [restartItem setAction:@selector(restartFinder)];
    [reFinderSubMenu addItem:restartItem];
    
    
    NSMenuItem *restartDockItem = [[NSMenuItem alloc] init];
    [restartDockItem setTarget:plugin];
    [restartDockItem setAction:@selector(restartDock)];
    [restartDockItem setTitle:@"Restart Dock"];
    [reFinderSubMenu addItem:restartDockItem];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    
    NSMenuItem *toggleHiddenItem = [[NSMenuItem alloc] init];
    [toggleHiddenItem setTarget:plugin];
    [toggleHiddenItem setAction:@selector(toggleHidden:)];
    if ([plugin hiddenFilesAreShown]) {
        [toggleHiddenItem setTitle:@"Hide Hidden Files"];
    } else {
        [toggleHiddenItem setTitle:@"Show Hidden Files"];
    }
    [reFinderSubMenu addItem:toggleHiddenItem];
    
    NSMenuItem *toggleDesktopItem = [[NSMenuItem alloc] init];
    [toggleDesktopItem setTarget:plugin];
    [toggleDesktopItem setAction:@selector(toggleDesktop:)];
    if ([plugin desktopIconsAreShown]) {
        [toggleDesktopItem setTitle:@"Hide Desktop Icons"];
    } else {
        [toggleDesktopItem setTitle:@"Show Desktop Icons"];
    }
    [reFinderSubMenu addItem:toggleDesktopItem];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    
    [[reFinderSubMenu addItemWithTitle:@"Preferences" action:@selector(showPreferences) keyEquivalent:@""] setTarget:plugin];
    
    return reFinderSubMenu;
}
- (void)loadSections {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    NSMenu *mainFinderMenu = [NSApp mainMenu];
    NSLog(@"[REFINDER] : %@", mainFinderMenu.itemArray);
    for (NSMenuItem *item in mainFinderMenu.itemArray) { // Feels like it could be done cleaner
        if ([[finderDictionary objectForKey:@"hideFileItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 1) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideEditItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 2) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideViewItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 3) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideGoItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 4) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideWindowItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 5) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideHelpItem"] boolValue] == 1 && [mainFinderMenu.itemArray indexOfObject:item] == 6) {
            [item setHidden:YES];
        }
    }
}
- (void)showPreferences {
    ReFinderPreferencesController *prefsController = [[ReFinderPreferencesController alloc] init];
    NSWindow *prefsWindow = [prefsController window];
    [prefsWindow setStyleMask:prefsWindow.styleMask|NSWindowStyleMaskFullSizeContentView];
    NSVisualEffectView *vibrant = [[NSClassFromString(@"NSVisualEffectView") alloc] initWithFrame:[[prefsWindow contentView] bounds]];
    [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [vibrant setIdentifier:@"rfView"];
    [[prefsWindow contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
    [prefsWindow makeKeyAndOrderFront:plugin];
}
- (void)toggleHidden:(NSMenuItem *)sender {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    if ([plugin hiddenFilesAreShown]) {
        [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"AppleShowAllFiles"];
        [sender setTitle:@"0"];
    } else {
        [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"AppleShowAllFiles"];
        [sender setTitle:@"1"];
    }
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
}
- (void)toggleDesktop:(id)sender {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];

    if ([plugin desktopIconsAreShown]) {
        [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"CreateDesktop"];
        [sender setTitle:@"0"];
    } else {
        [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"CreateDesktop"];
        [sender setTitle:@"1"];
    }
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
}
- (BOOL)hiddenFilesAreShown {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    return [[finderDictionary objectForKey:@"AppleShowAllFiles"] boolValue];
}
- (BOOL)desktopIconsAreShown {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    return [[finderDictionary objectForKey:@"CreateDesktop"] boolValue];
}

// https://github.com/w0lfschild/podcastsPlus/blob/182809f07326f5364954addc47ccd0dd8e83d6de/podcastsPlus/podcastsPlus.m#L424

- (void)restartFinder {
    NSLog(@"[REFINDER] : Relaunching Finder");
    float seconds = 1.0;
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %f; open \"%@\"", seconds, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    [NSApp terminate:nil];
}
- (void)restartDock {
    NSLog(@"[REFINDER] : Relaunching Dock");
    NSTask *task = [[NSTask alloc] init];
    NSArray *args = [NSArray arrayWithObjects:@"-c", @"killall Dock", nil];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
}
- (void)openSourceCode {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/MTACS/ReFinder"]];
}
- (void)initializePrefs {
    if (!preferences) {
        preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.mtac.refinder"];
        preferencesDict = [preferences dictionaryRepresentation];
    }
    [preferences synchronize];
}
@end

ZKSwizzleInterface(rf_AboutController, TAboutWindowController, NSWindowController)
@implementation rf_AboutController
- (void)windowDidLoad {
    ZKOrig(void);
    NSTextField *field = (NSTextField *)[self.window.contentView.subviews lastObject];
    [field setStringValue:[NSString stringWithFormat:@"%@\n\nReFinder 1.2 © MTAC", field.stringValue]];
}
@end

ZKSwizzleInterface(rf_TApplicationController, TApplicationController, NSResponder)
@implementation rf_TApplicationController
- (id)applicationDockMenu:(id)arg1 {
    NSMenu *dockMenu = ZKOrig(id, arg1);
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] init];
    [reFinderItem setTitle:@"ReFinder"];
    
    [dockMenu addItem:[NSMenuItem separatorItem]];
    [dockMenu addItem:reFinderItem];
    [dockMenu setSubmenu:[plugin reFinderMenu] forItem:reFinderItem];
    
    return dockMenu;
}
@end
