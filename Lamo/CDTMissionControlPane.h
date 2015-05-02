#import "Lamo.h"

@interface CDTMissionControlPane : UIView

@property (nonatomic) int paneIndex;
@property (nonatomic, retain) UIImageView *paneImage;

- (id)initWithPaneNumber:(int)paneIndex;

@end