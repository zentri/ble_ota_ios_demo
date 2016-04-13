//
//  RoundRectPresentationController.m
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import "RoundRectPresentationController.h"

@interface RoundRectPresentationController ()

@property (nonatomic, readonly) UIView *dimmingView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@end

@implementation RoundRectPresentationController

- (UIView *)dimmingView {
    static UIView *instance = nil;
    if (instance == nil) {
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    return instance;
}

- (void)presentationTransitionWillBegin {
    UIView *presentedView = self.presentedViewController.view;
    presentedView.layer.cornerRadius = 10.f;
    presentedView.layer.shadowColor = [[UIColor blackColor] CGColor];
    presentedView.layer.shadowOffset = CGSizeMake(0, 10);
    presentedView.layer.shadowRadius = 10;
    presentedView.layer.shadowOpacity = 0.5;

    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [_tapGesture setDelegate:self];
    [_tapGesture setNumberOfTapsRequired:1];
    [self.dimmingView addGestureRecognizer:_tapGesture];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
        _tapGesture = nil;
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
        _tapGesture = nil;
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGFloat size = self.presentingViewController.view.frame.size.width / 1.2; //280;
    CGFloat sizeHeight = self.presentingViewController.view.frame.size.height / 2.0; //380;
    CGRect frame = CGRectMake((self.containerView.frame.size.width - size) / 2,
                              (self.containerView.frame.size.height - sizeHeight) / 2,
                              size, sizeHeight);
    return frame;
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

#pragma mark - Gesture Actions
-(void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
