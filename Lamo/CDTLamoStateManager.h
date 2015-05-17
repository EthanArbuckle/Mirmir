//
//  CDTLamoStateManager.h
//  Lamo
//
//  Created by Ethan Arbuckle on 5/17/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Lamo.h"
#import "CDTLamoWindow.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoWindow.h"
#import "CDTLamoBarView.h"

@interface CDTLamoStateManager : NSObject

+ (void)saveWindowStatesFromDictionary:(NSDictionary *)dictionary andRemove:(BOOL)remove;
+ (void)restoreWindowsOntoView:(UIView *)view;

@end
