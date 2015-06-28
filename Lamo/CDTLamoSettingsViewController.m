//
//  CDTLamoSettingsViewController.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/5/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoSettingsViewController.h"

@implementation CDTLamoSettingsViewController

- (id)init {
    
    if (self = [super init]) {
        
        //create tableview, with frame of fullscreen
        _lamoSettingsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
        [_lamoSettingsTable setDelegate:self];
        [_lamoSettingsTable setDataSource:self];
        [[self view] addSubview:_lamoSettingsTable];
    
    }
    
    return self;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 5) {
        
        return @"Cortex Dev Team";
    }
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
    }
    else if (section == 1) {
        
        return 2;
    }
    else if (section == 2) {
        
        return 2;
    }
    else if (section == 3) {
        
        return 4;
    }
    else if (section == 4) {
        
        return 3;
    }
    else if (section == 5) {
        
        return 1;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return @"";
    }
    else if (section == 1) {
        
        return @"default orientation";
    }
    else if (section == 2) {
        
        return @"sizing";
    }
    else if (section == 3) {
        
        return @"activation";
    }
    else if (section == 4) {
        
        return @"windows";
    }
    else if (section == 5) {
        
        return @"";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //create settings cell
    UITableViewCell *settingCell = [[UITableViewCell alloc] init]; //[tableView dequeueReusableCellWithIdentifier:@"CDTLamoSettingCell"];
    if (settingCell) {

        //cell aint cell, make cell cell
        settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CDTLamoSettingCell"];
        
        if ([indexPath section] == 0) {
            
            //create enable switch + label
            UISwitch *cellSwitch = [[UISwitch alloc] init];
            [cellSwitch setOn:[[CDTLamoSettings sharedSettings] isEnabled]];
            [cellSwitch addTarget:self action:@selector(handleEnableSwitch:) forControlEvents:UIControlEventValueChanged];
            [cellSwitch setTag:[indexPath row]];
            [settingCell setAccessoryView:cellSwitch];
            [[settingCell textLabel] setText:@"Enabled"];
            
        }
        
        else if ([indexPath section] == 1) {
            
            //orientaition cells
            if ([indexPath row] == 0) {
                
                [[settingCell textLabel] setText:@"Portrait"];
                if ([[[CDTLamoSettings sharedSettings] defaultOrientation] isEqualToString:@"portrait"]) {
                    
                    [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Landscape"];
                if ([[[CDTLamoSettings sharedSettings] defaultOrientation] isEqualToString:@"landscape"]) {
                    
                    [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
        }
        
        else if ([indexPath section] == 2) {
            
            //window size cells
            if ([indexPath row] == 0) {
                
                [[settingCell textLabel] setText:@"Default Window Size"];
                [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Minimized Size"];
                [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }
        
        //activation cells
        else if ([indexPath section] == 3) {
            
            if ([indexPath row] == 0) {
                
                [[settingCell textLabel] setText:@"Drag From Top Left"];
                if ([[[CDTLamoSettings sharedSettings] activationZone] isEqualToString:@"left"]) {
                    
                    [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Drag From Top Center"];
                if ([[[CDTLamoSettings sharedSettings] activationZone] isEqualToString:@"center"]) {
                    
                    [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            else if ([indexPath row] == 2) {
                
                [[settingCell textLabel] setText:@"Drag From Top Right"];
                if ([[[CDTLamoSettings sharedSettings] activationZone] isEqualToString:@"right"]) {
                    
                    [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
                }
            }
            else if ([indexPath row] == 3) {
                
                [[settingCell textLabel] setText:@"Sensitivity"];
                [settingCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
        }
        
        else if ([indexPath section] == 4) {
            
            //window settings
            if ([indexPath row] == 0) {
                
                [[settingCell textLabel] setText:@"Hide Status Bar"];
                
                //create switch
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:[[CDTLamoSettings sharedSettings] hideStatusBar]];
                [cellSwitch addTarget:self action:@selector(handleStatusBarHideSwitch:) forControlEvents:UIControlEventValueChanged];
                [settingCell setAccessoryView:cellSwitch];
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Pinch to Resize"];
                
                //create switch
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:[[CDTLamoSettings sharedSettings] pinchToResize]];
                [cellSwitch addTarget:self action:@selector(handlePinchSwitch:) forControlEvents:UIControlEventValueChanged];
                [settingCell setAccessoryView:cellSwitch];
            }
            else if ([indexPath row] == 2) {
                
                [[settingCell textLabel] setText:@"Show Title Text"];
                
                //create switch
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:[[CDTLamoSettings sharedSettings] showTitleText]];
                [cellSwitch addTarget:self action:@selector(handleTitleTextSwitch:) forControlEvents:UIControlEventValueChanged];
                [settingCell setAccessoryView:cellSwitch];
            }
        }
        
        //tutorial cell
        else if ([indexPath section] == 5) {
            
            if ([indexPath row] == 0) {
                
                [[settingCell textLabel] setTextAlignment:NSTextAlignmentCenter];
                [[settingCell textLabel] setText:@"Launch Tutorial"];
                [[settingCell textLabel] setTextColor:[UIColor colorWithRed:0.204 green:0.459 blue:1.000 alpha:1.0]];
                
            }
        }
        
    }
    
    return settingCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //ensure we arent hosting the weather preview
    [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.weather"];
    
    //tapped an orientation cell
    if ([indexPath section] == 1) {
        
        if ([indexPath row] == 0) {
            
            [[CDTLamoSettings sharedSettings] setDefaultOrientation:@"portrait"];
        }
        else if ([indexPath row] == 1) {
            
            [[CDTLamoSettings sharedSettings] setDefaultOrientation:@"landscape"];
        }
    }
    
    //tapped sizing cell
    else if ([indexPath section] == 2) {
        
        if ([indexPath row] == 0) {

            CDTLamoDefaultWindowPane *windowSize = [[CDTLamoDefaultWindowPane alloc] init];
            [windowSize setTitle:@"Default Window Size"];
            [[self navigationController] pushViewController:windowSize animated:YES];
        }
        else if ([indexPath row] == 1) {
            
            CDTLamoMinimizedWindowPane *minimizePane = [[CDTLamoMinimizedWindowPane alloc] init];
            [minimizePane setTitle:@"Minimized Window Size"];
            [[self navigationController] pushViewController:minimizePane animated:YES];
        }
    }
    
    //activation zone cells
    else if ([indexPath section] == 3) {
        
        if ([indexPath row] == 0) {
            
            [[CDTLamoSettings sharedSettings] setActivationZone:@"left"];
        }
        else if ([indexPath row] == 1) {
            
            [[CDTLamoSettings sharedSettings] setActivationZone:@"center"];
        }
        else if ([indexPath row] == 2) {
            
            [[CDTLamoSettings sharedSettings] setActivationZone:@"right"];
        }
        else if ([indexPath row] == 3) {
            
            CDTLamoSensitivityPane *sensitivityPane = [[CDTLamoSensitivityPane alloc] init];
            [sensitivityPane setTitle:@"Activation Sensitivity"];
            [[self navigationController] pushViewController:sensitivityPane animated:YES];
        }
    }
    
    //tutorial cell
    else if ([indexPath section] == 5) {
        
        if ([indexPath row] == 0) {
            
            //present
            [[CDTLamo sharedInstance] setTutorialController:[[CDTLamoMainTutorialController alloc] init]];
            [[[CDTLamo sharedInstance] tutorialController] setTitle:@"Lamo Tutorial"];
            [[CDTLamo sharedInstance] setTutorialNavigationController:[[UINavigationController alloc] initWithRootViewController:[[CDTLamo sharedInstance] tutorialController]]];
            [[[[CDTLamo sharedInstance] tutorialNavigationController] view] setAlpha:0];
            [[[CDTLamo sharedInstance] springboardWindow] addSubview:[[[CDTLamo sharedInstance] tutorialNavigationController] view]];
            [(CDTLamoMainTutorialController *)[[CDTLamo sharedInstance] tutorialController] addBarButtons];
            
            //fade it in and fade settings controller out
            [UIView animateWithDuration:0.3 animations:^{
                
                [[[[CDTLamo sharedInstance] tutorialNavigationController] view] setAlpha:1];
                [[[[[CDTLamo sharedInstance] settingsNavigationController] view] superview] setAlpha:0];
                
            } completion:^(BOOL finished) {
                
                [[[[[CDTLamo sharedInstance] settingsNavigationController] view] superview] removeFromSuperview];
                
                //ensure we arent hosting the weather preview
                [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.weather"];
                
            }];

            
        }
    }
    
    
    [_lamoSettingsTable reloadData];
}

- (void)handleEnableSwitch:(UISwitch *)cellSwitch {
    
    [[CDTLamoSettings sharedSettings] setEnabled:[cellSwitch isOn]];
}

- (void)handleStatusBarHideSwitch:(UISwitch *)cellSwitch {
    
    [[CDTLamoSettings sharedSettings] setHideStatusBar:[cellSwitch isOn]];
}

- (void)handlePinchSwitch:(UISwitch *)cellSwitch {
    
    [[CDTLamoSettings sharedSettings] setPinchToResize:[cellSwitch isOn]];
}

- (void)handleTitleTextSwitch:(UISwitch *)cellSwitch {
    
    [[CDTLamoSettings sharedSettings] setShowTitleText:[cellSwitch isOn]];
}

@end
