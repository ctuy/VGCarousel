//
//  UIViewController+VGCarousel.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/30/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VGCarouselViewController;

@interface UIViewController (VGCarousel)

- (VGCarouselViewController *)carouselViewController;
- (UINavigationController *)carouselNavigationController;
- (BOOL)isVisible;

@end
