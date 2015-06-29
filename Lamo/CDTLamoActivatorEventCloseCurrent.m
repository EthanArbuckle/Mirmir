//
//  CDTLamoActivatorEventCloseCurrent.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventCloseCurrent.h"

@implementation CDTLamoActivatorEventCloseCurrent

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Close Current";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Close the topmost Mímir window";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //close window
    if ([(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] respondsToSelector:@selector(identifier)]) {
        NSString *identifier = [(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] identifier];
        [[CDTLamo sharedInstance] unwindowApplicationWithBundleID:identifier];
    
        [event setHandled:YES];
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
