//
//  CDTLamoWindowBarSizePane.h
//  Lamo
//
//  Created by Ethan Arbuckle on 7/3/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTLamoWindow.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoSettings.h"

@interface CDTLamoWindowBarSizePane : UITableViewController

@property (nonatomic, retain) UIView *previewWindow;
@property (nonatomic, retain) UIView *barView;

- (void)handleSliderChanged:(UISlider *)slider;

@end
