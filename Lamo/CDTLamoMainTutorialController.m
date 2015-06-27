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
        
        [[self view] setBackgroundColor:[UIColor clearColor]];
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        
        //create blur
        _UIBackdropView *blur = [(_UIBackdropView *)[NSClassFromString(@"_UIBackdropView") alloc] initWithStyle:1];
        [[self view] addSubview:blur];
        
        
        //create instruction label
        UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, kScreenWidth - 20, 100)];
        [instructionLabel setTextColor:[UIColor whiteColor]];
        [instructionLabel setTextAlignment:NSTextAlignmentCenter];
        [instructionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
        [instructionLabel setNumberOfLines:0];
        [instructionLabel setText:@"Drag down and release from the top left corner to invoke a window"];
        [[self view] addSubview:instructionLabel];
        
        //create homescreen preview
        SBHomeScreenPreviewView *homePreview = [NSClassFromString(@"SBHomeScreenPreviewView") preview];
        [homePreview setTransform:CGAffineTransformMakeScale(.8, .8)];
        [homePreview setFrame:CGRectMake((kScreenWidth / 2) - ((kScreenWidth * .8) / 2), 200, kScreenWidth, kScreenHeight)];
        [[homePreview subviews][1] removeFromSuperview];
        [homePreview setClipsToBounds:YES];
        [[self view] addSubview:homePreview];
        
        //create preview window
        _windowPreview = [[CDTLamoWindow alloc] init];
        [_windowPreview setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        [_windowPreview setBackgroundColor:[UIColor darkGrayColor]];
        [_windowPreview setUserInteractionEnabled:YES];
        
        //add it behind status bar of homescreenview
        [homePreview insertSubview:_windowPreview atIndex:1];
        
        //create bar view
        CDTLamoBarView *bar = [[CDTLamoBarView alloc] init];
        [bar setFrame:CGRectMake(0, -20, kScreenWidth, 20)];
        [bar setTitle:@"Lamo!"];
        [(CDTLamoWindow *)_windowPreview setBarView:bar];
        [_windowPreview addSubview:bar];
        
        //create pan gesture
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [[homePreview subviews][2] addGestureRecognizer:panGesture];
        
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

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    
    if ([gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture locationInView:[[gesture view] superview]];
        if (translation.x <= 100 && translation.y <= 100 && translation.y >= 0) {
            
            CGFloat base = .4 / 100;
            CGFloat offset = 1 - (base * translation.y);
            
            //update scale of preview
            [_windowPreview setTransform:CGAffineTransformMakeScale(offset, offset)];

        }
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        
        //pass
        if ([gesture locationInView:[[gesture view] superview]].y >= 80) {
            
            [self closeTutorial];
            
        }
        
        //or restore it to normal
        else {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [_windowPreview setTransform:CGAffineTransformIdentity];
                
            }];
            
        }
    }
}

@end
