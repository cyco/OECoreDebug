//
//  AppDelegate.h
//  CoreLauncher
//
//  Created by Christoph Leimbrock on 2/15/15.
//  Copyright (c) 2015 ccl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OELGameViewController.h"

extern NSString * const OECoreLauncherLastROMPath;

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) IBOutlet OELGameViewController *gameViewController;
@end

