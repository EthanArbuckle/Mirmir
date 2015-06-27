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

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    
    return 5;
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
    
    return 0;
}

- (NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
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
                [settingCell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Drag From Top Center"];
            }
            else if ([indexPath row] == 2) {
                
                [[settingCell textLabel] setText:@"Drag From Top Right"];
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
                [cellSwitch setOn:YES];
                [settingCell setAccessoryView:cellSwitch];
            }
            else if ([indexPath row] == 1) {
                
                [[settingCell textLabel] setText:@"Pinch to Resize"];
                
                //create switch
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:YES];
                [settingCell setAccessoryView:cellSwitch];
            }
            else if ([indexPath row] == 2) {
                
                [[settingCell textLabel] setText:@"Show Title Text"];
                
                //create switch
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:YES];
                [settingCell setAccessoryView:cellSwitch];
            }
        }
        
    }
    
    return settingCell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
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
    
    
    [_lamoSettingsTable reloadData];
}

- (void)handleEnableSwitch:(UISwitch *)cellSwitch {
    
    [[CDTLamoSettings sharedSettings] setEnabled:[cellSwitch isOn]];
}

@end
