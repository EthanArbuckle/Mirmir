//
//  CDTLamoPanGestureRecognizer.m
//  Lamo
//
//  Created by Ethan Arbuckle on 6/4/15.
//  Copyright (c) 2015 CortexDevTeam. All rights reserved.
//

#import "CDTLamoPanGestureRecognizer.h"

@implementation CDTLamoPanGestureRecognizer

//we want our pan delegate to fire on touches began, not when pan first begins (for long press recognizing)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    [self setState:UIGestureRecognizerStateBegan];
}

@end
