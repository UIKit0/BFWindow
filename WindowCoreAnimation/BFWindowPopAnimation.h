//
//  BFWindowPopAnimation.h
//  WindowCoreAnimation
//
//  Created by beefon on 09.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

@class BFWindow;

/**
 Brings a window to the screen using pop animation (like UIAlertView on iOS).
 For better appearance, you should call makeKeyAndOrderFrontAnimatedWithDuration:completion: to present window 
 only when application is already active. I.e. if you want to present window on application launch, you should not call
 this method from applicationDidFinishLaunching:, but you should wait for applicationDidBecomeActive: notification.
 */
@interface BFWindowPopAnimation : NSObject

/**
 A window which supports animation.
 */
@property (nonatomic, weak, readonly) BFWindow *window;

/**
 Returns an instance that is configured to animate the given window.
 @param window A Window that should be animated.
 */
+ (instancetype)animationWithWindow:(BFWindow *)window;

/**
 Presents window with animation.
 @param duration A duration of the animation.
 @see -[NSWindow makeKeyAndOrderFront:]
 */
- (void)makeKeyAndOrderFrontAnimatedWithDuration:(NSTimeInterval)duration;

/**
 Presents window with animation.
 @param duration A duration of the animation.
 @param block A completion block that will be executed when animation completes.
 @see -[NSWindow makeKeyAndOrderFront:]
 */
- (void)makeKeyAndOrderFrontAnimatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))block;

/**
 Removes the window from screen with the given duration.
 @param duration Duration of the animation.
 */
- (void)orderOutWithDuration:(NSTimeInterval)duration;

@end
