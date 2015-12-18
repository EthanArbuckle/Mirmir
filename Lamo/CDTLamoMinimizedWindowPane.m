//
//  CDTLamoMinimizedWindowPane.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/26/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoMinimizedWindowPane.h"

@interface CDTLamoMinimizedWindowPane ()

@end

@implementation CDTLamoMinimizedWindowPane

- (id)init {
    
    if (self = [super init]) {
        
        //setup tableview
        (void)[[self tableView] initWithFrame:[[self tableView] frame] style:UITableViewStyleGrouped];
        [[self tableView] setScrollEnabled:NO];
    }
    
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //stop hosting
    if (NEED_IPAD_HAX) {
        [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.Maps"];
    }
    else {
        [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.weather"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"size the '-' button sets";
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //set custom height for 2nd cell
    if ([indexPath row] == 0) {
        
        return 44;
    }
    
    else if ([indexPath row] == 1) {
        
        return (kScreenHeight * .7) + 40;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if ([indexPath row] == 0) {
        
        //create slider
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 12, kScreenWidth - 20, 20)];
        [slider setMinimumValue:0.3];
        [slider setMaximumValue:1];
        [slider setValue:[[CDTLamoSettings sharedSettings] minimizedWindowSize] animated:NO];
        [slider addTarget:self action:@selector(handleSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:slider];
    }
    
    else if ([indexPath row] == 1) {
        
        //create homescreen layout
        SBHomeScreenPreviewView *preview = [NSClassFromString(@"SBHomeScreenPreviewView") preview];
        [preview setTransform:CGAffineTransformMakeScale(.7, .7)];
        [preview setFrame:CGRectMake((kScreenWidth / 2) - ((kScreenWidth * .7) / 2), 10, kScreenWidth, kScreenHeight)];
        [preview setClipsToBounds:YES];
        [preview setUserInteractionEnabled:NO];
        
        //fuck this. gotta make a view to hide shit from the preview
        UIView *hidingView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth / 2) + ((kScreenWidth * .7) / 2), 0, 200, (kScreenHeight * .7) + 40)];
        [hidingView setBackgroundColor:[UIColor whiteColor]];
        
        [cell addSubview:preview];
        [cell addSubview:hidingView];
        
        
        //create fake lamo window
        _previewWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_previewWindow setBackgroundColor:[UIColor grayColor]];
        CDTLamoBarView *barView = [[CDTLamoBarView alloc] init];
        [barView setFrame:CGRectMake(0, -20, kScreenWidth, 20)];
        [(CDTLamoWindow *)_previewWindow setBarView:barView];
        [_previewWindow addSubview:barView];
        [barView setTitle:@"Mímir"];
        [_previewWindow setTransform:CGAffineTransformMakeScale([[CDTLamoSettings sharedSettings] minimizedWindowSize], [[CDTLamoSettings sharedSettings] minimizedWindowSize])];
        
        /*
        //create app
        UIView *contextView;
        if (NEED_IPAD_HAX) {
            contextView = [[CDTContextHostProvider new]  hostViewForApplicationWithBundleID:@"com.apple.Maps"];
            [[CDTContextHostProvider new] setStatusBarHidden:@(1) onApplicationWithBundleID:@"com.apple.Maps"];
        }
        else {
            contextView = [[CDTContextHostProvider new]  hostViewForApplicationWithBundleID:@"com.apple.weather"];
            [[CDTContextHostProvider new]  setStatusBarHidden:@(1) onApplicationWithBundleID:@"com.apple.weather"];
        }
        [_previewWindow addSubview:contextView];
        
        [preview addSubview:_previewWindow];
         
         */
    }
    
    return cell;
}

- (void)handleSliderChanged:(UISlider *)slider {
    
    //handle resizing our view
    [_previewWindow setTransform:CGAffineTransformMakeScale([slider value], [slider value])];
    
    //update setting
    [[CDTLamoSettings sharedSettings] setMinimizedWindowSize:[slider value]];
}

@end
