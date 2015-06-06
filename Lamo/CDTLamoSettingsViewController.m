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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //create settings cell
    UITableViewCell *settingCell = [tableView dequeueReusableCellWithIdentifier:@"CDTLamoSettingCell"];
    if (!settingCell) {
        
        //cell aint cell, make cell cell
        settingCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CDTLamoSettingCell"];
        
        switch ([indexPath row]) {
            case 0: {
                
                //create enable switch + label
                UISwitch *cellSwitch = [[UISwitch alloc] init];
                [cellSwitch setOn:[[CDTLamoSettings sharedSettings] isEnabled]];
                [settingCell setAccessoryView:cellSwitch];
                
                [[settingCell textLabel] setText:@"Enabled"];
                
                break;
            }
                
            default:
                break;
        }
    }
    
    return settingCell;
}


@end
