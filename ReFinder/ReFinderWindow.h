//
//  ReFinderWindow.h
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//

#import <Cocoa/Cocoa.h>
#import "ReFinder.h"

@interface ReFinderWindow : NSWindow
@property (strong) IBOutlet NSSwitch *compactSwitch;
@property (strong) IBOutlet NSSwitch *fileSwitch;
@property (strong) IBOutlet NSSwitch *editSwitch;
@property (strong) IBOutlet NSSwitch *viewSwitch;
@property (strong) IBOutlet NSSwitch *goSwitch;
@property (strong) IBOutlet NSSwitch *windowSwitch;
@property (strong) IBOutlet NSSwitch *helpSwitch;
@end
