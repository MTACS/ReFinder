//
//  RFWindow.h
//  ReFinderApp
//
//  Created by DF on 1/30/25.
//

#import <Cocoa/Cocoa.h>

@interface RFWindow : NSWindow
@property (nonatomic, strong) NSVisualEffectView *effectView;
- (void)updateTransparency;
@end
