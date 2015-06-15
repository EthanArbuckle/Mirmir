//
//  SBIconController.m
//  
//
//  Created by Ethan Arbuckle on 6/14/15.
//
//

#import <Foundation/Foundation.h>
#import "Lamo.h"
#import "CDTLamo.h"
#import "ZKSwizzle.h"

ZKSwizzleInterface($_Lamo_SBIconController, SBIconController, NSObject);

@implementation $_Lamo_SBIconController

//detect when our lamo settings icon is tapped
-(void)iconTapped:(id)icon {
    
    ZKOrig(void, icon);
    
    if ([[[icon valueForKey:@"_icon"] leafIdentifier] isEqualToString:@"lamo"]) {
        
        [[CDTLamo sharedInstance] presentSettingsController];

    }
    
}

@end