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
    
    [[NSClassFromString(@"LAActivator") sharedInstance] registerListener:[CDTLamoActivatorEventCloseAll new] forName:@"com.cortexdevteam.lamo.closeall"];
}

@end
