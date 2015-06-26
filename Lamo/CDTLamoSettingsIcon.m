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
        
        return @"lamo prefs";
    }

    return ZKOrig(NSString *);
    
}

-(id)generateIconImage:(int)ifmage {
    
    //create rounded icon image
    UIImage *image = [UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/icon.png"];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 120, 120) cornerRadius:33.0] addClip];
    [image drawInRect:CGRectMake(0, 0, 120, 120)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end