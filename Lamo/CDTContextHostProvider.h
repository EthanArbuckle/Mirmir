#import "Lamo.h"
#import "CDTLamoSettings.h"

#define NEED_IPAD_HAX UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface CDTContextHostProvider : NSObject

@property (nonatomic, retain) NSMutableArray *onlyIpad_runningIdentifiers;

- (UIView *)hostViewForApplication:(id)sbapplication;
- (UIView *)hostViewForApplicationWithBundleID:(NSString *)bundleID;

- (void)launchSuspendedApplicationWithBundleID:(NSString *)bundleID;

- (void)disableBackgroundingForApplication:(id)sbapplication;
- (void)enableBackgroundingForApplication:(id)sbapplication;

- (FBScene *)FBSceneForApplication:(id)sbapplication;
- (FBWindowContextHostManager *)contextManagerForApplication:(id)sbapplication;
- (FBSMutableSceneSettings *)sceneSettingsForApplication:(id)sbapplication;

- (BOOL)isHostViewHosting:(UIView *)hostView;
- (void)forceRehostingOnBundleID:(NSString *)bundleID;

- (void)stopHostingForBundleID:(NSString *)bundleID;
//- (void)startHostingForBundleID:(NSString *)bundleID;

- (void)_ipad_only_update_hosting;

- (void)sendLandscapeRotationNotificationToBundleID:(NSString *)bundleID;
- (void)sendPortraitRotationNotificationToBundleID:(NSString *)bundleID;
- (void)setStatusBarHidden:(NSNumber *)hidden onApplicationWithBundleID:(NSString *)bundleID;

@end