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

@interface ReFinder : NSObject
+ (instancetype)sharedInstance;
@end
