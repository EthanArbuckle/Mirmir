#import "CDTLamo.h"

@implementation CDTLamo

static SBWorkspaceApplicationTransitionContext *transitionContext;
static SBWorkspaceDeactivatingEntity *deactivatingEntity;
static SBWorkspaceHomeScreenEntity *homescreenEntity;
static SBMainWorkspaceTransitionRequest *transitionRequest;
static SBAppToAppWorkspaceTransaction *transaction;

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
        
        //create our own window on ios 7 & 9
        if ((iOS7) || GTEiOS9) {
            
            _springboardWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [_springboardWindow setWindowLevel:9999];
            [_springboardWindow makeKeyAndVisible];
        }

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
    
    //window arrangment changed a bit on ios 9
    if (GTEiOS9) {
        
        _sharedScalingWrapperView = [_sharedScalingWrapperView superview];
    }
    
    if (iOS8) {
        
        _springboardWindow = [[[appContextManager valueForKey:@"_hostView"] superview] window];
    }
}

- (void)seamlesslyCloseTopApp {
    
	//create even to deactivate the application
	FBWorkspaceEvent *event = [NSClassFromString(@"FBWorkspaceEvent") eventWithName:@"ActivateSpringBoard" handler:^{
        SBDeactivationSettings *deactiveSets = [[NSClassFromString(@"SBDeactivationSettings") alloc] init];
        [deactiveSets setFlag:YES forDeactivationSetting:20];
        [deactiveSets setFlag:NO forDeactivationSetting:2];
        [[self topmostApplication] _setDeactivationSettings:deactiveSets];
        
        //very different ways to close apps between iOS 8 and 9
        if (GTEiOS9) {
            
            transitionContext = [[NSClassFromString(@"SBWorkspaceApplicationTransitionContext") alloc] init];
            
            //set layout role to 'side' (deactivating)
            deactivatingEntity = [NSClassFromString(@"SBWorkspaceDeactivatingEntity") entity];
            [deactivatingEntity setLayoutRole:3];
            [transitionContext setEntity:deactivatingEntity forLayoutRole:3];
            
            //set layout role for 'primary' (activating)
            homescreenEntity = [[NSClassFromString(@"SBWorkspaceHomeScreenEntity") alloc] init];
            [transitionContext setEntity:homescreenEntity forLayoutRole:2];
            
            [transitionContext setAnimationDisabled:YES];
            
            //create transititon request
            transitionRequest = [[NSClassFromString(@"SBMainWorkspaceTransitionRequest") alloc] initWithDisplay:[[UIScreen mainScreen] valueForKey:@"_fbsDisplay"]];
            [transitionRequest setValue:transitionContext forKey:@"_applicationContext"];
            
            //create apptoapp transaction
            transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithTransitionRequest:transitionRequest];
            
            [transaction begin];
            
        }
        
        else {
            
        
            SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"SBAppToAppWorkspaceTransaction") alloc] initWithAlertManager:nil exitedApp:[self topmostApplication]];
            
            [transaction begin];
        }

	}];

	//execute it
	[(FBWorkspaceEventQueue *)[NSClassFromString(@"FBWorkspaceEventQueue") sharedInstance] executeOrAppendEvent:event];

}

- (void)addTopBarToWrapperWindow {

	//create the bar
	CDTLamoBarView *wrapperBarView = [[CDTLamoBarView alloc] init];
    [wrapperBarView setTitle:[[self topmostApplication] valueForKey:@"_displayName"]];

	//make it sit on top of the app
	[wrapperBarView setFrame:CGRectMake(0, -20, kScreenWidth, 20)];

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
    
    //create the 'title bar' window that holds the gestures
    //make this before we close the app so we can access topmost app and get the name
    CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
    [gestureView setTitle:[[self topmostApplication] valueForKey:@"_displayName"]];
    
    //close the app now that we grabbed its bundle id
	[self seamlesslyCloseTopApp];

    //create live context host
	UIView *contextHost = [_contextHostProvider hostViewForApplicationWithBundleID:bundleID];

	//create container view
	CDTLamoWindow *appWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + 20)];
    
    [appWindow setIdentifier:bundleID];
    [appWindow setBarView:gestureView];
    
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
	[contextHost setFrame:CGRectMake(0, 20, contextHost.frame.size.width, contextHost.frame.size.height)];

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

		//rotate 90 and keep scale of .5
		CGAffineTransform scale = CGAffineTransformMakeScale(.5, .5);
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

- (id)topmostApplication {

	//just return top most application from UIApp
	return [[UIApplication sharedApplication] _accessibilityFrontMostApplication];

}

- (void)addView:(UIView *)view toDictWithIdentifier:(NSString *)bundleID {
    
    [_windows setObject:view forKey:bundleID];
}

- (void)primeApplicationForSnapping:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position {
    
    //get window
    __block CDTLamoWindow *windowToSnap = [_windows valueForKey:identifier];
    CDTLamoBarView *barView = (CDTLamoBarView *)[windowToSnap barView];
    
    //prime da snappies
    [barView setIsPrimedForSnapping:YES];
    
    [barView setPrimedSnapAction:^{
        
        [UIView animateWithDuration:0.3 animations:^{
            [[CDTLamo sharedInstance] snapApplication:identifier toPosition:position];
            [windowToSnap setAlpha:1];
        }];
        
    }];
    
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

- (void)presentSettingsController {
    
    //dont open more than one instance
    if ([_windows valueForKey:@"com.cortexdevteam.lamosetting"]) {
        
        return;
    }
    
    //create settings window
    CDTLamoWindow *settingsWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + 20)];
    [settingsWindow setIdentifier:@"com.cortexdevteam.lamosetting"];
    [settingsWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
    
    //create settings view controller
    CDTLamoSettingsViewController *settingsController = [[CDTLamoSettingsViewController alloc] init];
    [settingsWindow addSubview:[settingsController view]];
    
    //shrink it down and update frame
    [settingsWindow setTransform:CGAffineTransformMakeScale(.6, .6)];
    
    //create the 'title bar' window that holds the gestures
    CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
    [settingsWindow addSubview:gestureView];
    
    //add it to dict
    [_windows setValue:settingsWindow forKey:@"com.cortexdevteam.lamosetting"];
    
    //add window to springboard window
    [_springboardWindow addSubview:settingsWindow];
    
    //animate it popping in
    [self doPopAnimationForView:settingsWindow];

}

- (void)snapAllClose {
    
    //cycle through all windows and close them
    for (NSString *bundleID in [_windows allKeys]) {
        
        //end hosting
        SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
        [_contextHostProvider disableBackgroundingForApplication:appToHost];
        [_contextHostProvider stopHostingForBundleID:bundleID];
        
        //switch it to portrait so it doesnt open in landscape
        [self triggerPortraitForApplication:appToHost];
        
        CDTLamoWindow *window = [_windows objectForKey:bundleID];
        
        //remove the view
        [window removeFromSuperview];
        
        //remove value from dict
        [_windows removeObjectForKey:bundleID];
    }
}

@end 