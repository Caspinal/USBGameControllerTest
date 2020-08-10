//
//  AppDelegate.h
//  GameControllerTest
//
//  Created by connor aspinall on 15/07/2020.
//  Copyright © 2020 connor aspinall. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property NSMutableDictionary *buttonMappings;
@property NSMutableDictionary *dPadMappings;
@property CGPoint stickPos;

@end

