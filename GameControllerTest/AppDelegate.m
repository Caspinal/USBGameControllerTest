//
//  AppDelegate.m
//  GameControllerTest
//
//  Created by connor aspinall on 15/07/2020.
//  Copyright © 2020 connor aspinall. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/hid/IOHIDLib.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSTextField *csticklbl;
@property (weak) IBOutlet NSSlider *HSlider;
@property (weak) IBOutlet NSSlider *VSlider;

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate


void inputEvent(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength);
 
void gamepadWasAdded(void* inContext, IOReturn inResult,
                     void* inSender, IOHIDDeviceRef device) {
    NSLog(@"Gamepad was plugged in: %@", device);
    
               AppDelegate *n = (__bridge AppDelegate*)inContext;
    [n playSoundNamed:@"Connect"];
  
}

-(void) playSoundNamed:(NSString*)soundName{
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:soundName ofType:@"m4a"] byReference:NO];
    [sound play];
}
 
void gamepadWasRemoved(void* inContext, IOReturn inResult,
                       void* inSender, IOHIDDeviceRef device) {
    NSLog(@"Gamepad was unplugged");
    AppDelegate *n = (__bridge AppDelegate*)inContext;
[n playSoundNamed:@"Disconnect"];
}
 
void gamepadAction(void* inContext, IOReturn inResult,
                   void* inSender, IOHIDValueRef value) {

    
    IOHIDElementRef element = IOHIDValueGetElement(value);
        
       int usagePage = IOHIDElementGetUsagePage(element);
       int usage = IOHIDElementGetUsage(element);
    long elementValue = IOHIDValueGetIntegerValue(value);
   
//       if (1 != usagePage)
//           return;
    AppDelegate *n = (__bridge AppDelegate*)inContext;
    if(usagePage == kHIDPage_Button){
        //NSLog(@"Button Usage %d %d %ld",usagePage, usage,elementValue);
        
        if(elementValue == 1){
        [n SpeakButton:usage];
        }
        return;
    }
    
   
        
        
            //NSLog(@"Joystick Usage %d %ld",usage,elementValue);
        

//               [n.label setStringValue:s];
    
    
        
    if(usage == kHIDUsage_GD_X){
        //NSLog(@"X %d %d %ld",usagePage, usage,elementValue);
        [n updatePoint:CGPointMake(elementValue, n.stickPos.y)];
    }

    if(usage == kHIDUsage_GD_Y){
        //NSLog(@"Y %d %d %ld",usagePage,usage,elementValue);
        [n updatePoint:CGPointMake(n.stickPos.x,elementValue)];
    }

    if(usage == kHIDUsage_GD_Z){
        // NSLog(@"Z %d %d %ld",usagePage,usage,elementValue);
        //c ctick here too?
    }
       
    if(usage == kHIDUsage_GD_Rz){
         NSLog(@"C Stick z %d %d %ld",usagePage,usage,elementValue);
    }
    if(usage == kHIDUsage_GD_Rx){
            NSLog(@"C Stick x %d %d %ld",usagePage,usage,elementValue);
    }
    if(usage == kHIDUsage_GD_Ry){
            NSLog(@"C Stick y  %d %d %ld",usagePage,usage,elementValue);
    }
    
    if(usage == kHIDUsage_GD_Hatswitch){
        //dpad rest 15
        // up 0
        // dn 4
        // lf 6
        // rt 2
        NSLog(@"HAT %d %d %ld",usagePage,usage,elementValue);
        if(elementValue == 15){return;}
        [n SpeakDirection:elementValue];
        //NSLog(@"dpad %d %d %ld",usagePage,usage,elementValue);
    }
    
    
    
}

-(void)SpeakButton:(int)button{
    
    NSSpeechSynthesizer *spk = [[NSSpeechSynthesizer alloc] init];
    
    NSNumber *key = [[NSNumber alloc] initWithInt:button];
    
    NSString *buttonLbl = [self.buttonMappings objectForKey:key];
    buttonLbl = [buttonLbl lowercaseString];
    NSLog(@"%@",buttonLbl);
    [spk startSpeakingString:buttonLbl];
}

-(void)SpeakDirection:(int)direction{
    
    NSSpeechSynthesizer *spk = [[NSSpeechSynthesizer alloc] init];
    
    NSNumber *key = [[NSNumber alloc] initWithInt:direction];
    
    NSString *buttonLbl = [self.dPadMappings objectForKey:key];
    buttonLbl = [buttonLbl lowercaseString];
    NSLog(@"%@",buttonLbl);
    [spk startSpeakingString:buttonLbl];
}

-(void)updatePoint:(CGPoint)point{
    
    self.stickPos = point;
    [self.label setStringValue:[NSString stringWithFormat:@"X: %f Y: %f",self.stickPos.x,self.stickPos.y]];
    
    [self.HSlider setDoubleValue: point.x];
    [self.VSlider setDoubleValue: point.y];
    
}

void inputEvent(void *context, IOReturn result, void *sender, IOHIDReportType type, uint32_t reportID, uint8_t *report, CFIndex reportLength){
    
     NSLog(@"Gamepad reported Input!");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    IOHIDManagerRef hidManager = IOHIDManagerCreate(kCFAllocatorDefault,
          kIOHIDOptionsTypeNone);
           
           NSMutableDictionary* criterion = [[NSMutableDictionary alloc] init];
           [criterion setObject: [NSNumber numberWithInt: kHIDPage_GenericDesktop]
                         forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
           [criterion setObject: [NSNumber numberWithInt: kHIDUsage_GD_Joystick]
                         forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
           
           IOHIDManagerSetDeviceMatching(hidManager, (__bridge CFDictionaryRef)criterion);
           
           IOHIDManagerRegisterDeviceMatchingCallback(hidManager, gamepadWasAdded,(__bridge void*)self);
           IOHIDManagerRegisterDeviceRemovalCallback(hidManager, gamepadWasRemoved,(__bridge void*)self);
            IOHIDManagerRegisterInputValueCallback(hidManager, gamepadAction,(__bridge void*)self);
    //IOHIDManagerRegisterInputReportCallback(hidManager, inputEvent, (__bridge void*)self);
    
    IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(),
    kCFRunLoopDefaultMode);
    IOHIDManagerOpen(hidManager, kIOHIDOptionsTypeNone);
    
    
    self.buttonMappings = [[NSMutableDictionary alloc] init];
    
    NSNumber *key = [[NSNumber alloc] initWithInt:3];
    [self.buttonMappings setObject:@"A" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:4];
    [self.buttonMappings setObject:@"B" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:1];
    [self.buttonMappings setObject:@"Y" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:2];
    [self.buttonMappings setObject:@"X" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:7];
    [self.buttonMappings setObject:@"Z" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:5];
    [self.buttonMappings setObject:@"LT" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:6];
    [self.buttonMappings setObject:@"RT" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:10];
    [self.buttonMappings setObject:@"START" forKey:key];
    
    self.stickPos = CGPointZero;
    
    self.dPadMappings = [[NSMutableDictionary alloc] init];
    
    key = [[NSNumber alloc] initWithInt:0];
    [self.dPadMappings setObject:@"up" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:1];
    [self.dPadMappings setObject:@"up and right" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:2];
    [self.dPadMappings setObject:@"right" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:3];
    [self.dPadMappings setObject:@"down and right" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:4];
    [self.dPadMappings setObject:@"down" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:5];
    [self.dPadMappings setObject:@"down and left" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:6];
    [self.dPadMappings setObject:@"left" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:7];
    [self.dPadMappings setObject:@"up and left" forKey:key];
    
    key = [[NSNumber alloc] initWithInt:15];
    [self.dPadMappings setObject:@"center" forKey:key];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
