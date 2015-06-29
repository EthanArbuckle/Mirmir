//
//  CDTLamoActivatorEventMaximize.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventMaximize.h"

@implementation CDTLamoActivatorEventMaximize

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Maximize";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Maximize the top Mímir window";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //get identifier and create application
    if ([(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] respondsToSelector:@selector(identifier)]) {
        
        NSString *identifier = [(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] identifier];
        SBApplication *appToOpen = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identifier];
        
        //send to fullscreen
        [[CDTLamo sharedInstance] launchFullModeFromWindowForApplication:appToOpen];
    }
    
    [event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
