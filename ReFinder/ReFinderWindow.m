//
//  ReFinderWindow.m
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//

#import "ReFinderWindow.h"

static NSUserDefaults *preferences = nil;

@implementation ReFinderWindow
- (void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    preferences = [NSUserDefaults standardUserDefaults];
    [self setupToggles];
}
- (void)setupToggles {
    NSArray *keys = [NSArray arrayWithObjects:@"useCompactMenu", @"hideFileItem", @"hideEditItem", @"hideViewItem", @"hideGoItem", @"hideWindowItem", @"hideHelpItem", nil];
    for (NSString *prefsKey in keys) {
        if (![preferences integerForKey:prefsKey]) {
            [preferences setInteger:0 forKey:prefsKey];
        }
    }
    [self.compactSwitch setState:(NSControlStateValue)[preferences integerForKey:@"useCompactMenu"]];
    [self.fileSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideFileItem"]];
    [self.editSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideEditItem"]];
    [self.viewSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideViewItem"]];
    [self.goSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideGoItem"]];
    [self.windowSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideWindowItem"]];
    [self.helpSwitch setState:(NSControlStateValue)[preferences integerForKey:@"hideHelpItem"]];
}
- (IBAction)toggleCompact:(NSSwitch *)sender {
    NSString *key = @"useCompactMenu";
    if (sender.state == NSControlStateValueOn) {
        [preferences setInteger:1 forKey:key];
    } else if (sender.state == NSControlStateValueOff) {
        [preferences setInteger:0 forKey:key];
    }
    [preferences synchronize];
    NSLog(@"[REFINDER] : Compact Menu -> %ld", [preferences integerForKey:key]);
}
- (IBAction)toggleSwitch:(NSSwitch *)sender {
    NSString *key = sender.identifier;
    if (sender.state == NSControlStateValueOn) {
        [preferences setInteger:1 forKey:key];
    } else if (sender.state == NSControlStateValueOff) {
        [preferences setInteger:0 forKey:key];
    }
    [preferences synchronize];
    NSLog(@"[REFINDER] : Hide %@ Item -> %ld", sender.identifier, [preferences integerForKey:key]);
}
- (IBAction)restartFinder:(NSButton *)sender {
    [[ReFinder sharedInstance] restartFinder];
}
- (IBAction)openSourceCode:(NSButton *)sender {
    [[ReFinder sharedInstance] openSourceCode];
}
@end
