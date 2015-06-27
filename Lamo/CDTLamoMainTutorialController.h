//
//  CDTLamoMainTutorialController.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/27/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTLamoWindow.h"

@interface CDTLamoMainTutorialController : UIViewController

@property (nonatomic, retain) CDTLamoWindow *windowPreview;

- (void)addBarButtons;
- (void)closeTutorial;
- (void)handlePan:(UIPanGestureRecognizer *)gesture;

@end
