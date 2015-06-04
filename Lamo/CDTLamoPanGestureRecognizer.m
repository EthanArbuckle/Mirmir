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
    
    //make sure we are out of the buttons bounds, because this will steal their touches
    for (UITouch *touch in [touches allObjects]) {
        
        CGPoint touchLocation = [touch locationInView:[self view]];
        CGPoint currentBounds = [(CDTLamoBarView *)[self view] panBounds];
        if (touchLocation.x <= currentBounds.x || touchLocation.x > currentBounds.y) {
            
            //cancel
            return;
        }
    }
    
    [super touchesBegan:touches withEvent:event];
    [self setState:UIGestureRecognizerStateBegan];
}

@end
