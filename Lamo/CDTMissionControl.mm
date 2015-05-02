#import "CDTMissionControl.h"

@implementation CDTMissionControl

+ (id)sharedInstance {

	static dispatch_once_t p = 0;
	__strong static id _sharedObject = nil;
	 
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});

	return _sharedObject;
}

- (id)init {

	if (self = [super init]) {

		//set frame to full screen
		[self setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];

		//we want touches to be passed to us
		[self setUserInteractionEnabled:YES];

		//create blur
		[self setBackgroundColor:[UIColor clearColor]];
		_UIBackdropView *blurBack = [[_UIBackdropView alloc] initWithStyle:2];

		//create dark blur mask
		UIView *blurMask = [[UIView alloc] initWithFrame:[self frame]];
		[blurMask setBackgroundColor:[UIColor blackColor]];
		[blurMask setAlpha:.3];

		[blurBack addSubview:blurMask];
		[self addSubview:blurBack];

		//create pane array
		_activePanes = [[NSMutableArray alloc] initWithCapacity:4];

		//create scrollview
		_paneScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 50)];
		[_paneScrollView setScrollEnabled:YES];
		[_paneScrollView setPagingEnabled:NO];
		[_paneScrollView setShowsHorizontalScrollIndicator:NO];
		[self addSubview:_paneScrollView];

		CGFloat paneSpacingDistance = 40;
		CGFloat xOrigin = paneSpacingDistance;

		//calc y origin to use (put panes in middle of scrollview)
		CGFloat yOrigin = ((kScreenHeight - 50) - (kScreenHeight * .7)) / 2;

		//create our 4 panes
		for (int paneIndex = 0; paneIndex < 4; paneIndex++) {

			//make pane with index
			CDTMissionControlPane *currentPane = [[CDTMissionControlPane alloc] initWithPaneNumber:paneIndex];

			//set pane frame
			[currentPane setFrame:CGRectMake(xOrigin, yOrigin, kScreenWidth * .7, kScreenHeight * .7)];

			//step up x origin (gap + pane width)
			xOrigin += paneSpacingDistance + (kScreenWidth * .7);

			//add it to array
			[_activePanes addObject:currentPane];

			//add it to scrollview
			[_paneScrollView addSubview:currentPane];

		}

		[self updateSnapshotOfHomescreen];

		//calculate content size (4 panes and 5 gaps)
		[_paneScrollView setContentSize:CGSizeMake(((kScreenWidth * .7) * 4) + (paneSpacingDistance * 5), kScreenHeight - 50)];

	}

	return self;

}

- (void)updateSnapshotOfHomescreen {

	//get homescreen snapshot
	SBViewSnapshotProvider *provider = [[NSClassFromString(@"SBViewSnapshotProvider") alloc] initWithView:[NSClassFromString(@"SBHomeScreenPreviewView") preview]];
	[provider snapshotAsynchronously:YES withImageBlock:^void(id snapshot) {
		
		//add it to all panes
		for (CDTMissionControlPane *pane in _activePanes) {

			//set image
			[[pane paneImage] setImage:snapshot];
		}

	}];

}

@end