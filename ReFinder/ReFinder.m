//
//  ReFinder.m
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//
//

#import "ReFinder.h"

ReFinder *plugin;

@implementation ReFinder
+ (instancetype)sharedInstance {
    static ReFinder *plugin = nil;
    if (plugin == nil) {
        plugin = [[ReFinder alloc] init];
    }
    return plugin;
}
+ (void)load {
    plugin = [ReFinder sharedInstance];
    NSUInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    NSLog(@"[REFINDER] : %@ loaded into %@ on macOS 10.%ld", [plugin class], [[NSBundle mainBundle] bundleIdentifier], (long)osx_ver);
    NSMenu *mainFinderMenu = [[[[NSApp mainMenu] itemArray] firstObject] submenu];
    [mainFinderMenu addItem:[NSMenuItem separatorItem]];
    [[mainFinderMenu addItemWithTitle:@"Restart Finder" action:@selector(restartFinder) keyEquivalent:@""] setTarget:plugin];
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
