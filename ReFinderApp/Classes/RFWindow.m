//
//  RFWindow.m
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import "RFWindow.h"

@implementation RFWindow
@synthesize effectView;
- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlurStyle) name:@"RFUpdateBlurStyle" object:nil];
    }
    return self;
}
- (void)updateBlurStyle {
    NSInteger selectedBlurStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedBlurStyle"] integerValue];
    [effectView setMaterial:(NSVisualEffectMaterial)selectedBlurStyle];
}
- (void)becomeKeyWindow {
    [super becomeKeyWindow];
    [self updateTransparency];
}
- (void)updateTransparency {
    if (!effectView) {
        effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height + 30)];
        [effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [[self contentView] addSubview:effectView positioned:NSWindowBelow relativeTo:nil];
        [self.contentView setWantsLayer:YES];
    }
    [effectView setState:NSVisualEffectStateActive];
    
    [self updateBlurStyle];
}
@end
