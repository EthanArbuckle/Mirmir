#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define kScreenHeight 			[[UIScreen mainScreen] bounds].size.height
#define kScreenWidth 			[[UIScreen mainScreen] bounds].size.width

#ifdef __cplusplus
extern "C" {
#endif

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

#ifdef __cplusplus
}
#endif

//snapping postitions
typedef enum CDTLamoSnapPosition {
    CDTLamoSnapLeft = 0,
    CDTLamoSnapRight,
    CDTLamoSnapTopLeft,
    CDTLamoSnapTopRight,
    CDTLamoSnapBottomLeft,
    CDTLamoSnapBottomRight,
    CDTLamoSnapTop,
    CDTLamoSnapBottom
 } CDTLamoSnapPosition;

@interface SBApplicationController
+ (id)sharedInstance;
- (id)applicationWithBundleIdentifier:(NSString *)bid;
@end

@interface SBUIController : NSObject
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
- (void)activateApplicationAnimated:(id)application;
@end

@interface FBWorkspaceEvent : NSObject
+ (instancetype)eventWithName:(NSString *)label handler:(id)handler;
@end

@interface SBAppToAppWorkspaceTransaction
- (void)begin;
- (id)initWithAlertManager:(id)alertManager exitedApp:(id)app;
- (id)initWithAlertManager:(id)arg1 from:(id)arg2 to:(id)arg3 withResult:(id)arg4;
@end

@interface FBWorkspaceEventQueue : NSObject
+ (instancetype)sharedInstance;
- (void)executeOrAppendEvent:(FBWorkspaceEvent *)event;
@end

@interface SBDeactivationSettings
-(id)init;
-(void)setFlag:(int)flag forDeactivationSetting:(unsigned)deactivationSetting;
@end

@interface SBWallpaperController
-(id)sharedInstance;
- (void)beginRequiringWithReason:(id)reason;
@end

@interface UIApplication (Private) 
- (void)_relaunchSpringBoardNow;
- (id)_accessibilityFrontMostApplication;
- (void)launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
- (id)displayIdentifier;
- (void)setStatusBarHidden:(bool)arg1 animated:(bool)arg2;
void receivedStatusBarChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void receivedLandscapeRotate();
void receivedPortraitRotate();
@end

@interface UIWindow (Private)
- (void)_setRotatableViewOrientation:(int)arg1 updateStatusBar:(BOOL)arg2 duration:(double)arg3 force:(BOOL)arg4;
@end

@interface SBApplication : NSObject
@property(copy) NSString* displayIdentifier;
@property(copy) NSString* bundleIdentifier;
@property(copy, nonatomic, setter=_setDeactivationSettings:) SBDeactivationSettings *_deactivationSettings;
- (id)valueForKey:(id)arg1;
- (NSString *)displayName;
- (int)pid;
- (id)mainScene;
- (NSString *)path;
//- (id)mainScreenContextHostManager;
- (void)setDeactivationSetting:(unsigned int)setting value:(id)value;
- (void)setDeactivationSetting:(unsigned int)setting flag:(BOOL)flag;
- (id)bundleIdentifier;
- (id)displayIdentifier;
- (void)notifyResignActiveForReason:(int)reason;
- (void)notifyResumeActiveForReason:(int)reason;
- (void)activate;
- (void)setFlag:(long long)arg1 forActivationSetting:(unsigned int)arg2;
- (BOOL)statusBarHidden;
@end

@interface FBScene
- (id)contextHostManager;
- (id)mutableSettings;
-(void)_applyMutableSettings:(id)arg1 withTransitionContext:(id)arg2 completion:(id)arg3;
@end

@interface FBWindowContextHostManager : NSObject
- (void)enableHostingForRequester:(id)arg1 orderFront:(BOOL)arg2;
- (void)enableHostingForRequester:(id)arg1 priority:(int)arg2;
- (void)disableHostingForRequester:(id)arg1;
- (id)hostViewForRequester:(id)arg1 enableAndOrderFront:(BOOL)arg2;
@end

@interface FBSMutableSceneSettings
- (void)setBackgrounded:(bool)arg1;
@end

@interface SBAppSwitcherModel : NSObject
- (void)addToFront:(id)arg1;
- (id)snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary;
@end

@interface SBDisplayLayout : NSObject
+ (id)fullScreenDisplayLayoutForApplication:(id)arg1;
@end

@interface SBAppSwitcherController : NSObject
@end

@interface _UIBackdropView : UIView
- (id)initWithStyle:(int)arg1;
@end

@interface SBViewSnapshotProvider

@property(copy, nonatomic) id completionBlock;
-(UIImage *)snapshot;
-(void)snapshotAsynchronously:(BOOL)asynchronously withImageBlock:(id)imageBlock;
-(id)initWithView:(id)view;
@end

@interface SBHomeScreenPreviewView : UIView
+ (void)cleanupPreview;
+ (id)preview;
@end

@interface UIKeyboard
+ (id)activeKeyboard;
@end

@interface SBLaunchAppListener : NSObject
- (id)initWithBundleIdentifier:(id)arg1 handlerBlock:(id)arg2;
@end
