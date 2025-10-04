//
//  RFController.m
//  ReFinderApp
//
//  Created by MTAC on 8/2/23.
//

#import "RFController.h"

NSUserDefaults *defaults;

BOOL containsKey(NSString *key) {
    return [defaults.dictionaryRepresentation.allKeys containsObject:key];
}

@implementation RFController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabSelectionChanged:) name:@"RFTabSelectionChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutView) name:@"RFShowAboutView" object:nil];
    
    [self.tabView selectTabViewItemAtIndex:0];
}
- (void)tabSelectionChanged:(NSNotification *)notification {
    NSDictionary *tabDict = notification.userInfo;
    NSInteger selectedIndex = [[tabDict objectForKey:@"selectedTab"] integerValue];
    [self.tabView selectTabViewItemAtIndex:selectedIndex];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}
- (IBAction)viewSource:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/MTACS/ReFinder"]];
}
- (void)loadDefaults {
    if (!defaults) defaults = [NSUserDefaults standardUserDefaults];
    
    if (!containsKey(@"useTranslucency")) {
        [defaults setBool:YES forKey:@"useTranslucency"];
    }
    
    if (!containsKey(@"hideSidebarScroller")) {
        [defaults setBool:YES forKey:@"hideSidebarScroller"];
    }
    
    if (!containsKey(@"hideFolderScroller")) {
        [defaults setBool:YES forKey:@"hideFolderScroller"];
    }
    
    if (!containsKey(@"useVibrantDivider")) {
        [defaults setBool:YES forKey:@"useVibrantDivider"];
    }
    
    if (!containsKey(@"addCopyPathItem")) {
        [defaults setBool:NO forKey:@"addCopyPathItem"];
    }
    
    if (!containsKey(@"addNewFileItem")) {
        [defaults setBool:NO forKey:@"addNewFileItem"];
    }
    
    if (!containsKey(@"showFileSize")) {
        [defaults setBool:NO forKey:@"showFileSize"];
    }
    
    if (!containsKey(@"selectedBlurStyle")) {
        [defaults setObject:@(6) forKey:@"selectedBlurStyle"];
    }
    
    [defaults synchronize];
    [self loadPreferences];
}
- (void)loadPreferences {
    self.translucencySwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useTranslucency"] boolValue] ?: YES;
    
    self.sidebarScrollSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hideSidebarScroller"] boolValue] ?: YES;
    
    self.folderScrollSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"hideFolderScroller"] boolValue] ?: YES;
    
    self.splitDividerSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"useVibrantDivider"] boolValue] ?: YES;
    
    self.pathSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"addCopyPathItem"] boolValue] ?: NO;
    
    self.fileSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"addNewFileItem"] boolValue] ?: NO;
    
    self.fileSizeSwitch.state = (NSControlStateValue)[[defaults objectForKey:@"showFileSize"] boolValue] ?: NO;
    
    NSNumber *selectedBlurStyle = [defaults objectForKey:@"selectedBlurStyle"];
    
    NSMenuItem *selectedBlurItem;
    for (NSMenuItem *item in self.blurStyleButton.itemArray) {
        BOOL selected = (item.tag == [selectedBlurStyle integerValue]);
        item.state = selected ? NSControlStateValueOn : NSControlStateValueOff;
        if (selected) {
            selectedBlurItem = item;
        }
    }
    [self.blurStyleButton selectItem:selectedBlurItem];
}
- (IBAction)translucencySwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useTranslucency"];
    [defaults synchronize];
}
- (IBAction)sidebarScrollSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"hideSidebarScroller"];
    [defaults synchronize];
}
- (IBAction)folderScrollSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"hideFolderScroller"];
    [defaults synchronize];
}
- (IBAction)splitDividerSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"useVibrantDivider"];
    [defaults synchronize];
}
- (IBAction)pathSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"addCopyPathItem"];
    [defaults synchronize];
}
- (IBAction)fileSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"addNewFileItem"];
    [defaults synchronize];
}
- (IBAction)fileSizeSwitchChanged:(NSSwitch *)sender {
    [defaults setObject:@(sender.state) forKey:@"showFileSize"];
    [defaults synchronize];
}
- (IBAction)blurStyleChanged:(NSPopUpButton *)sender {
    NSMenuItem *selectedItem = sender.selectedItem;
    [defaults setObject:@(selectedItem.tag) forKey:@"selectedBlurStyle"];
    [defaults synchronize];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"RFUpdateBlurStyle" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RFUpdateBlurStyle" object:nil];
}
- (BOOL)checkNumber:(NSString *)input {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    NSNumber *checkNumber = [numberFormatter numberFromString:input];
    return checkNumber != nil;
}
- (void)showAboutView {
    [self.tabView selectTabViewItemAtIndex:3];
}
@end
