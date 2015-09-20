#import "Lamo.h"
#import "CDTLamoSettingsViewController.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoBarView.h"
#import "CDTLamoWindow.h"
#import "CDTLamoSettings.h"
#import <dlfcn.h>

@interface CDTLamo : NSObject

@property (nonatomic, retain) UIView *sharedScalingWrapperView;
@property (nonatomic, retain) CDTContextHostProvider *contextHostProvider;

//these just need to be retained
@property (nonatomic, retain) UIViewController *settingsController;
@property (nonatomic, retain) UINavigationController *settingsNavigationController;
@property (nonatomic, retain) UIViewController *tutorialController;
@property (nonatomic, retain) UINavigationController *tutorialNavigationController;

@property (nonatomic, retain) NSMutableDictionary *windows;
@property (nonatomic, retain) UIWindow *springboardWindow;

@property BOOL wrapperViewIsTracking;

+ (id)sharedInstance;
- (void)beginShowingHomescreen;
- (void)updateWrapperView;
- (void)seamlesslyCloseTopApp;
- (void)addTopBarToWrapperWindow;
- (void)beginWindowModeForTopApplication;
- (void)beginWindowModeForApplicationWithBundleID:(NSString *)bundleID;
- (void)doPopAnimationForView:(UIView *)viewToPop withBase:(CGFloat)size;
- (void)unwindowApplicationWithBundleID:(NSString *)bundleID;
- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion;
- (void)launchFullModeFromWindowForApplication:(SBApplication *)appToOpen;
- (void)triggerLandscapeForApplication:(SBApplication *)application;
- (void)triggerPortraitForApplication:(SBApplication *)application;
- (id)topmostApplication;
- (void)addView:(UIView *)view toDictWithIdentifier:(NSString *)bundleID;
- (void)primeApplicationForSnapping:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (void)snapApplication:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (BOOL)shouldBlockNotificationCenter;
- (void)presentSettingsController;
- (void)snapAllClose:(BOOL)animated;
- (void)removeKeyFromDict:(NSString *)key;
- (UIView *)topmostApplicationWindow;
- (BOOL)isShowingSettings;
- (NSDictionary *)mutableWindowDict;
- (BOOL)SBHTMLInstalled;
- (BOOL)didSucceedInForceTouchLaunchAtLocation:(CGPoint)touch;

@end