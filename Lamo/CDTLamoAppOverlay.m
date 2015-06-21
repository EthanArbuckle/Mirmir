//
//  CDTLamoAppOverlay.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/21/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoAppOverlay.h"

@implementation CDTLamoAppOverlay

- (id)initWithOrientation:(UIInterfaceOrientation *)orientation {
    
    if (self = [super init]) {
        
        //create blurred backdrop
        _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:2060];
        [blurView setBlurRadius:10];
        [blurView setFrame:[self frame]];
        [self insertSubview:blurView atIndex:0];
        
        NSString *resourcePath = @"/Library/Application Support/Lamo";
        
#ifdef TARGET_IPHONE_SIMULATOR
        resourcePath = [NSString stringWithFormat:@"%s/Resources", stringify(SRC_ROOT)];
#endif
        
        //create pinching gesture
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self addGestureRecognizer:pinchGesture];
        
        //create minimize button
        UIButton *minimizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [minimizeButton setFrame:CGRectMake((kScreenWidth / 2) - 35, (kScreenHeight / 2) - 35, 70, 70)];
        [minimizeButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/min.png", resourcePath]] forState:UIControlStateNormal];
        [minimizeButton addTarget:[(CDTLamoWindow *)[self superview] barView] action:@selector(handleMin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:minimizeButton];
        
        //create maximize button
        UIButton *maximizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [maximizeButton setFrame:CGRectMake((kScreenWidth / 2) - 35, [minimizeButton frame].origin.y - 100, 70, 70)];
        [maximizeButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/full.png", resourcePath]] forState:UIControlStateNormal];
        [maximizeButton addTarget:[(CDTLamoWindow *)[self superview] barView] action:@selector(handleMax) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:maximizeButton];
        
        //create close button
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake((kScreenWidth / 2) - 35, [minimizeButton frame].origin.y + 100, 70, 70)];
        [closeButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/close.png", resourcePath]] forState:UIControlStateNormal];
        [closeButton addTarget:[(CDTLamoWindow *)[self superview] barView] action:@selector(handleClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        //create orientation button
        UIButton *orientationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [orientationButton setFrame:CGRectMake(kScreenWidth - 55, kScreenHeight - 55, 45, 45)];
        [orientationButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/rotate.png", resourcePath]] forState:UIControlStateNormal];
        [orientationButton addTarget:self action:@selector(handleOrientation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:orientationButton];
        
    }
    
    return self;
}

- (void)handleClose {
    
    //close window
    [[CDTLamo sharedInstance] unwindowApplicationWithBundleID:[(CDTLamoWindow *)[self superview] identifier]];
    
}

- (void)handleMin {
    
    //animate scale back to .6
    [UIView animateWithDuration:0.3f animations:^{
        
        [[self superview] setTransform:CGAffineTransformMakeScale(.6, .6)];
        
        //set frame to ensure window bar isnt out of screen bounds
        CGRect appWindowFrame = [[self superview] frame];
        
        if (appWindowFrame.origin.y <= 0) {
            
            //off of screen, bounce it back
            appWindowFrame.origin.y = 5;
        }
        
        if (appWindowFrame.origin.x <= 0) {
            
            //bounce this back too
            appWindowFrame.origin.x = 5;
        }
        
        [[self superview] setFrame:appWindowFrame];
        
        
    }];
    
}

- (void)handleMax {
    
    //get sbapp
    SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[(CDTLamoWindow *)[self superview] identifier]];
    
    //launch it fullscreen
    [[CDTLamo sharedInstance] launchFullModeFromWindowForApplication:app];
    
}

- (void)handleOrientation {
    
    //get app
    SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[(CDTLamoWindow *)[self superview] identifier]];
    
    //trigger portrait opposite of current one
    if ([(CDTLamoWindow *)[self superview] activeOrientation] == (UIInterfaceOrientation *)UIInterfaceOrientationLandscapeLeft) {
        
        //in landscape, trigger portrait
        [(CDTLamoWindow *)[self superview] setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
        [[CDTLamo sharedInstance] triggerPortraitForApplication:app];
        
    }
    else {
        
        //in portrait, trigger landscape
        [(CDTLamoWindow *)[self superview] setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationLandscapeLeft];
        [[CDTLamo sharedInstance] triggerLandscapeForApplication:app];
        
    }
    
}

//http://stackoverflow.com/questions/5150642/max-min-scale-of-pinch-zoom-in-uipinchgesturerecognizer-iphone-ios
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        _lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[[gestureRecognizer view] superview].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 1.0;
        const CGFloat kMinScale = .4;
        
        CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[[gestureRecognizer view] superview] transform], newScale, newScale);
        [[gestureRecognizer view] superview].transform = transform;
        
        _lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }
}

@end
