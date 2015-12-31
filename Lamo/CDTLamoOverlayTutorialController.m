//
//  CDTLamoOverlayTutorialController.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/27/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoOverlayTutorialController.h"

@interface CDTLamoOverlayTutorialController ()

@end

@implementation CDTLamoOverlayTutorialController


- (id)init {
    
    if (self = [super init]) {
        
        [[self view] setBackgroundColor:[UIColor clearColor]];
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        //create blur
        _UIBackdropView *blur = [(_UIBackdropView *)[NSClassFromString(@"_UIBackdropView") alloc] initWithStyle:1];
        [[self view] addSubview:blur];
        
        
        //create instruction label
        _instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 100)];
        [_instructionLabel setTextColor:[UIColor whiteColor]];
        [_instructionLabel setTextAlignment:NSTextAlignmentCenter];
        [_instructionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
        [_instructionLabel setNumberOfLines:0];
        [_instructionLabel setText:@"Tap the gray window bar to show window options"];
        [[self view] addSubview:_instructionLabel];
        
    }
    
    return self;
}

- (void)setLamoWindow:(UIView *)lamoWindow {
    
    //adjust to this view
    [lamoWindow setTransform:CGAffineTransformMakeScale(.7, .7)];
    
    CGRect windowFrame = [lamoWindow frame];
    windowFrame.origin.y = 110;
    [lamoWindow setFrame:windowFrame];
    
    _appWindow = lamoWindow;
    [[self view] addSubview:_appWindow];
    
    //replace bar gesture recognizer
    for (UIGestureRecognizer *gesture in [[(CDTLamoWindow *)_appWindow barView] gestureRecognizers]) {
        [[(CDTLamoWindow *)_appWindow barView] removeGestureRecognizer:gesture];
    }
    
    UITapGestureRecognizer *barTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotWindowTap)];
    [[(CDTLamoWindow *)_appWindow barView] addGestureRecognizer:barTap];
    [_appWindow setUserInteractionEnabled:YES];
}

- (void)gotWindowTap {
    
    _currentStep = 1;
    
    //overlay shown. move to next step
    [_instructionLabel setText:@"Tap the \"+\" button to maximize the window"];
    [(CDTLamoBarView *)[(CDTLamoWindow *)_appWindow barView] handleTap:nil];
    [(CDTLamoAppOverlay *)[(CDTLamoBarView *)[(CDTLamoWindow *)_appWindow barView] overlayView] prepForTutorialStage:_currentStep];
     
}

- (void)addBarButtons {
    
    //these need to be made outside of init so we have a navcontroller set
    //create close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeTutorial)];
    [[self navigationItem] setRightBarButtonItem:closeButton];
    [[self navigationItem] setHidesBackButton:YES];
}

- (void)closeTutorial {
    
    //animate it out
    [UIView animateWithDuration:0.3 animations:^{
        
        [[[CDTLamo sharedInstance] tutorialWindow] setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        //remove it
        [[[self navigationController] view] removeFromSuperview];
        [[[CDTLamo sharedInstance] tutorialWindow] setHidden:YES];
        [[CDTLamo sharedInstance] setTutorialWindow:NULL];
        [_appWindow setHidden:YES];
        _appWindow = NULL;
        
    }];
    
    //stop hosting
    if (NEED_IPAD_HAX) {
        [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.Maps"];
    }
    else {
        [[CDTContextHostProvider new] stopHostingForBundleID:@"com.apple.weather"];
    }
    
}

- (void)progressStep {
    
    //step up
    _currentStep++;
    
    //update label
    if (_currentStep == 2) {
        
        [_instructionLabel setText:@"Tap the \"-\" button to mimimize the window"];
    }
    else if (_currentStep == 3) {
        
        [_instructionLabel setText:@"Tap the \"X\" button to close the window"];
    }
    else if (_currentStep == 4) {
        
        [_instructionLabel setText:@"Tap the orientation window to switch app orientation"];
    }
    else if (_currentStep == 5) {
        
        //we're finished
        [_instructionLabel setText:@"Welcome to Mímir!"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            [self closeTutorial];
            
        });
    }
    
    //update overlay view
    [UIView animateWithDuration:0.4 animations:^{
        
        [(CDTLamoAppOverlay *)[(CDTLamoBarView *)[(CDTLamoWindow *)_appWindow barView] overlayView] prepForTutorialStage:_currentStep];
    }];
    
}

@end
