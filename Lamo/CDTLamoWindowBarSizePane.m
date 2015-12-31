//
//  CDTLamoWindowBarSizePane.m
//  Lamo
//
//  Created by Ethan Arbuckle on 7/3/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoWindowBarSizePane.h"

@interface CDTLamoWindowBarSizePane ()

@end

@implementation CDTLamoWindowBarSizePane


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
    
    [_previewWindow setHidden:YES];
    _previewWindow = NULL;
    
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
    
    return @"size of the window bar";
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
        [slider setMinimumValue:10];
        [slider setMaximumValue:60];
        [slider setValue:[[CDTLamoSettings sharedSettings] windowBarHeight] animated:NO];
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
        _barView = [[CDTLamoBarView alloc] init];
        [_barView setFrame:CGRectMake(0, -[[CDTLamoSettings sharedSettings] windowBarHeight], kScreenWidth, [[CDTLamoSettings sharedSettings] windowBarHeight])];
        [(CDTLamoWindow *)_previewWindow setBarView:_barView];
        [_previewWindow addSubview:_barView];
        [_previewWindow setTransform:CGAffineTransformMakeScale([[CDTLamoSettings sharedSettings] minimizedWindowSize], [[CDTLamoSettings sharedSettings] minimizedWindowSize])];
      
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
         
    }
    
    return cell;
}

- (void)handleSliderChanged:(UISlider *)slider {
    
    //handle resizing our view
    CGRect barFrame = [_barView frame];
    barFrame.size.height = [slider value];
    barFrame.origin.y = -[slider value];
    [_barView setFrame:barFrame];
    
    //update setting
    [[CDTLamoSettings sharedSettings] setWindowBarHeight:[slider value]];
}

@end
