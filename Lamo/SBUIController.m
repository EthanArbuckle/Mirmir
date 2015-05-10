#import "Lamo.h"
#import "CDTLamo.h"
#import "CDTMissionControl.h"
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBUIController, SBUIController, NSObject);

@implementation $_Lamo_SBUIController

- (void)_showNotificationsGestureBeganWithLocation:(CGPoint)location {

	if (location.x <= 100 && [[UIApplication sharedApplication] _accessibilityFrontMostApplication]) {

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

	ZKOrig(void, location);

}

- (void)_showNotificationsGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity {

	//if we're tracking
	if ([[CDTLamo sharedInstance] wrapperViewIsTracking] && [[CDTLamo sharedInstance] sharedScalingWrapperView] && location.y <= 100) {

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
	
	//touch ended and we were tracking
	if ([[CDTLamo sharedInstance] wrapperViewIsTracking] && [[CDTLamo sharedInstance] sharedScalingWrapperView]) {

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

- (BOOL)_activateAppSwitcher {

	//add our mission control
	//[[[UIApplication sharedApplication] keyWindow] addSubview:[CDTMissionControl sharedInstance]];

    return ZKOrig(BOOL);// YES;
}

@end