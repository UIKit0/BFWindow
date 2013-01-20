//
//  AppDelegate.h
//  WindowCoreAnimation
//
//  Created by beefon on 08.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

@class BFWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet BFWindow *window;
@property (weak) IBOutlet NSProgressIndicator *spinner;

- (IBAction)animate:(id)sender;

@end
