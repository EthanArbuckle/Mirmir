//
//  CDTLamoWindow.h
//  Lamo
//
//  Created by Ethan Arbuckle on 5/6/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDTLamoBarView.h"
#import "CDTContextHostProvider.h"

@interface CDTLamoWindow : UIWindow

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) UIView *barView;
@property (nonatomic, retain) UIView *hostedContextView;
@property (nonatomic, retain) NSTimer *hostingCheckTimer;
@property (nonatomic, retain) CDTContextHostProvider *contextProvider;

@property UIInterfaceOrientation *activeOrientation;
@property BOOL statusBarHidden;

- (float)level;
- (void)runHostingCheck;

@end
