//
//  BFWindowPopAnimation.m
//  WindowCoreAnimation
//
//  Created by beefon on 09.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

#import "BFWindow.h"
#import <QuartzCore/CoreImage.h>
#import "BFWindowPopAnimation.h"

@interface BFWindowPopAnimation ()

@property (nonatomic, copy) void (^completionBlock)(void);

@end

@implementation BFWindowPopAnimation

+ (instancetype)animationWithWindow:(BFWindow *)window {
    return [[self alloc] initWithWindow:window];
}

- (instancetype)initWithWindow:(BFWindow *)window {
    self = [super init];
    if (self) {
        _window = window;
    }
    return self;
}

- (void)makeKeyAndOrderFrontAnimatedWithDuration:(NSTimeInterval)duration {
    [self makeKeyAndOrderFrontAnimatedWithDuration:duration completion:NULL];
}

- (void)makeKeyAndOrderFrontAnimatedWithDuration:(NSTimeInterval)duration completion:(void (^)(void))block {
    if ([self.window isVisible]) {
        return;
    }
    
    self.completionBlock = ^{
        [self.window completeAnimationAndOrderFront:YES];
        if (block) {
            block();
        }
    };
    
    NSDisableScreenUpdates();
    [self animateWithDuration:duration];
    [self.window makeKeyAndOrderFront:nil];
    NSEnableScreenUpdates();
}

- (void)animateWithDuration:(NSTimeInterval)duration {
    NSSize insets = [self.window insetsForScale:1.2];
    CALayer *layer = [self.window prepareForAnimationWithInsets:insets];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.delegate = self;
    popAnimation.values = @[
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 0.01)],
    [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.2)],
    [NSValue valueWithCATransform3D:CATransform3DIdentity]
    ];
    popAnimation.timingFunctions = @[
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
    ];
    popAnimation.calculationMode = kCAAnimationLinear;
    popAnimation.keyTimes = @[@0.0, @0.5, @1.0];
    popAnimation.duration = duration;
    
    [layer addAnimation:popAnimation forKey:@"zoom"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self invokeCompletionBlock];
}

- (void)invokeCompletionBlock {
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = nil;
    }
}

- (void)orderOutWithDuration:(NSTimeInterval)duration {
    CALayer *layer = [self.window prepareForAnimationWithInsets:[self.window insetsForScale:1.0]];
    
    CATransform3D t = CATransform3DMakeScale(0.01, 0.01, 0.01);
    layer.transform = t;
    
    CABasicAnimation *zoomOut = [CABasicAnimation animationWithKeyPath:@"transform"];
    zoomOut.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    zoomOut.toValue = [NSValue valueWithCATransform3D:t];
    zoomOut.duration = duration;
    zoomOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    zoomOut.delegate = self;
    
    [layer addAnimation:zoomOut forKey:@"zoomOut"];
    
    self.completionBlock = ^{
        [self.window orderOut:nil];
        [self.window completeAnimationAndOrderFront:NO];
    };
}

@end
