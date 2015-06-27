//
//  CDTLamoMainTutorialController.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/27/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoMainTutorialController.h"

@interface CDTLamoMainTutorialController ()

@end

@implementation CDTLamoMainTutorialController

- (id)init {
    
    if (self = [super init]) {
        
        [[self view] setBackgroundColor:[UIColor whiteColor]];
        
    }
    
    return self;
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
        
        [[[self navigationController] view] setAlpha:0];
        
    } completion:^(BOOL finished) {
        
        //remove it
        [[[self navigationController] view] removeFromSuperview];
        
    }];
}

@end
