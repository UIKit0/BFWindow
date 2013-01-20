//
//  AppDelegate.m
//  WindowCoreAnimation
//
//  Created by beefon on 08.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

#import "AppDelegate.h"
#import "BFWindow.h"
#import "BFWindowPopAnimation.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.spinner startAnimation:nil];
    self.window.livePreview = YES;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[BFWindowPopAnimation animationWithWindow:self.window] makeKeyAndOrderFrontAnimatedWithDuration:3.0];
}

- (void)animate:(id)sender {
    [[BFWindowPopAnimation animationWithWindow:self.window] orderOutWithDuration:1.0];
}

@end
