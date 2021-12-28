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

@interface ReFinder : NSObject // <NSUserInterfaceValidations>
+ (instancetype)sharedInstance;
- (void)restartFinder;
- (void)openSourceCode;
@end
