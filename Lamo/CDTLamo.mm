#import "CDTLamo.h"

@implementation CDTLamo

+ (id)sharedInstance {
	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}

- (id)init {

	if (self = [super init]) {

		//not tracking initially
		_wrapperViewIsTracking = NO;

		//create host view provider
		_contextHostProvider = [[CDTContextHostProvider alloc] init];

		//create dict to hold hosted apps
		_windows = [[NSMutableDictionary alloc] init];

	}

	return self;

}

- (void)beginShowingHomescreen {

	//throw the wallpaper up
	[[NSClassFromString(@"SBWallpaperController") sharedInstance] beginRequiringWithReason:@"CDTLamoScalingBegan"];

	//show homescreen items
	[[NSClassFromString(@"SBUIController") sharedInstance] restoreContentAndUnscatterIconsAnimated:NO];

}

- (void)updateWrapperView {

	//set wrapper view to topmost app's host view wrapper
	FBScene *appScene = [[self topmostApplication] mainScene];
	FBWindowContextHostManager *appContextManager = [appScene contextHostManager];
	_sharedScalingWrapperView = [[appContextManager valueForKey:@"_hostView"] superview];
    _springboardWindow = [[[appContextManager valueForKey:@"_hostView"] superview] window];
}

- (void)seamlesslyCloseTopApp {

	//create even to deactivate the application
	FBWorkspaceEvent *event = [NSClassFromString(@"FBWorkspaceEvent") eventWithName:@"ActivateSpringBoard" handler:^{
        SBDeactivationSettings *deactiveSets = [[NSClassFromString(@"SBDeactivationSettings") alloc] init];
        [deactiveSets setFlag:YES forDeactivationSetting:20];
        [deactiveSets setFlag:NO forDeactivationSetting:2];
        [[self topmostApplication] _setDeactivationSettings:deactiveSets];
        SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithAlertManager:nil exitedApp:[self topmostApplication]];
        [transaction begin];

	}];

	//execute it
	[(FBWorkspaceEventQueue *)[NSClassFromString(@"FBWorkspaceEventQueue") sharedInstance] executeOrAppendEvent:event];

}

- (void)addTopBarToWrapperWindow {

	//create the bar
	CDTLamoBarView *wrapperBarView = [[CDTLamoBarView alloc] init];

	//make it sit on top of the app
	[wrapperBarView setFrame:CGRectMake(0, -40, kScreenWidth, 40)];

	[_sharedScalingWrapperView addSubview:wrapperBarView];

}

- (void)beginWindowModeForTopApplication {

	//get bundle identifier for application
	NSString *bundleID = [[self topmostApplication] valueForKey:@"_bundleIdentifier"];

	//close the app now that we grabbed its bundle id
	[self seamlesslyCloseTopApp];

	//create live context host
	UIView *contextHost = [_contextHostProvider hostViewForApplicationWithBundleID:bundleID];

	//hide statusbar
	[_contextHostProvider setStatusBarHidden:@(1) onApplicationWithBundleID:bundleID];

	//create container view
	CDTLamoWindow *appWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + 40)];
    [appWindow setIdentifier:bundleID];
    
    //naivly assume portrait for the time being
    [appWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
    
	//add host to window
	[appWindow addSubview:contextHost];

	//shrink it down and update frame
	[appWindow setTransform:CGAffineTransformMakeScale(.6, .6)];
	[contextHost setFrame:CGRectMake(0, 40, contextHost.frame.size.width, contextHost.frame.size.height)];

	//create the 'title bar' window that holds the gestures
	CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
	[appWindow addSubview:gestureView];

	
	//add it to dict
	[_windows setValue:appWindow forKey:bundleID];

	//add context window to springboard window
    [_springboardWindow addSubview:appWindow];

    //animate it popping in
    [self doPopAnimationForView:appWindow];

}

- (void)doPopAnimationForView:(UIView *)viewToPop {

	[UIView animateWithDuration:0.1 animations:^{

    	[viewToPop setTransform:CGAffineTransformMakeScale(.5, .5)];

    } completion:^(BOOL finished){

    	[UIView animateWithDuration:0.1 animations:^{

    		[viewToPop setTransform:CGAffineTransformMakeScale(.65, .65)];

    	} completion:^(BOOL finished){

    		[UIView animateWithDuration:0.1 animations:^{

    			[viewToPop setTransform:CGAffineTransformMakeScale(.6, .6)];

    		}];

    	}];

    }];

}

- (void)unwindowApplicationWithBundleID:(NSString *)bundleID {
    
    //get window instance, if exists
    CDTLamoWindow *window;
    if ([_windows valueForKey:bundleID]) {
        
        window = [_windows valueForKey:bundleID];
    }
    
    else {
        
        //stop if it doesnt exist
        return;
    }
    
    //show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:bundleID];
    
	//animate it out
	[UIView animateWithDuration:0.3 animations:^{

		//fade it out
		[window setAlpha:0];
		[window setTransform:CGAffineTransformMakeScale(.1, .1)];

	} completion:^(BOOL completed){

		//end hosting
		SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
		[_contextHostProvider disableBackgroundingForApplication:appToHost];
		[_contextHostProvider stopHostingForBundleID:bundleID];
        
        //switch it to portrait so it doesnt open in landscape
        [self triggerPortraitForApplication:appToHost];
        
		//remove the view
		[window removeFromSuperview];

	}];

}

- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion {

	//get bundle id
	NSString *bundleID = [app valueForKey:@"_bundleIdentifier"];

	//show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:bundleID];

	//close the window if its currently context hosted
	if ([_windows valueForKey:bundleID]) {

		[_contextHostProvider disableBackgroundingForApplication:app];
		[_contextHostProvider stopHostingForBundleID:bundleID];

		//get window so we can remove it
        CDTLamoWindow *window = [_windows valueForKey:bundleID];
		
		//remove the view
		[window removeFromSuperview];

	}
    
    //if on ipad, reenable hosting for each context when app is done launching
    if (NEED_IPAD_HAX) {
        
        (void)[[NSClassFromString(@"SBLaunchAppListener") alloc] initWithBundleIdentifier:bundleID handlerBlock:^(void) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                [_contextHostProvider _ipad_only_update_hosting];

            });
            
        }];
    }
    
	completion();

}

- (void)launchFullModeFromWindowForApplication:(SBApplication *)appToOpen {

	//get bundle id
	NSString *bundleID = [appToOpen valueForKey:@"_bundleIdentifier"];

    //get window so we can remove it
    CDTLamoWindow *window;
    if ([_windows valueForKey:bundleID]) {
        
        window = [_windows valueForKey:bundleID];
    }
    else {
        
        //stop, no window
        return;
    }
    
	//show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:bundleID];

	[UIView animateWithDuration:0.4f animations:^{

		[window setTransform:CGAffineTransformIdentity];
		[window setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];

	} completion:^(BOOL completed) {

		//close the window if its currently context hosted
		if ([_windows valueForKey:bundleID]) {

			[_contextHostProvider disableBackgroundingForApplication:appToOpen];
			[_contextHostProvider stopHostingForBundleID:bundleID];

			//remove the view
			[window removeFromSuperview];

			//disable animated launch
			[appToOpen setFlag:1 forActivationSetting:1];

			//open
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
			
		}

	}];

}

- (void)triggerLandscapeForApplication:(SBApplication *)application {

	//get bundle id
	NSString *bundleID = [application valueForKey:@"_bundleIdentifier"];
    
    //get window so we can remove it
    CDTLamoWindow *window;
    if ([_windows valueForKey:bundleID]) {
        
        window = [_windows valueForKey:bundleID];
    }
    else {
        
        //stop, no window
        return;
    }
    
    //stop if already in landscape
    if ([window activeOrientation] == (UIInterfaceOrientation *)UIInterfaceOrientationLandscapeRight) {
        
        return;
    }
    
    //update window orientation
    [window setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationLandscapeLeft];
    
	//put app in landscape mode
	[_contextHostProvider sendLandscapeRotationNotificationToBundleID:bundleID];

	//rotate context view
	[UIView animateWithDuration:0.45f animations:^{

		//rotate 90 and keep scale of .6
		CGAffineTransform scale = CGAffineTransformMakeScale(.6, .6);
		CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI * -90 / 180);
		[window setTransform:CGAffineTransformConcat(scale, rotate)];
        
        //set frame to ensure window bar isnt out of screen bounds
        CGRect appWindowFrame = [window frame];
        if (appWindowFrame.origin.x <= 0) {
            
            //off of screen, bounce it back
            appWindowFrame.origin.x = 5;
            [window setFrame:appWindowFrame];
            
        }

	}];

}

- (void)triggerPortraitForApplication:(SBApplication *)application {
    
    //get bundle id
    NSString *bundleID = [application valueForKey:@"_bundleIdentifier"];
    
    //get window so we can remove it
    CDTLamoWindow *window;
    if ([_windows valueForKey:bundleID]) {
        
        window = [_windows valueForKey:bundleID];
    }
    else {
        
        //stop, no window
        return;
    }
    
    //update window orientation
    [window setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
    
    //put app in landscape mode
    [_contextHostProvider sendPortraitRotationNotificationToBundleID:bundleID];
    
    //rotate context view
    [UIView animateWithDuration:0.45f animations:^{
        
        //scale of .6, this will also revert the 90 degree rotation
        [window setTransform:CGAffineTransformMakeScale(.6, .6)];
        
    }];
    
}

- (void)handlePan:(UIPanGestureRecognizer *)panGesture {

	//bring it to front
    [[[[panGesture view] superview] superview] bringSubviewToFront:[[panGesture view] superview]];

    if ([panGesture state] == UIGestureRecognizerStateBegan) {
        _offset = [[[panGesture view] superview] frame].origin;
    } else

    if ([panGesture state] == UIGestureRecognizerStateChanged) {

        CGPoint translation = [panGesture translationInView:[self springboardWindow]];
        if (_offset.x + translation.x <= 0 - ((kScreenWidth * .6) / 2) || _offset.y + translation.y >= kScreenHeight - ((kScreenHeight * .6) / 2) || _offset.y + translation.y <= 0 || _offset.x + translation.x >= kScreenWidth - ((kScreenWidth * .6) / 2)) {

        	//outside of screen bounds
        	return; 
        }

        [[[panGesture view] superview] setFrame:CGRectMake(_offset.x + translation.x, _offset.y + translation.y, [[panGesture view] superview].frame.size.width, [[panGesture view] superview].frame.size.height)];

    }

}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {

	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        // Reset the last scale, necessary if there are multiple objects with different scales
        _lastScale = [gestureRecognizer scale];
    }

    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || 
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {

        CGFloat currentScale = [[[gestureRecognizer view].superview.layer valueForKeyPath:@"transform.scale"] floatValue];

        const CGFloat kMaxScale = 1.0;
        const CGFloat kMinScale = .4;

        CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]); 
        newScale = MIN(newScale, kMaxScale / currentScale);   
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view].superview transform], newScale, newScale);
        [gestureRecognizer view].superview.transform = transform;

        _lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call  
    }

}

- (id)topmostApplication {

	//just return top most application from UIApp
	return [[UIApplication sharedApplication] _accessibilityFrontMostApplication];

}

@end 