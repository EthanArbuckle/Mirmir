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
    
    //make sure app is _there_ and running
    if (!bundleID || [(SBApplication *)[self topmostApplication] pid] <= 0) {
        
        //if not throw a message and stop
        [[[UIAlertView alloc] initWithTitle:@"Whoopsies" message:@"Failed to enter window mode for the application :-(." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] show];
        return;
    }
    
    //close the app now that we grabbed its bundle id
	[self seamlesslyCloseTopApp];

	//create live context host
	UIView *contextHost = [_contextHostProvider hostViewForApplicationWithBundleID:bundleID];

	//create container view
	CDTLamoWindow *appWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + 40)];
    
    [appWindow setIdentifier:bundleID];
    
    if ([[self topmostApplication] respondsToSelector:@selector(statusBarHidden)]) {
        
        [appWindow setStatusBarHidden:[(SBApplication *)[self topmostApplication] statusBarHidden]];
    }
    
    //naivly assume portrait for the time being
    [appWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
    
	//add host to window
	[appWindow addSubview:contextHost];
    
    //hide statusbar
    [_contextHostProvider setStatusBarHidden:@(1) onApplicationWithBundleID:bundleID];
    
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
	[_contextHostProvider setStatusBarHidden:@([window statusBarHidden]) onApplicationWithBundleID:bundleID];
    
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
        
        //remove value from dict
        [_windows removeObjectForKey:bundleID];

	}];

}

- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion {

	//get bundle id
	NSString *bundleID = [app valueForKey:@"_bundleIdentifier"];

	//close the window if its currently context hosted
	if ([_windows valueForKey:bundleID]) {
        
		[_contextHostProvider disableBackgroundingForApplication:app];
		[_contextHostProvider stopHostingForBundleID:bundleID];

		//get window so we can remove it
        CDTLamoWindow *window = [_windows valueForKey:bundleID];
		
        //restore statusbar
        [_contextHostProvider setStatusBarHidden:@([window statusBarHidden]) onApplicationWithBundleID:bundleID];
        
		//remove the view
		[window removeFromSuperview];
        
        //remove value from dict
        [_windows removeObjectForKey:bundleID];

	}
    
    //if on ipad, reenable hosting for each context when app is done launching
    if (NEED_IPAD_HAX) {
        
        (void)[[NSClassFromString(@"SBLaunchAppListener") alloc] initWithBundleIdentifier:bundleID handlerBlock:^(void) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                //this cycles our windows apps, and renabled hosting for each context view with priority 1
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
	[_contextHostProvider setStatusBarHidden:@([window statusBarHidden]) onApplicationWithBundleID:bundleID];

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
            
            //remove value from dict
            [_windows removeObjectForKey:bundleID];
			
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
        
        //set frame to ensure window bar isnt out of screen bounds
        CGRect appWindowFrame = [window frame];
        if (appWindowFrame.origin.y <= 0) {
            
            //off of screen, bounce it back
            appWindowFrame.origin.y = 5;
            [window setFrame:appWindowFrame];
            
        }
        
    }];
    
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
        
        [_longPress_timer invalidate];
        _longPress_isPressed = NO;
    }
    
    //hacky, but we're piggybacking a longpress gesture on this pan gesture
    if (_longPress_isPressed) {
        
        [self longPress_panWithGesture:panGesture];
        
        return;
    }

    if ([panGesture state] == UIGestureRecognizerStateBegan) {
        
        [self longPress_beginTimer];
        
        _offset = [[[panGesture view] superview] frame].origin;
        
        //bring it to front
        [[[[panGesture view] superview] superview] bringSubviewToFront:[[panGesture view] superview]];
        
    } else

    if ([panGesture state] == UIGestureRecognizerStateChanged) {
        
        [self longPress_beginTimer];
        
        CGPoint translation = [panGesture translationInView:[self springboardWindow]];
        
       // NSLog(@"%f, %f", translation.x + _offset.x, translation.y + _offset.y);
        
        //window snapping shit
        
        if (translation.x + _offset.x <= -5 && translation.y + _offset.y <= -5) { //top left
            
            //this makes the window a bit clear, and sets up the snapping action block
            [self primeApplicationForSnapping:[(CDTLamoWindow *)[[panGesture view] superview] identifier] toPosition:CDTLamoSnapTopLeft];
        }
        
        else if (_offset.x + translation.x >= kScreenWidth - ((kScreenWidth * .6) / 2) && translation.y + _offset.y <= -5) { //top right
            
            [self primeApplicationForSnapping:[(CDTLamoWindow *)[[panGesture view] superview] identifier] toPosition:CDTLamoSnapTopRight];
        }
        
        else {
            
            //window is out of snap region, unprime the shit
            if (_isPrimedForSnapping) {
                
                _isPrimedForSnapping = NO;
                
                //restore alpha
                [[_windows valueForKey:[(CDTLamoWindow *)[[panGesture view] superview] identifier]] setAlpha:1];
                
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

//these methods are a hacky way to piggypack on the windows pangesture to achieve a long press gesture recognizer
- (void)longPress_beginTimer {

    //invalidate timer just in case we're called twice consecutively
    _longPress_isPressed = NO;
    [_longPress_timer invalidate];
    
    //recreate it with our long press interval
    _longPress_timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(longPress_timerFired) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_longPress_timer forMode:NSDefaultRunLoopMode];
}

- (void)longPress_timerFired {

    _longPress_isPressed = YES;
}

- (void)longPress_panWithGesture:(UIPanGestureRecognizer *)panGesture {
    
    //get finger y origin position
    CGFloat yScale = [panGesture translationInView:_springboardWindow].y;
    CGFloat scale;
    
    //so we dont get weird stuffs
    if (yScale <= 0) {
        
        yScale = 0;
    }
    
    CGFloat base = .6 / 50;
    scale = base * yScale;
    
    [UIView animateWithDuration:.3 animations:^{
        
        [(UIView *)[_windows valueForKey:[(CDTLamoWindow *)[[panGesture view] superview] identifier]] setTransform:CGAffineTransformMakeScale(1 - scale, 1 - scale)];
    }];
    
}
//ok end hacks

- (id)topmostApplication {

	//just return top most application from UIApp
	return [[UIApplication sharedApplication] _accessibilityFrontMostApplication];

}

- (void)addView:(UIView *)view toDictWithIdentifier:(NSString *)bundleID {
    
    [_windows setObject:view forKey:bundleID];
}

- (void)primeApplicationForSnapping:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position {
    
    //stop if already primed
    if (_isPrimedForSnapping) {
        
        return;
    }
    
    //get window
    __block CDTLamoWindow *windowToSnap = [_windows valueForKey:identifier];
    
    //prime da snappies
    _isPrimedForSnapping = YES;
    _primedSnapAction = ^{
        [UIView animateWithDuration:0.3 animations:^{
            [[CDTLamo sharedInstance] snapApplication:identifier toPosition:position];
            [windowToSnap setAlpha:1];
        }];
        
    };
    
    //make it transparent
    [windowToSnap setAlpha:0.5];
    
}

- (void)snapApplication:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position {
    
    //if the app window exists, cycle through each possible snap position
    if ([_windows valueForKey:identifier]) {
        
        CDTLamoWindow *windowToSnap = [_windows valueForKey:identifier];
        
        switch (position) {
            case CDTLamoSnapLeft:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, 1)];
                [windowToSnap setFrame:CGRectMake(0, 0, kScreenWidth * .5, kScreenHeight)];
                
                break;
                
            case CDTLamoSnapRight:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, 1)];
                [windowToSnap setFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth * .5, kScreenHeight)];
                
                break;
                
            case CDTLamoSnapTopLeft:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, .5)];
                [windowToSnap setFrame:CGRectMake(0, 0, kScreenWidth * .5, kScreenHeight * .5)];
                
                break;
                
            case CDTLamoSnapTopRight:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, .5)];
                [windowToSnap setFrame:CGRectMake(kScreenWidth / 2, 0, kScreenWidth * .5, kScreenHeight * .5)];
                
                break;
                
            case CDTLamoSnapBottomLeft:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, .5)];
                [windowToSnap setFrame:CGRectMake(0, kScreenHeight / 2, kScreenWidth * .5, kScreenHeight * .5)];
                
                break;
                
            case CDTLamoSnapBottomRight:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(.5, .5)];
                [windowToSnap setFrame:CGRectMake(kScreenWidth / 2, kScreenHeight / 2, kScreenWidth * .5, kScreenHeight * .5)];
                
                break;
                
            case CDTLamoSnapTop:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(1, .5)];
                [windowToSnap setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight * .5)];
                
                break;
                
            case CDTLamoSnapBottom:
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(1, .5)];
                [windowToSnap setFrame:CGRectMake(0, kScreenHeight / 2, kScreenWidth, kScreenHeight * .5)];
                
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)shouldBlockNotificationCenter {
    
    if (![[CDTLamoSettings sharedSettings] isEnabled]) {
        
        return NO;
    }
    
    //cycle through windows and return YES if any of them are within 20points of top
    for (NSString *windowID in [_windows allKeys]) {
        
        if ([[_windows valueForKey:windowID] frame].origin.y <= 40) {
            
            return YES;
        }
    }
    
    return NO;
}

@end 