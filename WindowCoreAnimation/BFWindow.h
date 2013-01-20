//
//  BFWindow.h
//  WindowCoreAnimation
//
//  Created by beefon on 08.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

APPKIT_EXTERN NSSize const kBFWindowActiveWindowOffset;
APPKIT_EXTERN NSSize const kBFWindowInactiveWindowOffset;

/**
 Window that allows you to apply Core Animations to itself.
 It creates a window hierarchy that is displayed during animation and removes it when animation completes.
 */
@interface BFWindow : NSWindow

/**
 Returns image of the receiver's content.
 */
- (NSImage *)snapshot;

/**
 Returns the insets suitable for the given scale that you would apply to the receiver's content.
 */
- (NSSize)insetsForScale:(CGFloat)scale;

/**
 Allows to update the content during animation.
 */
@property (nonatomic, assign) BOOL livePreview;

/**
 Prepares and returns the layer that you would use to perform all the needed animations.
 */
- (CALayer *)prepareForAnimationWithInsets:(NSSize)insets;

/**
 Restores the receiver's state and removes all animation-related layers, etc.
 @param shouldOrderFront Pass YES if receiver should orderFront:; pass NO otherwise.
 */
- (void)completeAnimationAndOrderFront:(BOOL)shouldOrderFront;

@end
