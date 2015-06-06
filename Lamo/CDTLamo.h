#import "Lamo.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoBarView.h"
#import "CDTLamoWindow.h"
#import "CDTLamoSettings.h"

@interface CDTLamo : NSObject

@property (nonatomic, retain) UIView *sharedScalingWrapperView;
@property (nonatomic, retain) CDTContextHostProvider *contextHostProvider;
@property (nonatomic, retain) NSMutableDictionary *windows;
@property (nonatomic, retain) UIWindow *springboardWindow;
@property (nonatomic, copy) void (^primedSnapAction)();
@property (nonatomic, retain) NSTimer *longPress_timer;

@property CGPoint offset;
@property CGFloat lastScale;
@property BOOL wrapperViewIsTracking;
@property BOOL isPrimedForSnapping;
@property BOOL longPress_isPressed;

+ (id)sharedInstance;
- (void)beginShowingHomescreen;
- (void)updateWrapperView;
- (void)seamlesslyCloseTopApp;
- (void)addTopBarToWrapperWindow;
- (void)beginWindowModeForTopApplication;
- (void)doPopAnimationForView:(UIView *)viewToPop;
- (void)unwindowApplicationWithBundleID:(NSString *)bundleID;
- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion;
- (void)launchFullModeFromWindowForApplication:(SBApplication *)appToOpen;
- (void)triggerLandscapeForApplication:(SBApplication *)application;
- (void)triggerPortraitForApplication:(SBApplication *)application;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;
- (void)longPress_beginTimer;
- (void)longPress_timerFired;
- (void)longPress_panWithGesture:(UIPanGestureRecognizer *)panGesture;
- (id)topmostApplication;
- (void)addView:(UIView *)view toDictWithIdentifier:(NSString *)bundleID;
- (void)primeApplicationForSnapping:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (void)snapApplication:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (BOOL)shouldBlockNotificationCenter;

@end