//
//  CDTLamoActivatorEventReorientate.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoActivatorEventReorientate.h"

@implementation CDTLamoActivatorEventReorientate

- (NSString *)activator:(id)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName {
    return @"Switch Orientation";
}

- (NSString *)activator:(id)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName {
    return @"Change the orientation of the current Mímir window";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName {
    return @"Mímir";
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    
    //get top window bar
    if ([[[CDTLamo sharedInstance] topmostApplicationWindow] respondsToSelector:@selector(identifier)]) {
        
        //get app
        SBApplication *app = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] identifier]];
        
        //trigger portrait opposite of current one
        if ([(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] activeOrientation] == (UIInterfaceOrientation *)UIInterfaceOrientationLandscapeLeft) {
            
            //in landscape, trigger portrait
            [(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationPortrait];
            [[CDTLamo sharedInstance] triggerPortraitForApplication:app];
            
            //lol this is ugly. transition overlay if its visible
            if ([(CDTLamoBarView *)[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] overlayView]) {
                
                CDTLamoAppOverlay *overlay = (CDTLamoAppOverlay *)[(CDTLamoBarView *)[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] overlayView];
                
                //animate buttons in overlay to new positions
                [UIView animateWithDuration:0.4f animations:^{
                
                    [overlay transitionToPortrait];
                }];
            }
        }
        
        else {
            
            //in portrait, trigger landscape
            [(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] setActiveOrientation:(UIInterfaceOrientation *)UIInterfaceOrientationLandscapeLeft];
            [[CDTLamo sharedInstance] triggerLandscapeForApplication:app];
            
            //lol this is ugly. transition overlay if its visible
            if ([(CDTLamoBarView *)[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] overlayView]) {
                
                CDTLamoAppOverlay *overlay = (CDTLamoAppOverlay *)[(CDTLamoBarView *)[(CDTLamoWindow *)[[CDTLamo sharedInstance] topmostApplicationWindow] barView] overlayView];
                
                //animate buttons in overlay to new positions
                [UIView animateWithDuration:0.4f animations:^{
                    
                    [overlay transitionToLandscape];
                }];
            
            }
        }
    }
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
    NSLog(@"abort event");
}

@end
