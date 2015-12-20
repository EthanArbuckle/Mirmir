#import "Lamo.h"
#import "CDTLamo.h"
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBAppSwitcherController, SBAppSwitcherController, NSObject);

@implementation $_Lamo_SBAppSwitcherController

- (void)switcherScroller:(id)arg1 itemTapped:(id)arg2 {
    
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedDescending) {
    
        //normal ios 8 switcher
        if ([[self valueForKey:@"_appList_use_block_accessor"] indexOfObject:arg2] > 0) {
            
            //index -1, because springboard page counts as app
            int indexOfTapped = (int)([[self valueForKey:@"_appList_use_block_accessor"] indexOfObject:arg2]) - 1;
        
            //get array of indents
            SBAppSwitcherModel *appSwitcherModel = (SBAppSwitcherModel *)[NSClassFromString(@"SBAppSwitcherModel") sharedInstance];
            NSArray *liveIdents = [appSwitcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary];

            //get app
            NSString *identToOpen = [liveIdents objectAtIndex:indexOfTapped];
            SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identToOpen];
        
            //close window and run orig block
            [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
                ZKOrig(void, arg1, arg2);
            }];
        }
        else {
            
            //springboard tapped return as normal
            ZKOrig(void, arg1, arg2);
        }
    }
    
    else {

        //ios 9 device using legacy switcher
        if ([[self valueForKey:@"_displayItems"] indexOfObject:arg2] > 0) {
        
            //get app
            NSString *identToOpen = [arg2 valueForKey:@"_displayIdentifier"];
            SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identToOpen];
            
            //close window and run orig block
            [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
                ZKOrig(void, arg1, arg2);
            }];
        }
        else {
            
            //springboard tapped return as normal
            ZKOrig(void, arg1, arg2);
        }

        
    }

}

- (void)switcherScroller:(id)arg1 displayItemWantsToBeRemoved:(id)arg2 {
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedDescending) {

        if ([[self valueForKey:@"_appList_use_block_accessor"] indexOfObject:arg2] > 0) {
            
            //index -1, because springboard page counts as app
            //arg2 is sbdisplayitem, not sbdisplaylayout. fuck apple, we need to get the items
            int indexOfTapped = (int)([[self _flattenedArrayOfDisplayItemsFromDisplayLayouts:[self valueForKey:@"_appList_use_block_accessor"]] indexOfObject:arg2]) - 1;
            
            //get array of indents
            SBAppSwitcherModel *appSwitcherModel = (SBAppSwitcherModel *)[NSClassFromString(@"SBAppSwitcherModel") sharedInstance];
            NSArray *liveIdents = [appSwitcherModel snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary];
            
            //get app
            NSString *identToOpen = [liveIdents objectAtIndex:indexOfTapped];
            SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identToOpen];
            
            //close window and run orig block
            [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
                ZKOrig(void, arg1, arg2);
            }];
        }
        else {
            
            //springboard tapped return as normal
            ZKOrig(void, arg1, arg2);
        }
    }
    else {
        
        //ios 9 device with legacy switcher
        if ([[self valueForKey:@"_displayItems"] indexOfObject:arg2] > 0) {
            
            //get app
            NSString *identToOpen = [arg2 valueForKey:@"_displayIdentifier"];
            SBApplication *appOpening = [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:identToOpen];
            
            //close window and run orig block
            [[CDTLamo sharedInstance] appWantsToOpen:appOpening withBlock:^{
                ZKOrig(void, arg1, arg2);
            }];
        }
        else {
            
            //springboard tapped return as normal
            ZKOrig(void, arg1, arg2);
        }

    }

}

- (id)_flattenedArrayOfDisplayItemsFromDisplayLayouts:(id)arg1 {
    return ZKOrig(id, arg1);
}

@end