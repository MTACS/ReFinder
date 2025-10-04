//
//  RFSplitView.m
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import "RFSplitView.h"

@implementation RFSplitView
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlurStyle) name:@"RFUpdateBlurStyle" object:nil];
    }
    return self;
}
- (void)updateBlurStyle {
    NSLog(@"[REFINDER] Update");
    
    NSView *first = [self.subviews objectAtIndex:0];
    NSVisualEffectView *effectView = [first.subviews firstObject];
    
    NSInteger selectedBlurStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedBlurStyle"] integerValue];
    [effectView setMaterial:(NSVisualEffectMaterial)selectedBlurStyle];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self updateBlurStyle];
}
- (CGFloat)dividerThickness {
    return 0.5;
}
- (NSColor *)dividerColor {
    return [NSColor separatorColor];
}
@end
