//
//  CDTLamoActivatorEventPassthrough.m
//  Lamo
//
//  Created by Ethan Arbuckle on 7/6/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventPassthrough.h"

@implementation CDTLamoActivatorEventPassthrough

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Passthrough";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Access area behind Mírmir windows for 2 seconds";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //Get all windows
    NSArray *allWindows = [[[CDTLamo sharedInstance] mutableWindowDict] allValues];
    
    [UIView animateWithDuration:.3 animations:^{
        
        //cycle through and passththrough
        for (CDTLamoWindow *currentWindow in allWindows) {
            
            [currentWindow setAlpha:0];
            [currentWindow setUserInteractionEnabled:NO];
        }
        
    }];
    
    //set them all to be restored 2 seconds later
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.3 animations:^{
            
            //cycle through and restore
            for (CDTLamoWindow *currentWindow in allWindows) {
                
                [currentWindow setAlpha:1];
                [currentWindow setUserInteractionEnabled:YES];
            }
            
        }];
        
    });
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/icon-small.png"];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
