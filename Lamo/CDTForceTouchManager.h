//
//  CDTForceTouchManager.h
//  Lamo
//
//  Created by Ethan Arbuckle on 9/19/15.
//  Copyright © 2015 CortexDevTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "activator_headers/libactivator.h"
#include <dispatch/dispatch.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioServices.h>
#import "iokit/hid/IOHIDEventSystem.h"
#import "iokit/hid/IOHIDEventSystemClient.h"
#import "iokit/hid/IOHIDEvent.h"
#include <stdio.h>
#include <dlfcn.h>
#import "CDTLamo.h"

int IOHIDEventSystemClientSetMatching(IOHIDEventSystemClientRef client, CFDictionaryRef match);
CFArrayRef IOHIDEventSystemClientCopyServices(IOHIDEventSystemClientRef, int);
typedef struct __IOHIDServiceClient * IOHIDServiceClientRef;
int IOHIDServiceClientSetProperty(IOHIDServiceClientRef, CFStringRef, CFNumberRef);
typedef void* (*clientCreatePointer)(const CFAllocatorRef);
typedef void* (*vibratePointer)(SystemSoundID inSystemSoundID, id arg, NSDictionary *vibratePattern);

@interface CDTForceTouchManager : NSObject

+ (id)sharedInstance;

@end
