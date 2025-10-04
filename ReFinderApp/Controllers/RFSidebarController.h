//
//  RFSidebarController.h
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import <Cocoa/Cocoa.h>
#import "../Classes/RFSidebarCell.h"
#import "../Classes/RFTableRowView.h"

@interface RFSidebarController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
@property (strong) IBOutlet NSTableView *tableView;
@end
