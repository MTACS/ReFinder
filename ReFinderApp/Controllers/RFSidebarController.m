//
//  RFSidebarController.m
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import "RFSidebarController.h"

@interface RFSidebarController ()
@end

@implementation RFSidebarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.target = self;
    self.tableView.action = @selector(tableViewClicked:);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAboutView) name:@"RFShowAboutView" object:nil];
    
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
    
    // [self.tableView editColumn:0 row:0 withEvent:nil select:YES];
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"RFSidebarCell" bundle:nil] forIdentifier:@"sidebarCell"];
}
- (void)showAboutView {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:3] byExtendingSelection:NO];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 4;
}
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 36.0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *titles = @[@"Appearance", @"Menus", @"Quick Look", @"About"];
    NSArray *images = @[@"appearance", @"menu", @"quicklook", @"info"];
    RFSidebarCell *cell = [tableView makeViewWithIdentifier:@"sidebarCell" owner:self];
    [cell.titleLabel setStringValue:titles[row]];
    [cell.imageView setImage:[NSImage imageNamed:images[row]]];
    [cell.imageView.image setTemplate:YES];
    return cell;
}
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    RFTableRowView *rowView = [tableView makeViewWithIdentifier:@"tableRowView" owner:self];
    if (!rowView) {
        rowView = [[RFTableRowView alloc] initWithFrame:NSZeroRect];
        rowView.identifier = @"tableRowView";
    }
    return rowView;
}
- (NSImage *)symbolImage:(NSImage *)image {
    NSImage *scaledImage = [[NSImage alloc] initWithSize:CGSizeMake(20, 20)];
    [scaledImage lockFocus];
    [image setSize:CGSizeMake(20, 20)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [image drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, 20, 20) operation:NSCompositingOperationCopy fraction:1.0];
    [scaledImage unlockFocus];
    return scaledImage;
}
- (void)tableViewClicked:(id)sender {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow != -1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RFTabSelectionChanged" object:nil userInfo:@{@"selectedTab" : [NSNumber numberWithInteger:selectedRow]}];
    }
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
     NSInteger selectedRow = [self.tableView selectedRow];
    if (selectedRow != -1) {
        RFTableRowView *myRowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
        [myRowView setEmphasized:YES];
    }
}
@end
