//
//  CDTLamoActivatorEventMinimize.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventMinimize.h"

@implementation CDTLamoActivatorEventMinimize

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Minimize";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Minimize the top Mímir window";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //get identifier
    if ([(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] respondsToSelector:@selector(identifier)]) {
        
        //get window
        CDTLamoWindow *window = (CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow];
        
        //animate scale back to min size
        [UIView animateWithDuration:0.3f animations:^{
            
            [window setTransform:CGAffineTransformMakeScale([[CDTLamoSettings sharedSettings] minimizedWindowSize], [[CDTLamoSettings sharedSettings] minimizedWindowSize])];
            
            //set frame to ensure window bar isnt out of screen bounds
            CGRect appWindowFrame = [window frame];
            
            if (appWindowFrame.origin.y <= 0) {
                
                //off of screen, bounce it back
                appWindowFrame.origin.y = 5;
            }
            
            if (appWindowFrame.origin.x <= 0) {
                
                //bounce this back too
                appWindowFrame.origin.x = 5;
            }
            
            [window setFrame:appWindowFrame];
            
            
        }];
    }
    
    [event setHandled:YES];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/icon-small.png"];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
