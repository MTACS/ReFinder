//
//  AppDelegate.m
//  ReFinderApp
//
//  Created by DF on 3/2/25.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
- (IBAction)showAboutView:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RFShowAboutView" object:nil];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
- (IBAction)resetPreferences:(id)sender {
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:@"com.mtac.refinder"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
