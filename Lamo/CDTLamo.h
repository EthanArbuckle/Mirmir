#import "Lamo.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoBarView.h"
#import "CDTLamoWindow.h"

@interface CDTLamo : NSObject

@property (nonatomic, retain) UIView *sharedScalingWrapperView;
@property (nonatomic, retain) CDTContextHostProvider *contextHostProvider;
@property (nonatomic, retain) NSMutableDictionary *windows;
@property (nonatomic, retain) UIWindow *springboardWindow;
@property (nonatomic, copy) void (^primedSnapAction)();

@property CGPoint offset;
@property CGFloat lastScale;
@property BOOL wrapperViewIsTracking;
@property BOOL isPrimedForSnapping;

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
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;
- (id)topmostApplication;
- (void)addView:(UIView *)view toDictWithIdentifier:(NSString *)bundleID;
- (void)primeApplicationForSnapping:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (void)snapApplication:(NSString *)identifier toPosition:(CDTLamoSnapPosition)position;
- (BOOL)shouldBlockNotificationCenter;

@end