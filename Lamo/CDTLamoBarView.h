#import "Lamo.h"
#import "CDTLamo.h"
#import "CDTLamoWindow.h"
#import "CDTLamoPanGestureRecognizer.h"
#import "CDTLamoAppOverlay.h"

@interface CDTLamoBarView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, copy) void (^primedSnapAction)();
@property (nonatomic, retain) CDTLamoAppOverlay *overlayView;

@property CGPoint offset;
@property BOOL isPrimedForSnapping;

- (void)setTitle:(NSString *)title;
- (void)handleTap:(UITapGestureRecognizer *)gesture;
- (void)handlePan:(UIPanGestureRecognizer *)panGesture;
- (void)handleClose;
- (void)handleMin;
- (void)handleMax;
- (void)handleOrientation;

@end