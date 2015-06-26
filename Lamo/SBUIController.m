#import "Lamo.h"
#import "CDTLamo.h"
#import "CDTMissionControl.h"
#import "ZKSwizzle.h"
#import "CDTLamoSettings.h"

ZKSwizzleInterface($_Lamo_SBUIController, SBUIController, NSObject);

@implementation $_Lamo_SBUIController

- (void)_showNotificationsGestureBeganWithLocation:(CGPoint)location {

    if (location.x <= 100 && [[UIApplication sharedApplication] _accessibilityFrontMostApplication] && [[CDTLamoSettings sharedSettings] isEnabled]) {

		//we've started tracking the wrapper view
		[[CDTLamo sharedInstance] setWrapperViewIsTracking:YES];

		//create wrapper view
		[[CDTLamo sharedInstance] updateWrapperView];

		//add bar to scaling wrapper view
		[[CDTLamo sharedInstance] addTopBarToWrapperWindow];

		//make sure homescreen is visible in background
		[[CDTLamo sharedInstance] beginShowingHomescreen];
		
		return;
	}
    
    //getting pissed off at notification center stealing my window pans
    if ([[CDTLamo sharedInstance] shouldBlockNotificationCenter]) {
        
        [self _showNotificationsGestureCancelled];
        return;
    }
    
	ZKOrig(void, location);

}

- (void)_showNotificationsGestureCancelled {
    ZKOrig(void);
}

- (void)_showNotificationsGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity {
    
    //stop our touches from getting jacked
    if ([[CDTLamo sharedInstance] shouldBlockNotificationCenter]) {
        
        [self _showNotificationsGestureCancelled];
        return;
    }
    
    //if we're tracking
	if ([[CDTLamo sharedInstance] wrapperViewIsTracking] && [[CDTLamo sharedInstance] sharedScalingWrapperView] && location.y <= 100 && [[CDTLamoSettings sharedSettings] isEnabled]) {

		//100 point tracking zone, with min final transform being .6
		CGFloat base = .4 / 100;
		CGFloat offset = base * location.y;

		//update wrapper view transform
		[[[CDTLamo sharedInstance] sharedScalingWrapperView] setTransform:CGAffineTransformMakeScale(1 - offset, 1 - offset)];

		return;
	}

    ZKOrig(void, location, velocity);

}

- (void)_showNotificationsGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity {

    //stop our touches from getting jacked
    if ([[CDTLamo sharedInstance] shouldBlockNotificationCenter]) {
        
        [self _showNotificationsGestureCancelled];
        return;
    }
    
    //touch ended and we were tracking
	if ([[CDTLamo sharedInstance] wrapperViewIsTracking] && [[CDTLamo sharedInstance] sharedScalingWrapperView] && [[CDTLamoSettings sharedSettings] isEnabled]) {

		//stop tracking
		[[CDTLamo sharedInstance] setWrapperViewIsTracking:NO];

		//if we need to window the app
		if (location.y >= 80) {

			//start window mode for app
			[[CDTLamo sharedInstance] beginWindowModeForTopApplication];

		}

		//or restore it to normal
		else {

			[UIView animateWithDuration:0.3 animations:^{

				[[[CDTLamo sharedInstance] sharedScalingWrapperView] setTransform:CGAffineTransformIdentity];

			}];

		}

		//nil out wrapper view
		[[CDTLamo sharedInstance] setSharedScalingWrapperView:nil];

		return;
	}

	ZKOrig(void, location, velocity);

}

- (void)activateApplicationAnimated:(id)animated {

    //an app is opening, make sure it close its window
    [[CDTLamo sharedInstance] appWantsToOpen:animated withBlock:^{
		ZKOrig(void, animated);
    }];

}

- (void)finishLaunching {
    
    ZKOrig(void);

    //create settings icon on homescreen
    SBLeafIcon *lamoSettings = [[NSClassFromString(@"SBLeafIcon") alloc] initWithLeafIdentifier:@"lamo" applicationBundleID:nil];
    SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
    SBIconModel *iconModel = [iconController valueForKey:@"_iconModel"];
    [iconModel addIcon:lamoSettings];
    [iconController addNewIconToDesignatedLocation:lamoSettings animate:NO scrollToList:NO saveIconState:YES];
 
}

- (void)_deviceLockStateChanged:(id)changed {
    
    //close all windows and stop hosting
    [[CDTLamo sharedInstance] snapAllClose];
    
}

@end