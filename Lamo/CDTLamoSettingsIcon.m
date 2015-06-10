//
//  CDTLamoSettingsIcon.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/6/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoSettingsIcon.h"
#import "Lamo.h"
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBLeafIcon, SBApplicationIcon, UIView);

@implementation $_Lamo_SBLeafIcon

- (BOOL)launchEnabled {
    
    if ([[self valueForKey:@"_leafIdentifier"] isEqualToString:@"lamo"]) {
        
        return YES;
    }
    
    return ZKOrig(BOOL);
    
}

-(void)touchesEnded:(id)ended withEvent:(id)event {
    
    [[[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil] show];
    if ([[self valueForKey:@"_leafIdentifier"] isEqualToString:@"lamo"]) {
        NSLog(@"open");
    }
    
    return ZKOrig(void);
    
}
- (NSString *)displayName {
    
    if ([[self valueForKey:@"_leafIdentifier"] isEqualToString:@"lamo"]) {
        
        return @"Lamo Settings";
    }
    
    return ZKOrig(NSString *);
    
}

@end