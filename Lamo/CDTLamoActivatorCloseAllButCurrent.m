//
//  CDTLamoActivatorCloseAllButCurrent.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorCloseAllButCurrent.h"

@implementation CDTLamoActivatorCloseAllButCurrent

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Close All But Current";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Close all Mímir windows except for the top one";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //cycle subviews and end all that arent current top window
    for (UIView *subview in [[[CDTLamo sharedInstance] springboardWindow] subviews]) {
        
        //make sure its not top
        if (subview != [[CDTLamo sharedInstance] topmostApplicationWindow]) {
            
            if ([subview respondsToSelector:@selector(identifier)]) {
                
                NSString *identifier = [(CDTLamoWindow *)subview identifier];
                [[CDTLamo sharedInstance] unwindowApplicationWithBundleID:identifier];
                
                [event setHandled:YES];
            }
        }
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
