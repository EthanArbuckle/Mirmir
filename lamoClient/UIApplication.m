//
//  UIApplication.m
//  Lamo
//
//  Created by Ethan Arbuckle on 5/1/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "../Lamo/ZKSwizzle.h"
#import "../Lamo/Lamo.h"

ZKSwizzleInterface($_Lamo_UIApplication, UIApplication, NSObject);

@implementation $_Lamo_UIApplication

- (id)init {
    
    //we dont want to register springboard for notifications
    NSString *dispident = [(UIApplication *)self displayIdentifier];
    if (![dispident isEqualToString:@"com.apple.springboard"]) {

        //if we get here, we're inside an app. register notification for rotation
        //notification will be appidentifierLamoRotate
        NSString *rotationLandscapeNotification = [NSString stringWithFormat:@"%@LamoLandscapeRotate", dispident];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), (CFNotificationCallback)receivedLandscapeRotate, (CFStringRef)rotationLandscapeNotification, NULL, CFNotificationSuspensionBehaviorDrop);
        
        //portrait
        NSString *rotationPortraitNotification = [NSString stringWithFormat:@"%@LamoPortraitRotate", dispident];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), (CFNotificationCallback)receivedPortraitRotate, (CFStringRef)rotationPortraitNotification, NULL, CFNotificationSuspensionBehaviorDrop);
        
        //create statusbar notification
        NSString *changeStatusBarNotification = [NSString stringWithFormat:@"%@LamoStatusBarChange", dispident];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), (__bridge const void *)(self), (CFNotificationCallback)receivedStatusBarChange, (CFStringRef)changeStatusBarNotification, NULL, CFNotificationSuspensionBehaviorDrop);
                
    }
    
    return ZKOrig(id);
}

void receivedStatusBarChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    //set hidden based on isHidden key
    [[UIApplication sharedApplication] setStatusBarHidden:[[(__bridge NSDictionary *)userInfo valueForKey:@"isHidden"] boolValue] animated:YES];
}

void receivedLandscapeRotate() {
    
    //rotate all windows
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        
        [window _setRotatableViewOrientation:UIInterfaceOrientationLandscapeRight updateStatusBar:YES duration:0.45 force:YES];
        
    }
}

void receivedPortraitRotate() {
    
    //rotate all windows
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        
        [window _setRotatableViewOrientation:UIInterfaceOrientationPortrait updateStatusBar:YES duration:0.45 force:YES];
        
    }
}


@end