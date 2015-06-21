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
		CDTLamoPanGestureRecognizer *panTrack = [[CDTLamoPanGestureRecognizer alloc] initWithTarget:[CDTLamo sharedInstance] action:@selector(handlePan:)];
		[self addGestureRecognizer:panTrack];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
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
    NSLog(@"Tap");
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

@end