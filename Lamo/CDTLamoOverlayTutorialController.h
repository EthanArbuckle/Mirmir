//
//  CDTLamoOverlayTutorialController.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/27/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoWindow.h"

@interface CDTLamoOverlayTutorialController : UIViewController

@property (nonatomic, retain) UILabel *instructionLabel;
@property (nonatomic, retain) UIView *appWindow;
@property int currentStep;

- (void)setLamoWindow:(UIView *)lamoWindow;
- (void)gotWindowTap;
- (void)addBarButtons;
- (void)closeTutorial;
- (void)progressStep;

@end
