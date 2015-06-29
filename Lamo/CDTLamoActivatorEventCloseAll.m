//
//  CDTLamoActivatorEventCloseAll.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventCloseAll.h"

@implementation CDTLamoActivatorEventCloseAll

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Close all";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Close all Mímir windows";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"lamo 3";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //close all
    [[CDTLamo sharedInstance] snapAllClose:YES];
    
    [event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
