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
        
        _stackedWindowLevel = 9999;
        
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
    
    if (!(iOS7)) {
        
        //set wrapper view to topmost app's host view wrapper
        FBScene *appScene = [[self topmostApplication] mainScene];
        FBWindowContextHostManager *appContextManager = [appScene contextHostManager];
        _sharedScalingWrapperView = [[appContextManager valueForKey:@"_hostView"] superview];
        
        //window arrangment changed a bit on ios 9
        if (GTEiOS9) {

            _sharedScalingWrapperView = [_sharedScalingWrapperView superview];

        }
        
    }
    
    else {
        
        //get hostview on iOS 7
        id contextHostManager = [[self topmostApplication] mainScreenContextHostManager];
        _sharedScalingWrapperView = [contextHostManager valueForKey:@"_hostView"];
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

    if (GTEiOS9) {
        
        [wrapperBarView setFrame:CGRectMake(0, 0, kScreenWidth, [[CDTLamoSettings sharedSettings] windowBarHeight])];
        [[_sharedScalingWrapperView subviews][1] addSubview:wrapperBarView];
        return;
    }
    
    //ios 8 and under
    //make it sit on top of the app
    [wrapperBarView setFrame:CGRectMake(0, -[[CDTLamoSettings sharedSettings] windowBarHeight], kScreenWidth, [[CDTLamoSettings sharedSettings] windowBarHeight])];
	[_sharedScalingWrapperView addSubview:wrapperBarView];

}

- (void)beginWindowModeForTopApplication {
    
    //get bundle identifier for application
    NSString *bundleID = [[self topmostApplication] valueForKey:@"_bundleIdentifier"];
    [self beginWindowModeForApplicationWithBundleID:bundleID];
    
}

- (void)beginWindowModeForApplicationWithBundleID:(NSString *)bundleID {
    
    SBApplication *appToWindow = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

    //create the 'title bar' window that holds the gestures
    //make this before we close the app so we can access topmost app and get the name
    CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
    [gestureView setTitle:[appToWindow valueForKey:@"_displayName"]];
    
    //close the app now that we grabbed its bundle id
	[self seamlesslyCloseTopApp];

    //create live context host
	UIView *contextHost = [_contextHostProvider hostViewForApplicationWithBundleID:bundleID];
    
    CGFloat barHeight = [[CDTLamoSettings sharedSettings] windowBarHeight];
    
	//create container view
	CDTLamoWindow *appWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(20, 20, kScreenWidth, kScreenHeight + barHeight)];
    
    [appWindow setIdentifier:bundleID];
    [appWindow setBarView:gestureView];
    [appWindow setHostedContextView:contextHost];
    [appWindow setWindowLevel:_stackedWindowLevel++];
    
    if ([appToWindow respondsToSelector:@selector(statusBarHidden)]) {
        
        [appWindow setStatusBarHidden:[appToWindow statusBarHidden]];
    }
    
	//add host to window
	[appWindow addSubview:contextHost];
    
    //hide statusbar
    [_contextHostProvider setStatusBarHidden:@(1) onApplicationWithBundleID:bundleID];
    
	//shrink it down and update frame
	[appWindow setTransform:CGAffineTransformMakeScale([[CDTLamoSettings sharedSettings] defaultWindowSize], [[CDTLamoSettings sharedSettings] defaultWindowSize])];
	[contextHost setFrame:CGRectMake(0, barHeight, contextHost.frame.size.width, contextHost.frame.size.height)];

	[appWindow addSubview:gestureView];
	
	//add it to dict
	[_windows setValue:appWindow forKey:bundleID];

    //add context window to springboard window
    //[_springboardWindow addSubview:appWindow];

    //animate it popping in
    [self doPopAnimationForView:appWindow withBase:[[CDTLamoSettings sharedSettings] defaultWindowSize]];
    
    //set to default orientation setting
    if ([[[CDTLamoSettings sharedSettings] defaultOrientation] isEqualToString:@"portrait"]) {
        
        [_contextHostProvider sendPortraitRotationNotificationToBundleID:bundleID];
    }
    else {
        [_contextHostProvider sendLandscapeRotationNotificationToBundleID:bundleID];
    }

}

- (void)doPopAnimationForView:(UIView *)viewToPop withBase:(CGFloat)size {

	[UIView animateWithDuration:0.1 animations:^{

    	[viewToPop setTransform:CGAffineTransformMakeScale(size - .1, size - .1)];

    } completion:^(BOOL finished){

    	[UIView animateWithDuration:0.1 animations:^{

    		[viewToPop setTransform:CGAffineTransformMakeScale(size + .05, size + .05)];

    	} completion:^(BOOL finished){

    		[UIView animateWithDuration:0.1 animations:^{

    			[viewToPop setTransform:CGAffineTransformMakeScale(size, size)];

    		}];

    	}];

    }];

}

- (void)unwindowApplicationWithBundleID:(NSString *)bundleID {
    
    //get window instance, if exists
    __block CDTLamoWindow *window;
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
		[window setHidden:YES];
        window = NULL;
        
        //remove value from dict
        [[(CDTLamoWindow *)[_windows valueForKey:bundleID] hostingCheckTimer] invalidate];
        [_windows removeObjectForKey:bundleID];

    }];

}

- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion {

	//get bundle id
	NSString *bundleID = [app valueForKey:@"_bundleIdentifier"];

    //close the window if its currently context hosted
	if ([_windows valueForKey:bundleID]) {
        
        [[(CDTLamoWindow *)[_windows valueForKey:bundleID] hostingCheckTimer] invalidate];
		[_contextHostProvider disableBackgroundingForApplication:app];
		[_contextHostProvider stopHostingForBundleID:bundleID];

		//get window so we can remove it
        CDTLamoWindow *window = [_windows valueForKey:bundleID];
		
        //restore statusbar
        [_contextHostProvider setStatusBarHidden:@([window statusBarHidden]) onApplicationWithBundleID:bundleID];

        //remove the view
		[window setHidden:YES];
        window = NULL;
        
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
    __block CDTLamoWindow *window;
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
            
            [[(CDTLamoWindow *)[_windows valueForKey:bundleID] hostingCheckTimer] invalidate];
			[_contextHostProvider disableBackgroundingForApplication:appToOpen];
			[_contextHostProvider stopHostingForBundleID:bundleID];

			//remove the view
            [UIView animateWithDuration:0.2f animations:^{
                
                [window setAlpha:0];
                
            } completion:^(BOOL finished) {
                
                [window setHidden:YES];
                window = NULL;
                
                //remove value from dict
                [_windows removeObjectForKey:bundleID];
                
            }];
			

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
        
        //this will also revert the 90 degree rotation
        [window setTransform:CGAffineTransformMakeScale([[CDTLamoSettings sharedSettings] defaultWindowSize], [[CDTLamoSettings sharedSettings] defaultWindowSize])];
        
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
    
    //dont snap the settings
    if ([[windowToSnap identifier] isEqualToString:@"com.cortexdevteam.lamosetting"]) {
        
        return;
    }
    
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
                
            case CDTLamoSnapTop: {
                
                NSString *windowChange = [NSString stringWithFormat:@"%@LamoWindowSize", [(CDTLamoWindow *)windowToSnap identifier]];
                
                CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)windowChange, NULL, (__bridge CFDictionaryRef) @{@"frame" : [NSValue valueWithCGRect:CGRectMake(0, 0, kScreenWidth, kScreenHeight * .5)] } , YES);
                
                [windowToSnap setTransform:CGAffineTransformMakeScale(1, 1)];
                //[windowToSnap setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight * .5)];
                
                break;
            }
                
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
    
    //stop if settings is on screen
    if ([self isShowingSettings]) {

        return YES;
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
    
    //create settings window
    CDTLamoWindow *settingsWindow = [[CDTLamoWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight + 20)];
    [settingsWindow setIdentifier:@"com.cortexdevteam.lamosetting"];
    [settingsWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
    
    //create settings view controller
    _settingsController = [[CDTLamoSettingsViewController alloc] init];
    _settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:_settingsController];
    [[_settingsNavigationController view] setFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight)];
    [_settingsController setTitle:@"Mírmir"];
    [settingsWindow addSubview:[_settingsNavigationController view]];
    
    //create the 'title bar' window that holds the gestures
    CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
    //[gestureView setTitle:@"Mímir Settings"];
    [gestureView setFrame:CGRectMake(0, 0, kScreenWidth, 20)];
    [settingsWindow addSubview:gestureView];
    
    //add it to dict
    [_windows setValue:settingsWindow forKey:@"com.cortexdevteam.lamosetting"];
    
    //animate it popping in
    [self doPopAnimationForView:settingsWindow withBase:1];

}

- (void)snapAllClose:(BOOL)animated {
    
    //cycle through all windows and close them
    for (NSString *bundleID in [_windows allKeys]) {
        
        __block CDTLamoWindow *window = [_windows objectForKey:bundleID];
        
        if (animated) {
            
            //fade them
            [UIView animateWithDuration:0.3 animations:^{
                
                [window setAlpha:0];
            } completion:^(BOOL finished) {
                
                //end hosting
                SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
                [_contextHostProvider disableBackgroundingForApplication:appToHost];
                [_contextHostProvider stopHostingForBundleID:bundleID];
                
                //switch it to portrait so it doesnt open in landscape
                [self triggerPortraitForApplication:appToHost];

                
                //remove the view
                [window setHidden:YES];
                window = NULL;
                
                //remove value from dict
                [_windows removeObjectForKey:bundleID];

            }];
        }
        else { //dont animate
            
            //end hosting
            SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
            [_contextHostProvider disableBackgroundingForApplication:appToHost];
            [_contextHostProvider stopHostingForBundleID:bundleID];
            
            //switch it to portrait so it doesnt open in landscape
            [self triggerPortraitForApplication:appToHost];

            
            //remove the view
            [window setHidden:YES];
            window = NULL;
            
            //remove value from dict
            [_windows removeObjectForKey:bundleID];

        }

    }
}

- (void)removeKeyFromDict:(NSString *)key {
    
    //remove from windows dict
    if ([_windows valueForKey:key]) {
        
        [_windows removeObjectForKey:key];
    }
}

- (UIWindow *)topmostApplicationWindow {
    
    //return the top application
    NSInteger windowLevel = 0;
    UIWindow *topWindow;
    for (UIWindow *window in [_windows allValues]) {
        
        if ([window windowLevel] > windowLevel) {
            
            topWindow = window;
            windowLevel = [window windowLevel];
        }
    }
                              
    return topWindow;
}

- (BOOL)isShowingSettings {
    
    //return if settings is on screen
    if ([[_settingsNavigationController viewControllers] count] > 0 && [[_settingsNavigationController view] superview]) {
        return YES;
    }
    
    return NO;
}

- (NSDictionary *)mutableWindowDict {
    
    return [_windows mutableCopy];
}

- (BOOL)SBHTMLInstalled {
    
    //see if we can create a sbhtml class
    dlopen("/Library/MobileSubstrate/DynamicLibraries/SBHTML.dylib", RTLD_LAZY);
    Class sbhtmlClass = NSClassFromString(@"SBHTMLWebView");
    
    //if it exists, we have sbhtml
    if (sbhtmlClass) {
        
        return YES;
    }
    
    return NO;
}

- (UIWindow *)fbRootWindow {
    
    if (!_auxWindow) {
        
        _auxWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [_auxWindow setBackgroundColor:[UIColor clearColor]];
        [_auxWindow setUserInteractionEnabled:NO];
    }
    
    return _auxWindow;
}

@end 