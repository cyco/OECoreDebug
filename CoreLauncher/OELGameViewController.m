//
//  OELGameViewController.m
//  CoreLauncher
//
//  Created by Christoph Leimbrock on 2/15/15.
//  Copyright (c) 2015 ccl. All rights reserved.
//

#import "OELGameViewController.h"


@interface OELGameViewController ()
@end

@implementation OELGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSColor *viewBackgroundColor = [NSColor darkGrayColor];
    [[self view] setBackgroundColor:viewBackgroundColor];
}

#pragma mark - OEGameCoreDisplayHelper
- (void)setEnableVSync:(BOOL)enable
{
    // Do nothing. VSync is always on!
}

- (void)setAspectSize:(OEIntSize)newAspectSize
{
    [[self view] setAspectSize:newAspectSize];
}

- (void)setScreenSize:(OEIntSize)newScreenSize withIOSurfaceID:(IOSurfaceID)newSurfaceID
{
    [[self view] setScreenSize:newScreenSize withIOSurfaceID:newSurfaceID];
}

- (void)setScreenSize:(OEIntSize)newScreenSize aspectSize:(OEIntSize)newAspectSize withIOSurfaceID:(IOSurfaceID)newSurfaceID
{
    [[self view] setScreenSize:newScreenSize aspectSize:newAspectSize withIOSurfaceID:newSurfaceID];
}


@end
