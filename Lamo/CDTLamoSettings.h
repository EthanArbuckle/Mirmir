//
//  CDTLamoSettings.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define isEnabledKey @"CDTLamoIsEnabled"

@interface CDTLamoSettings : NSObject

+ (id)sharedSettings;
- (void)saveChanges;

- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;

@end