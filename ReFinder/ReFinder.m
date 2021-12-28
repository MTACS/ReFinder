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
    
    NSMenu *mainFinderMenu = [[[[NSApp mainMenu] itemArray] firstObject] submenu];
    
    NSMenu *reFinderSubMenu = [[NSMenu alloc] initWithTitle:@"ReFinder"];
    NSMenuItem *restartItem = [[NSMenuItem alloc] init];
    [restartItem setTitle:@"Restart Finder"];
    [restartItem setKeyEquivalent:@""];
    [restartItem setTarget:plugin];
    [restartItem setAction:@selector(restartFinder)];
    [reFinderSubMenu addItem:restartItem];
    
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    NSMenu *reFinderTools = [[NSMenu alloc] initWithTitle:@"Tools"];
    
    NSMenuItem *toggleHiddenItem = [[NSMenuItem alloc] init];
    [toggleHiddenItem setTarget:plugin];
    [toggleHiddenItem setAction:@selector(toggleHidden:)];
    [toggleHiddenItem setKeyEquivalent:@""];
    if ([plugin hiddenFilesAreShown]) {
        [toggleHiddenItem setTitle:@"Hide Hidden Files"];
    } else {
        [toggleHiddenItem setTitle:@"Show Hidden Files"];
    }
    [reFinderTools addItem:toggleHiddenItem];
    
    [reFinderTools addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *toggleDesktopItem = [[NSMenuItem alloc] init];
    [toggleDesktopItem setTarget:plugin];
    [toggleDesktopItem setAction:@selector(toggleDesktop:)];
    [toggleDesktopItem setKeyEquivalent:@""];
    if ([plugin desktopIconsAreShown]) {
        [toggleDesktopItem setTitle:@"Hide Desktop Icons"];
    } else {
        [toggleDesktopItem setTitle:@"Show Desktop Icons"];
    }
    [reFinderTools addItem:toggleDesktopItem];
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] initWithTitle:@"ReFinder" action:nil keyEquivalent:@""];
    
    NSMenuItem *reFinderToolsItem = [[NSMenuItem alloc] initWithTitle:@"Tools" action:nil keyEquivalent:@""];
    [reFinderSubMenu addItem:reFinderToolsItem];
    [mainFinderMenu setSubmenu:reFinderTools forItem:reFinderToolsItem];
    
    [mainFinderMenu addItem:[NSMenuItem separatorItem]];
    [mainFinderMenu addItem:reFinderItem];
    [mainFinderMenu setSubmenu:reFinderSubMenu forItem:reFinderItem];
    
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    
    [[reFinderSubMenu addItemWithTitle:@"Preferences" action:@selector(showPreferences) keyEquivalent:@""] setTarget:plugin];
}
- (void)loadSections {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    NSMenu *mainFinderMenu = [NSApp mainMenu];
    for (NSMenuItem *item in mainFinderMenu.itemArray) { // Feels like it could be done cleaner
        if ([[finderDictionary objectForKey:@"hideFileItem"] boolValue] == 1 && [item.title isEqualToString:@"File"]) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideEditItem"] boolValue] == 1 && [item.title isEqualToString:@"Edit"]) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideViewItem"] boolValue] == 1 && [item.title isEqualToString:@"View"]) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideGoItem"] boolValue] == 1 && [item.title isEqualToString:@"Go"]) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideWindowItem"] boolValue] == 1 && [item.title isEqualToString:@"Window"]) {
            [item setHidden:YES];
        }
        if ([[finderDictionary objectForKey:@"hideHelpItem"] boolValue] == 1 && [item.title isEqualToString:@"Help"]) {
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
    NSLog(@"[REFINDER] : Relaunching");
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
    [field setStringValue:[NSString stringWithFormat:@"%@\n\nReFinder 1.1 © MTAC", field.stringValue]];
}
@end


