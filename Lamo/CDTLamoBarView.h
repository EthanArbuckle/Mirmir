#import "Lamo.h"
#import "CDTLamo.h"
#import "CDTLamoWindow.h"
#import "CDTLamoPanGestureRecognizer.h"
#import "CDTLamoAppOverlay.h"
#import "CDTLamoSettings.h"

@interface CDTLamoBarView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, copy) void (^primedSnapAction)();
@property (nonatomic, retain) UIView *overlayView;

@property CGPoint offset;
@property BOOL isPrimedForSnapping;

- (void)setTitle:(NSString *)title;
- (void)handleTap:(UITapGestureRecognizer *)gesture;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;

@end