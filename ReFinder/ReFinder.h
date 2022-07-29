//
//  ReFinder.h
//  ReFinder
//
//  Created by MTAC on 12/26/21.
//
//

@import AppKit;

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "ZKSwizzle/ZKSwizzle.h"
#import "ReFinderPreferencesController.h"

@interface ReFinder : NSObject
+ (instancetype)sharedInstance;
- (NSMenu *)reFinderMenu;
- (void)restartFinder;
- (void)restartDock;
- (void)openSourceCode;
@end
