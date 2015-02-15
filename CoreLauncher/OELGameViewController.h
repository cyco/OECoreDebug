//
//  OELGameViewController.h
//  CoreLauncher
//
//  Created by Christoph Leimbrock on 2/15/15.
//  Copyright (c) 2015 ccl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OEGameView.h"
#import "OEGameCoreHelper.h"

@interface OELGameViewController : NSViewController <OEGameCoreDisplayHelper>
@property (strong) IBOutlet OEGameView *view;
@end
