//
//  CDTLamoStateManager.m
//  Lamo
//
//  Created by Ethan Arbuckle on 5/17/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoStateManager.h"

@implementation CDTLamoStateManager

+ (void)saveWindowStatesFromDictionary:(NSDictionary *)dictionary andRemove:(BOOL)remove {
    
    NSMutableDictionary *dictToFile = [[NSMutableDictionary alloc] init];
    
    //cycle idents
    for (NSString *identifier in [dictionary allKeys]) {
        
        NSMutableDictionary *currentWindow = [[NSMutableDictionary alloc] init];
        [currentWindow setValue:identifier forKey:@"bundleID"];
        
        //fuck these orientations not being able to go straight into a dict
        UIInterfaceOrientation *orientation = [(CDTLamoWindow *)[dictionary valueForKey:identifier] activeOrientation];
        if (orientation == (UIInterfaceOrientation *)UIInterfaceOrientationPortrait) {
            
            [currentWindow setValue:@"portrait" forKey:@"orientation"];
        }
        else {
            
            [currentWindow setValue:@"landscape" forKey:@"orientation"];
        }
        
        [currentWindow setValue:[NSValue valueWithCGRect:[(CDTLamoWindow *)[dictionary valueForKey:identifier] frame]] forKey:@"frame"];
        
        [currentWindow setValue:NSStringFromCGAffineTransform([(CDTLamoWindow *)[dictionary valueForKey:identifier] transform]) forKey:@"transform"];
        
        [dictToFile setValue:currentWindow forKey:identifier];
        
        //remove the view if needed
        if (remove) {
            
            [(CDTLamoWindow *)[dictionary valueForKey:identifier] removeFromSuperview];
        }
        
    }
    
    NSString *writePath;
    
#if TARGET_IPHONE_SIMULATOR
    writePath = @"/Users/ethanarbuckle/Desktop/LAMO_DYLIB/lamoWindows.plist";
#else
    writepath = @"/Library/Application Support/Lamo/lamoWindows.plist";
#endif
    
    [NSKeyedArchiver archiveRootObject:dictToFile toFile:writePath];
    
}

+ (void)restoreWindowsOntoView:(UIView *)view {
    
    NSString *writePath;
    
#if TARGET_IPHONE_SIMULATOR
    writePath = @"/Users/ethanarbuckle/Desktop/LAMO_DYLIB/lamoWindows.plist";
#else
    writepath = @"/Library/Application Support/Lamo/lamoWindows.plist";
#endif
    
    //get saved states
    NSDictionary *savedStates = [NSKeyedUnarchiver unarchiveObjectWithFile:writePath];
    
    //create context host provider
    CDTContextHostProvider *contextProvider = [[CDTContextHostProvider alloc] init];
    
    for (NSString *identifier in [savedStates allKeys]) {
        
        CGRect frame = [[[savedStates valueForKey:identifier] valueForKey:@"frame"] CGRectValue];
        
        //get host view for identifier
        UIView *contextHost = [contextProvider hostViewForApplicationWithBundleID:identifier];
        
        //create container view
        CDTLamoWindow *appWindow = [[CDTLamoWindow alloc] initWithFrame:frame];
        
        [appWindow setIdentifier:identifier];
        [appWindow setStatusBarHidden:YES];
        
        //naivly assume portrait for the time being
        if ([[[savedStates valueForKey:identifier] valueForKey:@"orientation"] isEqualToString:@"portrait"]) {
            [appWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
        }
        else {
            [appWindow setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationMaskLandscapeLeft];
            [[CDTLamo sharedInstance] sendLandscapeRotationNotificationToBundleID:identifier];
        }
        
        //add host to window
        [appWindow addSubview:contextHost];
        
        //hide statusbar
        [contextProvider setStatusBarHidden:@(1) onApplicationWithBundleID:identifier];
        
        //shrink it down and update frame
        [appWindow setTransform:CGAffineTransformFromString([[savedStates valueForKey:identifier] valueForKey:@"transform"])];
        [contextHost setFrame:CGRectMake(0, 40, contextHost.frame.size.width, contextHost.frame.size.height)];
        
        //create the 'title bar' window that holds the gestures
        CDTLamoBarView *gestureView = [[CDTLamoBarView alloc] init];
        [appWindow addSubview:gestureView];
        
        if (view) {
            
            [view addSubview:appWindow];
        }
        
        //add to dict
        [[CDTLamo sharedInstance] addView:appWindow toDictWithIdentifier:identifier];
        
    }
}

@end
