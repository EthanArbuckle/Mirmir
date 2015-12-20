//
//  SBMainSwitcherViewController.m
//  Lamo
//
//  Created by Ethan Arbuckle
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "Lamo.h"
#import "CDTLamo.h"
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBMainSwitcherViewController, SBMainSwitcherViewController, NSObject);

@implementation $_Lamo_SBMainSwitcherViewController

- (void)switcherContentController:(id)arg1 selectedItem:(id)arg2 {
    
    //get app ident of tapped snapshot
    NSString *identifier = [arg2 valueForKey:@"_displayIdentifier"];
    
    //get application instance
    SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identifier];
    
    //send msg to cdtlamo
    [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
        
        //continue as normal
        ZKOrig(void, arg1, arg2);
    }];
    
}

- (void)_quitAppRepresentedByDisplayItem:(id)arg1 forReason:(long long)arg2 {

    //get app ident of tapped snapshot
    NSString *identifier = [arg1 valueForKey:@"_displayIdentifier"];
    
    //get application instance
    SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identifier];
    
    //send msg to cdtlamo
    [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
        
        //continue as normal
        ZKOrig(void, arg1, arg2);
    }];

}

@end