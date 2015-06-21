//
//  CDTLamoAppOverlay.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/21/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoAppOverlay.h"

@implementation CDTLamoAppOverlay

- (id)initWithOrientation:(UIInterfaceOrientation *)orientation {
    
    if (self = [super init]) {
        
        //create blurred backdrop
        _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:2060];
        [blurView setBlurRadius:10];
        [blurView setFrame:[self frame]];
        [self insertSubview:blurView atIndex:0];
        
    }
    
    return self;
}

@end
