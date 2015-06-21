#import "CDTLamoBarView.h"

@implementation CDTLamoBarView

- (id)init {

	if (self = [super init]) {

		//create the bar
		[self setFrame:CGRectMake(0, 0, kScreenWidth, 20)];
		[self setBackgroundColor:[UIColor darkGrayColor]];
		[self setAlpha:0.9];
		[self setUserInteractionEnabled:YES];

		//add pangesture to make it movable
		CDTLamoPanGestureRecognizer *panTrack = [[CDTLamoPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panTrack setDelegate:self];
		[self addGestureRecognizer:panTrack];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [tapGesture setDelegate:self];
        [self addGestureRecognizer:tapGesture];
        
    }

	return self;
}

- (void)setTitle:(NSString *)title {
    
    //create app name label
    UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    [appNameLabel setTextColor:[UIColor whiteColor]];
    [appNameLabel setTextAlignment:NSTextAlignmentCenter];
    [appNameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]];
    [appNameLabel setText:title];
    [self addSubview:appNameLabel];
    
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    //check if we need to create or remove overlay
    if (_overlayView && [_overlayView superview]) {
        
        //remove it
        [UIView animateWithDuration:0.4f animations:^{
            
            [_overlayView setAlpha:0];
        } completion:^(BOOL finished) {
            
            _overlayView = nil;
        }];
    }
    
    else {
    
        //create overlay options. frame is in context of superview, cdtlamowindow
        _overlayView = [[CDTLamoAppOverlay alloc] initWithOrientation:[(CDTLamoWindow *)[self superview] activeOrientation]];
        [_overlayView setFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight)];
        [_overlayView setBackgroundColor:[UIColor clearColor]];
        [_overlayView setAlpha:0];
        [[self superview] addSubview:_overlayView];
        
        [UIView animateWithDuration:0.4f animations:^{
            [_overlayView setAlpha:1];
        }];
    }
    
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {
    
    if ([panGesture state] == UIGestureRecognizerStateEnded) {
        
        //check if we're primed to snap
        if (_isPrimedForSnapping) {
            
            //we're primed, execute the snapz
            _primedSnapAction();
            
            //and cancel it out so we dont double snapz
            _isPrimedForSnapping = NO;
            _primedSnapAction = nil;
            
        }
        
    }
    
    if ([panGesture state] == UIGestureRecognizerStateBegan) {
        
        _offset = [[[panGesture view] superview] frame].origin;
        
        //bring it to front
        [[[[panGesture view] superview] superview] bringSubviewToFront:[[panGesture view] superview]];
        
    } else
        
        if ([panGesture state] == UIGestureRecognizerStateChanged) {
            
            CGPoint translation = [panGesture translationInView:[[CDTLamo sharedInstance] springboardWindow]];
            
            //window snapping shit
            
            if (translation.x + _offset.x <= -5 && translation.y + _offset.y <= -5) { //top left
                
                //this makes the window a bit clear, and sets up the snapping action block
                [[CDTLamo sharedInstance] primeApplicationForSnapping:[(CDTLamoWindow *)[[panGesture view] superview] identifier] toPosition:CDTLamoSnapTopLeft];
            }
            
            else if (_offset.x + translation.x >= kScreenWidth - ((kScreenWidth * .6) / 2) && translation.y + _offset.y <= -5) { //top right
                
                [[CDTLamo sharedInstance] primeApplicationForSnapping:[(CDTLamoWindow *)[[panGesture view] superview] identifier] toPosition:CDTLamoSnapTopRight];
            }
            
            else {
                
                //window is out of snap region, unprime the shit
                if (_isPrimedForSnapping) {
                    
                    _isPrimedForSnapping = NO;
                    
                    //restore alpha
                    [[[[CDTLamo sharedInstance] windows] valueForKey:[(CDTLamoWindow *)[[panGesture view] superview] identifier]] setAlpha:1];
                    
                    _primedSnapAction = nil;
                }
            }
            
            CGRect bounds = CGRectMake(_offset.x + translation.x, _offset.y + translation.y, [[panGesture view] superview].frame.size.width,[[panGesture view] superview].frame.size.height);
            
            if (bounds.origin.x <= -((kScreenWidth * .6) / 2)) bounds.origin.x = -((kScreenWidth *.6) / 2);
            if (bounds.origin.y >= kScreenHeight - ((kScreenHeight * .6) / 2)) bounds.origin.y = kScreenHeight - ((kScreenHeight * .6) / 2);
            if (bounds.origin.y <= 0) bounds.origin.y = 0;
            if (bounds.origin.x >= kScreenWidth - ((kScreenWidth * .6) / 2)) bounds.origin.x = kScreenWidth - ((kScreenWidth * .6) / 2);
            
            [[[panGesture view] superview] setFrame:bounds];
            
        }
    
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

- (BOOL)gestureRecognizer:(nonnull UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end