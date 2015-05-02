#import "Lamo.h"
#import "CDTContextHostProvider.h"
#import "CDTLamoBarView.h"

@interface CDTLamo : NSObject

@property (nonatomic, retain) UIView *sharedScalingWrapperView;
@property (nonatomic, retain) CDTContextHostProvider *contextHostProvider;
@property (nonatomic, retain) NSMutableArray *hostedApplications;
@property (nonatomic, retain) NSMutableArray *hostedContextViews;
@property (nonatomic, retain) UIWindow *springboardWindow;

@property CGPoint offset;
@property CGFloat lastScale;
@property BOOL wrapperViewIsTracking;

+ (id)sharedInstance;

- (void)beginShowingHomescreen;
- (void)updateWrapperView;
- (void)seamlesslyCloseTopApp;
- (void)addTopBarToWrapperWindow;
- (void)beginWindowModeForTopApplication;
- (void)doPopAnimationForView:(UIView *)viewToPop;
- (void)unwindowApplicationAtIndex:(int)indexOfApp;
- (void)appWantsToOpen:(SBApplication *)app withBlock:(void(^)(void))completion;
- (void)launchFullModeFromWindowForApplication:(SBApplication *)appToOpen;
- (void)triggerLandscapeForApplication:(SBApplication *)application;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;

- (id)topmostApplication;

@end