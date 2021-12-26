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
    
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    
    for (NSString *key in [finderDictionary allKeys]) {
        NSLog(@"[REFINDER] : Key/Value -> %@, %@", key, [finderDictionary objectForKey:key]);
    }
    
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSLog(@"[REFINDER] : %@ loaded into %@ on macOS 10.%ld", [plugin class], [[NSBundle mainBundle] bundleIdentifier], (long)osx_ver);
    
    NSMenu *mainFinderMenu = [[[[NSApp mainMenu] itemArray] firstObject] submenu];
    
    NSMenu *reFinderSubMenu = [[NSMenu alloc] initWithTitle:@"ReFinder"];
    [[reFinderSubMenu addItemWithTitle:@"Restart Finder" action:@selector(restartFinder) keyEquivalent:@""] setTarget:plugin];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    [[reFinderSubMenu addItemWithTitle:@"Show Hidden Files" action:@selector(showHidden) keyEquivalent:@""] setTarget:plugin];
    [[reFinderSubMenu addItemWithTitle:@"Hide Hidden Files" action:@selector(hideHidden) keyEquivalent:@""] setTarget:plugin];
    [reFinderSubMenu addItem:[NSMenuItem separatorItem]];
    [[reFinderSubMenu addItemWithTitle:@"Show Desktop Icons" action:@selector(showDesktopIcons) keyEquivalent:@""] setTarget:plugin];
    [[reFinderSubMenu addItemWithTitle:@"Hide Desktop Icons" action:@selector(hideDesktopIcons) keyEquivalent:@""] setTarget:plugin];
    
    NSMenuItem *reFinderItem = [[NSMenuItem alloc] initWithTitle:@"ReFinder" action:nil keyEquivalent:@""];
    
    [mainFinderMenu addItem:[NSMenuItem separatorItem]];
    [mainFinderMenu addItem:reFinderItem];
    [mainFinderMenu setSubmenu:reFinderSubMenu forItem:reFinderItem];
}
- (void)showHidden {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"AppleShowAllFiles"];
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
}
- (void)hideHidden {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"AppleShowAllFiles"];
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
}
- (void)showDesktopIcons {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    [finderDictionary setValue:[NSNumber numberWithBool:1] forKey:@"CreateDesktop"];
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
}
- (void)hideDesktopIcons {
    finderDictionary = [[defaults persistentDomainForName:@"com.apple.finder"] mutableCopy];
    [finderDictionary setValue:[NSNumber numberWithBool:0] forKey:@"CreateDesktop"];
    [defaults setPersistentDomain:finderDictionary forName:@"com.apple.finder"];
    [plugin restartFinder];
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
@end

ZKSwizzleInterface(rf_AboutController, TAboutWindowController, NSWindowController)
@implementation rf_AboutController
- (void)windowDidLoad {
    ZKOrig(void);
    NSTextField *field = (NSTextField *)[self.window.contentView.subviews lastObject];
    [field setStringValue:[NSString stringWithFormat:@"%@\n\nReFinder 1.0 © MTAC", field.stringValue]];
}
@end


