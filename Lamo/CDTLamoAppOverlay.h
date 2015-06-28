//
//  CDTLamoAppOverlay.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/21/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTLamoBarView.h"
#import "CDTLamoSettings.h"

@interface CDTLamoAppOverlay : UIView

@property CGFloat lastScale;

- (id)initWithOrientation:(UIInterfaceOrientation *)orientation;

- (void)handleClose;
- (void)handleMin;
- (void)handleMax;
- (void)handleOrientation;
- (void)transitionToPortrait;
- (void)transitionToLandscape;
- (void)handleTap;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)prepForTutorialStage:(int)stage;

@end
