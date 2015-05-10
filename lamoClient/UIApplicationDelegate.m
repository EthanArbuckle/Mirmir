//
//  UIApplicationDelegate.m
//  Lamo
//
//  Created by Ethan Arbuckle on 5/9/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//
/*

#import "../Lamo/ZKSwizzle.h"
#import "../Lamo/Lamo.h"

#define NEED_IPAD_HAX UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

ZKSwizzleInterface($_Lamo_UIApplicationDelegate, UIResponder, NSObject);

@implementation $_Lamo_UIApplicationDelegate


-(BOOL)application:(id)application didFinishLaunchingWithOptions:(id)options {
    
    //if on ipad, manually reenable each windowed apps context hosting after this app has launched
    //This notification is observed by CDTContextHostProvider
    if (NEED_IPAD_HAX) {
        //TODO Fix this class from crashing the system :-)
        //TODO Add notification post
    }
    
    return ZKOrig(BOOL, application);
}

@end

*/