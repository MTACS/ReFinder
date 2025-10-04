//
//  RFWindowController.m
//  ReFinderApp
//
//  Created by MTAC on 8/2/23.
//

#import "RFWindowController.h"

NSUserDefaults *preferences;

NSVisualEffectMaterial selectedBlurMaterial(void) {
    NSInteger selectedBlurStyle = [[preferences objectForKey:@"selectedBlurStyle"] integerValue];
    return (NSVisualEffectMaterial)selectedBlurStyle;
}

@interface RFWindowController ()
@end

@implementation RFWindowController
- (id)init {
    self = [super init];
    if (self) {
        preferences = [NSUserDefaults standardUserDefaults];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBlurStyle) name:@"RFUpdateBlurStyle" object:nil];
    }
    return self;
}
- (void)objectDidBecomeKey:(NSNotification *)notification {
    [self removeBackground:[notification object]];
}
- (void)updateBlurStyle {
    [self.effectView setMaterial:selectedBlurMaterial()];
}
- (void)windowDidLoad {
    [super windowDidLoad];
    [self removeBackground:self.window];
}
- (void)removeBackground:(NSWindow *)window {
    [window setBackgroundColor:[NSColor clearColor]];
   
    self.effectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, window.contentView.bounds.size.width, window.contentView.bounds.size.height + 30)];
    [self.effectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.effectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [self.effectView setState:NSVisualEffectStateActive];
    if (![self.effectView isDescendantOf:window.contentView]) {
        [[window contentView] addSubview:self.effectView positioned:NSWindowBelow relativeTo:nil];
    }

    [window.contentView setWantsLayer:YES];
    window.contentView.layer.backgroundColor = [NSColor clearColor].CGColor;
    
    [self updateBlurStyle];
}
@end
