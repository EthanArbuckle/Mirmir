#import "CDTContextHostProvider.h"
#import "Lamo.h"

@implementation CDTContextHostProvider

- (id)init {

	if (self = [super init]) {
        
        //On ipads >8.3, context host views stop hosting when another context begins hosting.
        //To get around this, everytime we begin hosting a new context we'll cycle through all
        //the other ones and force them to host as well.
        if (NEED_IPAD_HAX) {
            _onlyIpad_runningIdentifiers = [[NSMutableArray alloc] init];
        }
        
	}

	return self;
}

- (UIView *)hostViewForApplication:(id)sbapplication {	

	//open it
	[self launchSuspendedApplicationWithBundleID:[(SBApplication *)sbapplication bundleIdentifier]];
    
    //add current identifier
    if (NEED_IPAD_HAX) {
        
        if (![_onlyIpad_runningIdentifiers containsObject:[(SBApplication *)sbapplication bundleIdentifier]]) {

            [_onlyIpad_runningIdentifiers addObject:[(SBApplication *)sbapplication bundleIdentifier]];
        }
    }
    
	//let the app run in the background
	[self enableBackgroundingForApplication:sbapplication];

	//allow hosting of our new hostview
	[[self contextManagerForApplication:sbapplication] enableHostingForRequester:[(SBApplication *)sbapplication bundleIdentifier] orderFront:YES];

	//get our fancy new hosting view
	UIView *hostView = [[self contextManagerForApplication:sbapplication] hostViewForRequester:[(SBApplication *)sbapplication bundleIdentifier] enableAndOrderFront:YES];

    //now that new host is created, cycle through all other ones (including new) and reenable hosting for ipads.
    if (NEED_IPAD_HAX) {
        
        [self _ipad_only_update_hosting];
    }

	return hostView;
}

- (UIView *)hostViewForApplicationWithBundleID:(NSString *)bundleID {

	//get application reference
	SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

	//return hostview
	return [self hostViewForApplication:appToHost];
}

- (void)launchSuspendedApplicationWithBundleID:(NSString *)bundleID {
	[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleID suspended:YES];
}

- (void)disableBackgroundingForApplication:(id)sbapplication {

	//get scene settings
	FBSMutableSceneSettings *sceneSettings = [self sceneSettingsForApplication:sbapplication];

	//force backgrounding to YES
	[sceneSettings setBackgrounded:YES];

	//reapply new settings to scene
	[[self FBSceneForApplication:sbapplication] _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];

}

- (void)enableBackgroundingForApplication:(id)sbapplication {

	//get scene settings
	FBSMutableSceneSettings *sceneSettings = [self sceneSettingsForApplication:sbapplication];

	//force backgrounding to NO
	[sceneSettings setBackgrounded:NO];

	//reapply new settings to scene
	[[self FBSceneForApplication:sbapplication] _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];

}

- (FBScene *)FBSceneForApplication:(id)sbapplication {

    return [(SBApplication *)sbapplication mainScene];
}

- (FBWindowContextHostManager *)contextManagerForApplication:(id)sbapplication {

    return [[self FBSceneForApplication:sbapplication] contextHostManager];
}

- (FBSMutableSceneSettings *)sceneSettingsForApplication:(id)sbapplication {
	return [[[self FBSceneForApplication:sbapplication] mutableSettings] mutableCopy];
}

- (BOOL)isHostViewHosting:(UIView *)hostView {
    if (hostView && [[hostView subviews] count] >= 1)
        return [(FBWindowContextHostView *)[hostView subviews][0] isHosting];
    return NO;
}

- (void)forceRehostingOnBundleID:(NSString *)bundleID {

    SBApplication *appToForce = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
    [self launchSuspendedApplicationWithBundleID:bundleID];
    [self enableBackgroundingForApplication:appToForce];
    FBWindowContextHostManager *manager = [self contextManagerForApplication:appToForce];
    [manager enableHostingForRequester:bundleID priority:1];
}

- (void)stopHostingForBundleID:(NSString *)bundleID {

	SBApplication *appToHost = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];
    [self disableBackgroundingForApplication:appToHost];
    FBWindowContextHostManager *contextManager = [self contextManagerForApplication:appToHost];
	[contextManager disableHostingForRequester:bundleID];

    if (NEED_IPAD_HAX) {
        
        if ([_onlyIpad_runningIdentifiers containsObject:bundleID]) {
            
            [_onlyIpad_runningIdentifiers removeObject:bundleID];
        }
    }
    
}

- (void)_ipad_only_update_hosting {
    
    for (NSString *_ipad_app_bundleid in _onlyIpad_runningIdentifiers) {
        
        SBApplication *_ipad_application = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:_ipad_app_bundleid];
        FBWindowContextHostManager *_ipad_context_manager = [self contextManagerForApplication:_ipad_application];
        [_ipad_context_manager enableHostingForRequester:_ipad_app_bundleid priority:1];
    }
    
}

- (void)sendLandscapeRotationNotificationToBundleID:(NSString *)bundleID {

	//notification is "identifierLamoRotate"
	NSString *rotateNotification = [NSString stringWithFormat:@"%@LamoLandscapeRotate", bundleID];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)rotateNotification, NULL, NULL, YES);
}

- (void)sendPortraitRotationNotificationToBundleID:(NSString *)bundleID {

	//notification is "identifierLamoRotate"
	NSString *rotateNotification = [NSString stringWithFormat:@"%@LamoPortraitRotate", bundleID];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)rotateNotification, NULL, NULL, YES);
}

- (void)setStatusBarHidden:(NSNumber *)hidden onApplicationWithBundleID:(NSString *)bundleID {
	
    //respect user settings
    if ([[CDTLamoSettings sharedSettings] hideStatusBar]) {
        
        NSString *changeStatusBarNotification = [NSString stringWithFormat:@"%@LamoStatusBarChange", bundleID];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)changeStatusBarNotification, NULL, (__bridge CFDictionaryRef) @{@"isHidden" : hidden } , YES);
    }

}

@end