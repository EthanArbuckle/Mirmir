//
//  CDTLamoActivatorBinding.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "activator_headers/libactivator.h"
#import "CDTLamoActivatorEventCloseAll.h"
#import "CDTLamoActivatorEventCloseCurrent.h"

@interface CDTLamoActivatorBinding : NSObject

+ (id)sharedBinding;
- (BOOL)activatorSupported;
- (void)setupActivatorActions;

@end
