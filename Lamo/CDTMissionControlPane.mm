#import "CDTMissionControlPane.h"

@implementation CDTMissionControlPane

- (id)initWithPaneNumber:(int)paneIndex {

	if (self = [super init]) {

		//our index
		_paneIndex = paneIndex;

		//imageview that holds pane content
		_paneImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth * .7, kScreenHeight * .7)];
		[self addSubview:_paneImage];

		[self setBackgroundColor:[UIColor clearColor]];

	}

	return self;
}

@end