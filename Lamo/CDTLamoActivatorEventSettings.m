//
//  CDTLamoActivatorEventSettings.m
//  Lamo
//
//  Created by Ethan Arbuckle on 7/18/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventSettings.h"

@implementation CDTLamoActivatorEventSettings

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Settings";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Open Mímir's settings panel";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //remove just in case
    if ([[[[CDTLamo sharedInstance] settingsNavigationController] view] superview]) {
        [[[[[CDTLamo sharedInstance] settingsNavigationController] view] superview] removeFromSuperview];
        [[CDTLamo sharedInstance] removeKeyFromDict:@"com.cortexdevteam.lamosetting"];
    }
    
    [[CDTLamo sharedInstance] presentSettingsController];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale {
    return [UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/icon-small.png"];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
