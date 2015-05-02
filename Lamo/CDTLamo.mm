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

		//create arrays to hold hosted apps
		_hostedApplications = [[NSMutableArray alloc] init];
		_hostedContextViews = [[NSMutableArray alloc] init];

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

	if (![[self topmostApplication] isKindOfClass:NSClassFromString(@"SBApplication")]) {

		NSLog(@"You're killin me smalls");
		return;
	}

	//get bundle identifier for application
	NSString *bundleID = [[self topmostApplication] valueForKey:@"_bundleIdentifier"];

	//close the app now that we grabbed its bundle id
	[self seamlesslyCloseTopApp];

	//add application to hosted apps array
	[_hostedApplications addObject:bundleID];

	//create live context host
	UIView *contextHost = [_contextHostProvider hostViewForApplicationWithBundleID:bundleID];

	//hide statusbar
	[_contextHostProvider setStatusBarHidden:@(1) onApplicationWithBundleID:bundleID];

	//create container view
	UIView *appWindow = [[UIView alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + 40)];

	//add host to window
	[appWindow addSubview:contextHost];

	//shrink it down and update frame
	[appWindow setTransform:CGAffineTransformMakeScale(.6, .6)];
	[contextHost setFrame:CGRectMake(0, 40, contextHost.frame.size.width, contextHost.frame.size.height)];

	//create the 'title bar' window that holds the gestures
	CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
	[gestureView setTag:[_hostedApplications indexOfObject:bundleID]];
	[appWindow addSubview:gestureView];

	
	//add it to array
	[_hostedContextViews addObject:appWindow];

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

- (void)unwindowApplicationAtIndex:(int)indexOfApp {

	//show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:[_hostedApplications objectAtIndex:indexOfApp]];

	//animate it out
	[UIView animateWithDuration:0.3 animations:^{

		//fade it out
		[[_hostedContextViews objectAtIndex:indexOfApp] setAlpha:0];
		[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] setTransform:CGAffineTransformMakeScale(.1, .1)];

	} completion:^(BOOL completed){

		//end hosting
		NSString *bundleID = [_hostedApplications objectAtIndex:indexOfApp];
		SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
		[_contextHostProvider disableBackgroundingForApplication:appToHost];
		[_contextHostProvider stopHostingForBundleID:bundleID];

		//remove the view
		[[_hostedContextViews objectAtIndex:indexOfApp] removeFromSuperview];

		//remove it from arrays
		//[_hostedApplications removeObjectAtIndex:indexOfApp];
		//[_hostedContextViews removeObjectAtIndex:indexOfApp];

	}];

}

- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion {

	if (![app isKindOfClass:NSClassFromString(@"SBApplication")]) {

		NSLog(@"You're killin me smalls");
		return;
	}

	//get bundle id
	NSString *bundleID = [app valueForKey:@"_bundleIdentifier"];

	//show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:bundleID];

	//close the window if its currently context hosted
	if ([_hostedApplications containsObject:bundleID]) {

		[_contextHostProvider disableBackgroundingForApplication:app];
		[_contextHostProvider stopHostingForBundleID:bundleID];

		int indexOfApp = [_hostedApplications indexOfObject:bundleID];
		
		//remove the view
		[[_hostedContextViews objectAtIndex:indexOfApp] removeFromSuperview];

		//remove it from arrays
		//[_hostedApplications removeObjectAtIndex:indexOfApp];
		//[_hostedContextViews removeObjectAtIndex:indexOfApp];

	}

	completion();

}

- (void)launchFullModeFromWindowForApplication:(SBApplication *)appToOpen {

	if (![appToOpen isKindOfClass:NSClassFromString(@"SBApplication")]) {

		NSLog(@"You're killin me smalls");
		return;
	}

	//get bundle id
	NSString *bundleID = [appToOpen valueForKey:@"_bundleIdentifier"];
	int indexOfApp = [_hostedApplications indexOfObject:bundleID];

	//show statusbar
	[_contextHostProvider setStatusBarHidden:@(0) onApplicationWithBundleID:bundleID];

	[UIView animateWithDuration:0.4f animations:^{

		[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] setTransform:CGAffineTransformIdentity];
		[[_hostedContextViews objectAtIndex:indexOfApp] setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];

	} completion:^(BOOL completed) {

		//close the window if its currently context hosted
		if ([_hostedApplications containsObject:bundleID]) {

			[_contextHostProvider disableBackgroundingForApplication:appToOpen];
			[_contextHostProvider stopHostingForBundleID:bundleID];

			//remove the view
			[[_hostedContextViews objectAtIndex:indexOfApp] removeFromSuperview];

			//remove it from arrays
			//[_hostedApplications removeObjectAtIndex:indexOfApp];
			//[_hostedContextViews removeObjectAtIndex:indexOfApp];

			SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

			//disable animated launch
			[app setFlag:1 forActivationSetting:1];

			//open
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:NO];
			
		}

	}];

}

- (void)triggerLandscapeForApplication:(SBApplication *)application {

	//get bundle id
	NSString *bundleID = [application valueForKey:@"_bundleIdentifier"];
	int indexOfApp = [_hostedApplications indexOfObject:bundleID];

	//put app in landscape mode
	[_contextHostProvider sendLandscapeRotationNotificationToBundleID:bundleID];

	//rotate context view
	[UIView animateWithDuration:0.45f animations:^{

		//rotatw 90 and keep scale of .6
		CGAffineTransform scale = CGAffineTransformMakeScale(.6, .6);
		CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI * -90 / 180);
		[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] setTransform:CGAffineTransformConcat(scale, rotate)];

		//hide gesture view of window
		//[[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] subviews][1] setAlpha:0];
		//[[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] subviews][1] setFrame:CGRectMake(0, 40, kScreenWidth, 40)];

	} completion:^(BOOL completed) {

		//show gesture view of window (only want scale transform, not rotation)
		//[[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] subviews][1] setFrame:CGRectMake(0, 0, kScreenWidth, 40)];
		//[(UIView *)[[_hostedContextViews objectAtIndex:indexOfApp] subviews][1] setTransform:CGAffineTransformMakeRotation(M_PI * 90 / 180)];
		//[[(UIView *)[_hostedContextViews objectAtIndex:indexOfApp] subviews][1] setAlpha:0.7];

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