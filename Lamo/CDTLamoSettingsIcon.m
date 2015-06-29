//
//  CDTLamoSettingsIcon.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/6/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "Lamo.h"
#import <objc/runtime.h>
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBLeafIcon, SBLeafIcon, UIView);

@implementation $_Lamo_SBLeafIcon

- (BOOL)launchEnabled {
    
    if ([[self valueForKey:@"_leafIdentifier"] isEqualToString:@"lamo"]) {
        
        return YES;
    }
    
    return ZKOrig(BOOL);
    
}

- (NSString *)displayName {
    
    if ([[self valueForKey:@"_leafIdentifier"] isEqualToString:@"lamo"]) {
        
        return @"mímir prefs";
    }

    return ZKOrig(NSString *);
    
}

-(id)generateIconImage:(int)ifmage {
    
    //create rounded icon image
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/Icon.png"];
}

@end