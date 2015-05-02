#import "Lamo.h"

@interface CDTContextHostProvider : NSObject

- (UIView *)hostViewForApplication:(id)sbapplication;
- (UIView *)hostViewForApplicationWithBundleID:(NSString *)bundleID;

- (void)launchSuspendedApplicationWithBundleID:(NSString *)bundleID;

- (void)disableBackgroundingForApplication:(id)sbapplication;
- (void)enableBackgroundingForApplication:(id)sbapplication;

- (FBScene *)FBSceneForApplication:(id)sbapplication;
- (FBWindowContextHostManager *)contextManagerForApplication:(id)sbapplication;
- (FBSMutableSceneSettings *)sceneSettingsForApplication:(id)sbapplication;

//- (BOOL)isHostViewHosting:(UIView *)hostView;

- (void)stopHostingForBundleID:(NSString *)bundleID;
//- (void)startHostingForBundleID:(NSString *)bundleID;

- (void)sendLandscapeRotationNotificationToBundleID:(NSString *)bundleID;
- (void)sendPortraitRotationNotificationToBundleID:(NSString *)bundleID;
- (void)setStatusBarHidden:(NSNumber *)hidden onApplicationWithBundleID:(NSString *)bundleID;
@end