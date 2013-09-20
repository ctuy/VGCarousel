//
//  VGCarouselTitleView.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/20/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VGCarouselTitleView : UIView

@property (nonatomic, strong) NSArray *carouselTitles;
@property (nonatomic, strong) UIFont *carouselTitleFont;
@property (nonatomic, strong) UIColor *activeTitleColor;
@property (nonatomic, strong) UIColor *inactiveTitleColor;
@property (nonatomic) float shiftPercentage;
@property (nonatomic) NSUInteger currentTitleIndex;

- (id)initWithTitles:(NSArray *)titles;
- (void)shiftRight;
- (void)shiftLeft;
- (void)reset;

@end
