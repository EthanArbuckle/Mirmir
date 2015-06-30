//
//  CDTLamoCreditsPaneTableViewController.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoCreditsPane.h"

@interface CDTLamoCreditsPane ()

@end

@implementation CDTLamoCreditsPane

- (id)init {
    
    if (self = [super init]) {
        
        //set table to grouped
        (void)[[self tableView] initWithFrame:[[self tableView] frame] style:UITableViewStyleGrouped];
        
    }
    
    return self;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //100 for dev cell, 44 for rest
    if ([indexPath row] == 0) {
        return 100;
    }
    
    return 44;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    
    return 3;
}

- (NSString *)tableView:(nonnull UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        
        return @"We were all pretty baked while making this tweak.";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    //setup info for cell
    
    //cortex cell
    if ([indexPath section] == 2) {
        
        //dev cell
        if ([indexPath row] == 0) {
            
            //create cell
            CDTLamoCreditsDevCell *devCell = [[CDTLamoCreditsDevCell alloc] init];
            [[devCell developerImage] setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/Cortex.png"]];
            [[devCell developerName] setText:@"Cortex Dev Team"];
            return devCell;
        }
        
        //twitter cell
        else if ([indexPath row] == 1) {
            
            //stock table cell
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            [[cell textLabel] setText:@"Twitter"];
            
            //create label with twitter info
            UILabel *twitter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
            [twitter setText:@"@CortexDevTeam"];
            [twitter setTextAlignment:NSTextAlignmentRight];
            [twitter setTextColor:[UIColor grayColor]];
            [twitter setBackgroundColor:[UIColor clearColor]];
            [cell setAccessoryView:twitter];
            return cell;
        }

    }
    
    //ethan cell
    if ([indexPath section] == 0) {
        
        //dev cell
        if ([indexPath row] == 0) {
            
            //create cell
            CDTLamoCreditsDevCell *devCell = [[CDTLamoCreditsDevCell alloc] init];
            [[devCell developerImage] setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/Ethan.png"]];
            [[devCell developerName] setText:@"Ethan Arbuckle"];
            [[devCell developerDescription] setText:@"Lead Developer"];
            return devCell;
        }
        
        //twitter cell
        else if ([indexPath row] == 1) {
            
            //stock table cell
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            [[cell textLabel] setText:@"Twitter"];
            
            //create label with twitter info
            UILabel *twitter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
            [twitter setText:@"@its_not_herpes"];
            [twitter setTextAlignment:NSTextAlignmentRight];
            [twitter setTextColor:[UIColor grayColor]];
            [twitter setBackgroundColor:[UIColor clearColor]];
            [cell setAccessoryView:twitter];
            return cell;
        }
        
    }
    
    //liam cell
    if ([indexPath section] == 1) {
        
        //dev cell
        if ([indexPath row] == 0) {
            
            //create cell
            CDTLamoCreditsDevCell *devCell = [[CDTLamoCreditsDevCell alloc] init];
            [[devCell developerImage] setImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/Lamo/Liam.png"]];
            [[devCell developerName] setText:@"Liam Thynne"];
            [[devCell developerDescription] setText:@"Lead Designer"];
            return devCell;
        }
        
        //twitter cell
        else if ([indexPath row] == 1) {
            
            //stock table cell
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            [[cell textLabel] setText:@"Twitter"];
            
            //create label with twitter info
            UILabel *twitter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
            [twitter setText:@"@iamHoenir"];
            [twitter setTextAlignment:NSTextAlignmentRight];
            [twitter setTextColor:[UIColor grayColor]];
            [twitter setBackgroundColor:[UIColor clearColor]];
            [cell setAccessoryView:twitter];
            return cell;
        }
        
    }


    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //cells tapped, open twitters
    if ([indexPath row] == 1) {
        
        //ethan twitter
        if ([indexPath section] == 0) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/its_not_herpes"]];
        }
        
        //liam twitter
        else if ([indexPath section] == 1) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/iamHoenir"]];
        }
        
        //cortex twitter
        else if ([indexPath section] == 2) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/CortexDevTeam"]];
        }
        
        //fade settings out
        [UIView animateWithDuration:0.3 animations:^{
            
            [[[[CDTLamo sharedInstance] tutorialNavigationController] view] setAlpha:1];
            [[[[[CDTLamo sharedInstance] settingsNavigationController] view] superview] setAlpha:0];
            
        } completion:^(BOOL finished) {
            
            [[[[[CDTLamo sharedInstance] settingsNavigationController] view] superview] removeFromSuperview];
            [[CDTLamo sharedInstance] removeKeyFromDict:@"com.cortexdevteam.lamosetting"];
            
        }];
    }
}
@end
