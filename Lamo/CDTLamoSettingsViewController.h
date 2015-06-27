//
//  CDTLamoSettingsViewController.h
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lamo.h"
#import "CDTLamoSettings.h"
#import "CDTLamoDefaultWindowPane.h"
#import "CDTLamoMinimizedWindowPane.h"
#import "CDTLamoSensitivityPane.h"

@interface CDTLamoSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *lamoSettingsTable;

- (void)handleEnableSwitch:(UISwitch *)cellSwitch;

@end
