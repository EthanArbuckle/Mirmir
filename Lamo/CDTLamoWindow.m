//
//  CDTLamoWindow.m
//  Lamo
//
//  Created by Ethan Arbuckle on 5/6/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoWindow.h"

@implementation CDTLamoWindow

//FrontBoard assumed this is a FBWindow, a UIWindow subclass. Lets let it keep thinking that and
//not crash out randomly on us
- (float)level {

    return 99999;
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
                
        [self makeKeyAndVisible];
        
        //setup host provider
        _contextProvider = [[CDTContextHostProvider alloc] init];
        
        //setup timer to keep this view hosted if it loses it
        _hostingCheckTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(runHostingCheck) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_hostingCheckTimer forMode:NSRunLoopCommonModes];

    }
    
    return self;
}

- (void)runHostingCheck {

    //force hosting if its disabled
    if (_hostedContextView && ![_contextProvider isHostViewHosting:_hostedContextView] && [self superview]) {
        
        NSLog(@"Mimir Window \"%@\" lost hosting... reenabling", _identifier);
        [_hostedContextView removeFromSuperview];
        CGRect frame = [_hostedContextView frame];
        _hostedContextView = [_contextProvider hostViewForApplicationWithBundleID:_identifier];
        [_hostedContextView setFrame:frame];
        [self addSubview:_hostedContextView];
    }
}

@end
