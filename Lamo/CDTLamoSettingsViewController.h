//
//  CDTLamoSettingsViewController.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "Lamo.h"
#import "CDTLamoSettings.h"
#import "CDTLamoDefaultWindowPane.h"
#import "CDTLamoMinimizedWindowPane.h"
#import "CDTLamoSensitivityPane.h"
#import "CDTLamoMainTutorialController.h"
#import "CDTLamoActivatorBinding.h"
#import "CDTLamoCreditsPane.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

@interface CDTLamoSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *lamoSettingsTable;

- (void)handleEnableSwitch:(UISwitch *)cellSwitch;
- (void)handleStatusBarHideSwitch:(UISwitch *)cellSwitch;
- (void)handlePinchSwitch:(UISwitch *)cellSwitch;
- (void)handleTitleTextSwitch:(UISwitch *)cellSwitch;
- (void)handleTweet;

@end
