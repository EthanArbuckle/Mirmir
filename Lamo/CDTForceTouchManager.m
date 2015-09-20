//
//  CDTForceTouchManager.m
//  Lamo
//
//  Created by Ethan Arbuckle on 9/19/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import "CDTForceTouchManager.h"

struct rawTouch {
    float density;
    float radius;
    float quality;
    float x;
    float y;
} lastTouch;

BOOL hasIncreasedByPercent(float percent, float value1, float value2) {
    
    if (value1 <= 0 || value2 <= 0)
        return NO;
    if (value1 >= value2 + (value2 / percent))
        return YES;
    return NO;
}

void touch_event(void* target, void* refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    
    if (IOHIDEventGetType(event) == kIOHIDEventTypeDigitizer) {
        
        //get child events (individual finger)
        NSArray *children = (__bridge NSArray *)IOHIDEventGetChildren(event);
        if ([children count] == 1) { //single touch
            
            struct rawTouch touch;
            
            touch.density = IOHIDEventGetFloatValue((__bridge IOHIDEventRef)(children[0]), (IOHIDEventField)kIOHIDEventFieldDigitizerDensity);
            touch.radius = IOHIDEventGetFloatValue((__bridge IOHIDEventRef)(children[0]), (IOHIDEventField)kIOHIDEventFieldDigitizerMajorRadius);
            touch.quality = IOHIDEventGetFloatValue((__bridge IOHIDEventRef)(children[0]), (IOHIDEventField)kIOHIDEventFieldDigitizerQuality);
            touch.x = IOHIDEventGetFloatValue((__bridge IOHIDEventRef)(children[0]), (IOHIDEventField)kIOHIDEventFieldDigitizerX) * [[UIScreen mainScreen] bounds].size.width;
            touch.y = IOHIDEventGetFloatValue((__bridge IOHIDEventRef)(children[0]), (IOHIDEventField)kIOHIDEventFieldDigitizerY) * [[UIScreen mainScreen] bounds].size.height;
            
            if (hasIncreasedByPercent(10, touch.density, lastTouch.density) && hasIncreasedByPercent(5, touch.radius, lastTouch.radius) && hasIncreasedByPercent(5, touch.quality, lastTouch.quality)) {
                
                //make sure we arent being triggered by some swipe by canceling out touches that go beyond 10px of orig touch
                if ((lastTouch.x - touch.x >= 10 || lastTouch.x - touch.x <= -10) || (lastTouch.y - touch.y >= 10 || lastTouch.y - touch.y <= -10)) {
                    return;
                }
                
                
                CGPoint touchLocation = CGPointMake(touch.x, touch.y);
                
                if ([[CDTLamo sharedInstance] didSucceedInForceTouchLaunchAtLocation:touchLocation]) {
                                
                    NSMutableArray *vPattern = [NSMutableArray array];
                    [vPattern addObject:[NSNumber numberWithBool:YES]];
                    [vPattern addObject:[NSNumber numberWithInt:100]];
                    NSDictionary *vDict = @{ @"VibePattern" : vPattern, @"Intensity" : @1 };
                
                    vibratePointer vibrate;
                    void *handle = dlopen(0, 9);
                    *(void**)(&vibrate) = dlsym(handle,"AudioServicesPlaySystemSoundWithVibration");
                    vibrate(kSystemSoundID_Vibrate, nil, vDict);
                    
                    typedef void* (*cancelTouchesStruct)();
                    cancelTouchesStruct cancelTouches;
                    *(void**)(&cancelTouches) = dlsym(handle,"BKSHIDServicesCancelTouchesOnMainDisplay");
                    cancelTouches();
                    
                }
            }
            
            lastTouch = touch;
        }
    }
}

@implementation CDTForceTouchManager

+ (id)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    
    if (self = [super init]) {
        
        clientCreatePointer clientCreate;
        void *handle = dlopen(0, 9);
        *(void**)(&clientCreate) = dlsym(handle,"IOHIDEventSystemClientCreate");
        IOHIDEventSystemClientRef ioHIDEventSystem = clientCreate(kCFAllocatorDefault);
        IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystem, (IOHIDEventSystemClientEventCallback)touch_event, NULL, NULL);
        
    }
    
    return self;
}

@end
