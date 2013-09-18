//
//  VGCarouselViewController.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VGCarouselViewController;

@protocol VGCarouselViewControllerDelegate <NSObject>



@end

@interface VGCarouselViewController : UIViewController

@property (nonatomic, assign) id <VGCarouselViewControllerDelegate> delegate;

- (id)initWithViewControllers:(NSArray *)viewControllers;

@end
