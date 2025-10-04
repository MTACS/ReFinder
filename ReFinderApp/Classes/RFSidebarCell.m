//
//  RFSidebarCell.m
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import "RFSidebarCell.h"

@implementation RFSidebarCell
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    self.imageView.imageScaling = NSImageScaleProportionallyUpOrDown;
}
@end
