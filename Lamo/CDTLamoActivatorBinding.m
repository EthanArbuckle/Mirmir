//
//  CDTLamoActivatorBinding.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorBinding.h"
#import <dlfcn.h>

@implementation CDTLamoActivatorBinding

+ (id)sharedBinding {
    
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (BOOL)activatorSupported {
    
    //see if we can create a activator class
    dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
    Class activatorClass = NSClassFromString(@"LAActivator");
    
    //if it exists, we have activator
    if (activatorClass) {
        
        return YES;
    }
    
    return NO;
}

- (void)setupActivatorActions {
    
    //stop if activator isnt installed
    if (![self activatorSupported]) {
        
        return;
    }
    
    //setup events
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventCloseAll new] forName:@"com.cortexdevteam.lamo.closeall"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventCloseCurrent new] forName:@"com.cortexdevteam.lamo.closecurrent"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorCloseAllButCurrent new] forName:@"com.cortexdevteam.lamo.closebackground"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventTriggerOverlay new] forName:@"com.cortexdevteam.lamo.triggeroverlay"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventReorientate new] forName:@"com.cortexdevteam.lamo.reorientate"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventMaximize new] forName:@"com.cortexdevteam.lamo.maximize"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventMinimize new] forName:@"com.cortexdevteam.lamo.minimize"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventPassthrough new] forName:@"com.cortexdevteam.lamo.passthrough"];
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventSettings new] forName:@"com.cortexdevteam.lamo.settings"];
}

@end
