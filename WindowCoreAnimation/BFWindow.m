//
//  BFWindow.m
//  WindowCoreAnimation
//
//  Created by beefon on 08.01.13.
//  Copyright (c) 2013 beefon. All rights reserved.
//

#import "BFWindow.h"

NSSize const kBFWindowActiveWindowOffset = {0, -22};
NSSize const kBFWindowInactiveWindowOffset = {0, -5};
CGFloat const kBFWindowShadowTotalLength = 90.0;

@interface BFWindow ()

@property (nonatomic, assign) NSSize insets;
@property (nonatomic, assign) NSSize offset;

@property (nonatomic, assign) NSRect originalFrame;

@property (nonatomic, assign) NSTimer *renderTimer;

@property (nonatomic, strong) NSWindow *animationWindow;
@property (nonatomic, strong) NSView *animationView;
@property (nonatomic, strong) CALayer *animationLayer;

@end

@implementation BFWindow

- (NSImage *)snapshot {
    NSImage *image = [[NSImage alloc] initWithCGImage:[self newImageFromWindowContent]
                                                 size:self.frame.size];
    [image setDataRetained:YES];
    [image setCacheMode:NSImageCacheNever];
    
    return image;
}

- (CGImageRef)newImageFromWindowContent {
    CGWindowID windowID = (CGWindowID)[self windowNumber];
    CGWindowListOption singleWindowListOptions = kCGWindowListOptionIncludingWindow;
    CGRect imageBounds = CGRectNull;
	CGImageRef windowImage = CGWindowListCreateImage(imageBounds,
                                                     singleWindowListOptions,
                                                     windowID,
                                                     kCGWindowImageDefault);
    return windowImage;
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
    return frameRect;
}

- (NSWindow *)animationWindow {
    if (_animationWindow == nil) {
        _animationWindow = [[NSWindow alloc] initWithContentRect:NSInsetRect(self.frame, -self.insets.width, -self.insets.height)
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO];
        [_animationWindow setOpaque:NO];
        _animationWindow.backgroundColor = [NSColor clearColor];
        [_animationWindow.contentView addSubview:self.animationView];
        _animationWindow.level = self.level;
    }
    return _animationWindow;
}

- (NSView *)animationView {
    if (_animationView == nil) {
        NSRect frame = [self.animationWindow.contentView frame];
        _animationView = [[NSView alloc] initWithFrame:frame];
        _animationView.wantsLayer = YES;
        _animationView.layer = [CALayer layer];
        [_animationView.layer addSublayer:self.animationLayer];
        [self updateAnimationLayerFrame];
    }
    return _animationView;
}

- (CALayer *)animationLayer {
    if (_animationLayer == nil) {
        _animationLayer = [[CALayer alloc] init];
        _animationLayer.contentsGravity = kCAGravityCenter;
    }
    return _animationLayer;
}

- (void)updateAnimationLayerContents {
    [CATransaction lock];
    self.animationLayer.contents = [self snapshot];
    [CATransaction unlock];
}

#pragma mark - Live Preview Timer

- (void)startRenderTimer {
    if (self.renderTimer == nil) {
        self.renderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                            target:self
                                                          selector:@selector(renderTimerFired:)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

- (BOOL)isRenderTimerStarted {
    return (self.renderTimer != nil);
}

- (void)renderTimerFired:(NSTimer *)t {
    if (self.livePreview) {
        [self updateAnimationLayerContents];
    }
}

- (void)stopRenderTimer {
    if (self.renderTimer) {
        [self.renderTimer invalidate];
        self.renderTimer = nil;
    }
}

#pragma mark - Shadow Considering

- (void)setOffset:(NSSize)offset {
    if (!NSEqualSizes(offset, _offset)) {
        _offset = offset;
        [self updateAnimationLayerFrame];
    }
}

- (void)updateAnimationLayerFrame {
    if (_animationLayer) {
        [CATransaction setDisableActions:YES];
        [CATransaction lock];
        
        CATransform3D t = self.animationLayer.transform;
        self.animationLayer.transform = CATransform3DIdentity;
        
        [self updateAnimationLayerContents];
        
        CGRect layerFrame = NSRectToCGRect(self.animationView.layer.bounds);
        layerFrame.size.width -= self.insets.width*2;
        layerFrame.size.height -= self.insets.height*2;
        layerFrame.origin = CGPointMake(self.insets.width + self.offset.width,
                                        self.insets.height + self.offset.height);
        self.animationLayer.frame = layerFrame;
        
        self.animationLayer.transform = t;
        
        [CATransaction unlock];
    }
}

#pragma mark - Notifications

- (void)subscribeToNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(updateOffset:) name:NSWindowDidBecomeKeyNotification object:self];
    [center addObserver:self selector:@selector(updateOffset:) name:NSWindowDidBecomeMainNotification object:self];
    [center addObserver:self selector:@selector(updateOffset:) name:NSWindowDidResignKeyNotification object:self];
    [center addObserver:self selector:@selector(updateOffset:) name:NSWindowDidResignMainNotification object:self];
}

- (void)unsubscribeFromNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSWindowDidBecomeKeyNotification object:self];
    [center removeObserver:self name:NSWindowDidBecomeMainNotification object:self];
    [center removeObserver:self name:NSWindowDidResignKeyNotification object:self];
    [center removeObserver:self name:NSWindowDidResignMainNotification object:self];
}

- (void)makeKeyAndOrderFront:(id)sender {
    [super makeKeyAndOrderFront:sender];
    
    if (_animationLayer) {
        [self updateAnimationLayerContents];
    }
}

- (void)updateOffset:(NSNotification *)n {
    self.offset = ([self isMainWindow] || [self isKeyWindow] ? kBFWindowActiveWindowOffset : kBFWindowInactiveWindowOffset);
}

#pragma mark - Public Interface

- (CALayer *)prepareForAnimationWithInsets:(NSSize)insets {
    if (![self isRenderTimerStarted]) {
        self.insets = insets;
        [self.animationWindow orderFront:nil];
        
        [self updateOffset:nil];
        [self subscribeToNotifications];
        
        [self startRenderTimer];
        
        self.originalFrame = self.frame;
        [self setFrame:NSOffsetRect(self.originalFrame, -15000, 0) display:YES];
    }
    return self.animationLayer;
}

- (void)completeAnimationAndOrderFront:(BOOL)shouldOrderFront {
    NSDisableScreenUpdates();
    
    [self stopRenderTimer];
    
    [self setFrame:self.originalFrame display:YES];
    
    if (shouldOrderFront) {
        [self orderFront:nil];
    }
    
    [self.animationWindow orderOut:nil];
    
    [self unsubscribeFromNotifications];
    
    self.animationLayer = nil;
    self.animationView = nil;
    self.animationWindow = nil;
    
    NSEnableScreenUpdates();
}

- (NSSize)insetsForScale:(CGFloat)scale {
    NSSize sizeWithShadow = self.frame.size;
    sizeWithShadow.width += kBFWindowShadowTotalLength;
    sizeWithShadow.height += kBFWindowShadowTotalLength;
    
    return NSMakeSize(MAX(roundf((scale - 1.0) * sizeWithShadow.width)*2, kBFWindowShadowTotalLength),
                      MAX(roundf((scale - 1.0) * sizeWithShadow.height)*2, kBFWindowShadowTotalLength));
}

@end
