//
//  RFController.h
//  ReFinderApp
//
//  Created by MTAC on 8/2/23.
//

#import <Cocoa/Cocoa.h>

@interface RFController : NSViewController <NSTextFieldDelegate>
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSSwitch *translucencySwitch;
@property (strong) IBOutlet NSSwitch *sidebarScrollSwitch;
@property (strong) IBOutlet NSSwitch *folderScrollSwitch;
@property (strong) IBOutlet NSSwitch *splitDividerSwitch;
@property (strong) IBOutlet NSSwitch *pathSwitch;
@property (strong) IBOutlet NSSwitch *fileSwitch;
@property (strong) IBOutlet NSSwitch *fileSizeSwitch;
@property (strong) IBOutlet NSPopUpButton *blurStyleButton;
- (void)loadDefaults;
- (void)loadPreferences;
@end

