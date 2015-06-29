//
//  CDTLamoCreditsDevCell.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/29/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoCreditsDevCell.h"

@implementation CDTLamoCreditsDevCell

- (id)init {
    
    if (self = [super init]) {
        
        //create ui objects
        
        _developerImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 70, 70)];
        [self addSubview:_developerImage];
        
        _developerName = [[UILabel alloc] initWithFrame:CGRectMake(95, 10, kScreenWidth - 20, 44)];
        [_developerName setBackgroundColor:[UIColor clearColor]];
        [_developerName setTextColor:[UIColor blackColor]];
        [_developerName setFont:[UIFont fontWithName:@"Helvetica Light" size:23]];
        [self addSubview:_developerName];
        
        _developerDescription = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, kScreenWidth - 20, 44)];
    }
 
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
