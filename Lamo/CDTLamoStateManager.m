//
//  CDTLamoStateManager.m
//  Lamo
//
//  Created by Ethan Arbuckle on 5/17/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoStateManager.h"

@implementation CDTLamoStateManager

+ (void)saveWindowStatesFromDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *dictToFile = [[NSMutableDictionary alloc] init];
    
    //cycle idents
    for (NSString *identifier in [dictionary allKeys]) {
        
        NSMutableDictionary *currentWindow = [[NSMutableDictionary alloc] init];
        [currentWindow setValue:identifier forKey:@"bundleID"];
        
        //fuck these orientations not being able to go straight into a dict
        UIInterfaceOrientation *orientation = [(CDTLamoWindow *)[dictionary valueForKey:identifier] activeOrientation];
        if (orientation == (UIInterfaceOrientation *)UIInterfaceOrientationPortrait) {
            
            [currentWindow setValue:@"portrait" forKey:@"orientation"];
        }
        else {
            
            [currentWindow setValue:@"landscape" forKey:@"orientation"];
        }
        
        [currentWindow setObject:[NSValue valueWithCGRect:[(CDTLamoWindow *)[dictionary valueForKey:identifier] frame]] forKey:@"frame"];
        
        [currentWindow setValue:NSStringFromCGAffineTransform([(CDTLamoWindow *)[dictionary valueForKey:identifier] transform]) forKey:@"transform"];
        
        [dictToFile setObject:currentWindow forKey:identifier];
        
    }
}

+ (void)restoreWindowsOntoView:(UIView *)view {
    
}

@end
