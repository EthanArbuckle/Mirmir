//
//  CDTLamoSettings.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoSettings.h"

@implementation CDTLamoSettings

+ (id)sharedSettings {
    
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    
    if (self = [super init]) {
        
        //create default settings
        NSDictionary *defaultSettings = @{
                                          isEnabledKey : @YES,
                                          defaultOrientationKey : @"portrait",
                                          defaultWindowSizeKey : @.6,
                                          minimizedWindowSizeKey : @.4,
                                          activationZoneKey : @"left",
                                          activationTriggerRadiusKey : @80,
                                          hideStatusBarKey : @YES,
                                          pinchToResizeKey : @YES,
                                          showTitleTextKey : @YES
                                          };
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultSettings];
        
    }
    
    return self;
}

- (void)saveChanges {

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setEnabled:(BOOL)enabled {
    
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:isEnabledKey];
    [self saveChanges];
}

- (BOOL)isEnabled {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:isEnabledKey];
}

- (void)setDefaultOrientation:(NSString *)defaultOrientation {

    [[NSUserDefaults standardUserDefaults] setValue:defaultOrientation forKey:defaultOrientationKey];
    [self saveChanges];
}

- (NSString *)defaultOrientation {
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:defaultOrientationKey];
}

- (void)setDefaultWindowSize:(CGFloat)scale {
    
    [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:defaultWindowSizeKey];
    [self saveChanges];
}

- (CGFloat)defaultWindowSize {
    
    return [[NSUserDefaults standardUserDefaults] floatForKey:defaultWindowSizeKey];
}

- (void)setMinimizedWindowSize:(CGFloat)scale; {
    
    [[NSUserDefaults standardUserDefaults] setFloat:scale forKey:minimizedWindowSizeKey];
    [self saveChanges];
}

- (CGFloat)minimizedWindowSize {
    
    return [[NSUserDefaults standardUserDefaults] floatForKey:minimizedWindowSizeKey];
}

- (void)setActivationZone:(NSString *)zone {
    
    [[NSUserDefaults standardUserDefaults] setValue:zone forKey:activationZoneKey];
    [self saveChanges];
}

- (NSString *)activationZone {
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:activationZoneKey];
}

- (void)setActivationTriggerRadius:(CGFloat)radius {
    
    [[NSUserDefaults standardUserDefaults] setFloat:radius forKey:activationTriggerRadiusKey];
    [self saveChanges];
}

- (CGFloat)activationTriggerRadius {
    
    return [[NSUserDefaults standardUserDefaults] floatForKey:activationTriggerRadiusKey];
}

- (void)setHideStatusBar:(BOOL)hide {
    
    [[NSUserDefaults standardUserDefaults] setBool:hide  forKey:hideStatusBarKey];
    [self saveChanges];
}

- (BOOL)hideStatusBar {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:hideStatusBarKey];
}

- (void)setPinchToResize:(BOOL)enabled {
    
    [[NSUserDefaults standardUserDefaults] setBool:enabled  forKey:pinchToResizeKey];
    [self saveChanges];
}

- (BOOL)pinchToResize {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:pinchToResizeKey];
}

- (void)setShowTitleText:(BOOL)show {
    
    [[NSUserDefaults standardUserDefaults] setBool:show  forKey:showTitleTextKey];
    [self saveChanges];
}

- (BOOL)showTitleText {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:showTitleTextKey];
}

@end
