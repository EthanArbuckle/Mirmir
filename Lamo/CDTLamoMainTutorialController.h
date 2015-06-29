//
//  CDTLamoMainTutorialController.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/27/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoWindow.h"
#import "CDTLamoOverlayTutorialController.h"

@interface CDTLamoMainTutorialController : UIViewController

@property (nonatomic, retain) UIView *windowPreview;
@property (nonatomic, retain) CDTContextHostProvider *contextProvider;
@property (nonatomic, retain) UIImageView *animatingView;

- (void)addBarButtons;
- (void)closeTutorial;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
- (void)animateHelperViewDown;
- (void)animateHelperViewUp;

@end
