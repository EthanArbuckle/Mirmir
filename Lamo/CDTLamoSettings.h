//
//  CDTLamoSettings.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define isEnabledKey @"CDTLamoIsEnabled"
#define defaultOrientationKey @"CDTLamoDefaultOrientation"
#define defaultWindowSizeKey @"CDTLamoDefaultWindowSize"
#define minimizedWindowSizeKey @"CDTLamoMinimizedWindowSize"
#define activationZoneKey @"CDTLamoActivationZone"
#define activationTriggerRadiusKey @"CDTLamoActivationTriggerRadius"

@interface CDTLamoSettings : NSObject

+ (id)sharedSettings;
- (void)saveChanges;

- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;

- (void)setDefaultOrientation:(NSString *)defaultOrientation;
- (NSString *)defaultOrientation;

- (void)setDefaultWindowSize:(CGFloat)scale;
- (CGFloat)defaultWindowSize;

- (void)setMinimizedWindowSize:(CGFloat)scale;
- (CGFloat)minimizedWindowSize;

- (void)setActivationZone:(NSString *)zone;
- (NSString *)activationZone;

- (void)setActivationTriggerRadius:(CGFloat)radius;
- (CGFloat)activationTriggerRadius;

@end
