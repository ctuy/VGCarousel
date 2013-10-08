//
//  UIViewController+VGCarousel.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/30/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "UIViewController+VGCarousel.h"
#import "VGCarouselViewController.h"

@implementation UIViewController (VGCarousel)

- (VGCarouselViewController *)carouselViewController
{
    if ([self.parentViewController isKindOfClass:[VGCarouselViewController class]]) {
        VGCarouselViewController *parent = (VGCarouselViewController *)self.parentViewController;
        return parent;
    }
    else {
        return nil;
    }
}

- (BOOL)isVisible
{
    return [self isViewLoaded] && self.view.window;
}

@end
