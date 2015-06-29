//
//  CDTLamoActivatorEventTriggerOverlay.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventTriggerOverlay.h"

@implementation CDTLamoActivatorEventTriggerOverlay

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Trigger Overlay";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Show the options overlay for the top Mímir window";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //fake a tap to the bar if it exists
    if ([[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] respondsToSelector:@selector(handleTap:)]) {
       
        [(CDTLamoBarView *)[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] handleTap:nil];
    }
    
    [event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
