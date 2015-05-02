#import "Lamo.h"
#import "CDTMissionControlPane.h"

@interface CDTMissionControl : UIView

@property (nonatomic, retain) NSMutableArray *activePanes;
@property (nonatomic, retain) UIScrollView *paneScrollView;

+ (id)sharedInstance;
- (void)updateSnapshotOfHomescreen;

@end