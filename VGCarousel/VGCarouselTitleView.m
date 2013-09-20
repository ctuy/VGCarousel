//
//  VGCarouselTitleView.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/20/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGCarouselTitleView.h"
#import "VGIndexUtilities.h"

#define DEFAULT_CAROUSEL_TITLE_BAR_HEIGHT 26
#define DEFAULT_CAROUSEL_TITLE_BAR_COLOR [UIColor colorWithRed:0.0/255.0 green:96.0/255.0 blue:119.0/255.0 alpha:1.0]
#define DEFAULT_CAROUSEL_TITLE_FONT [UIFont fontWithName:@"Helvetica-Bold" size:16.0f]
#define DEFAULT_CAROUSEL_CURRENT_TITLE_COLOR [UIColor whiteColor]
#define DEFAULT_CAROUSEL_INACTIVE_TITLE_COLOR [UIColor lightGrayColor]

@interface VGCarouselTitleView ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *floatingLabel;

@property (nonatomic, strong) NSArray *titleLabels;

@end

@implementation VGCarouselTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTitles:(NSArray *)titles
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.carouselTitles = titles;
        
        self.carouselTitleFont = DEFAULT_CAROUSEL_TITLE_FONT;
        self.activeTitleColor = DEFAULT_CAROUSEL_CURRENT_TITLE_COLOR;
        self.inactiveTitleColor = DEFAULT_CAROUSEL_INACTIVE_TITLE_COLOR;
        
        NSMutableArray *titleLabels = [NSMutableArray arrayWithCapacity:4];
        for (NSUInteger index = 0; index < 4; ++index) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textColor = self.inactiveTitleColor;
            label.font = self.carouselTitleFont;
            label.backgroundColor = [UIColor clearColor];
            [self addSubview:label];
            [titleLabels addObject:label];
        }
        
        self.titleLabels = [NSArray arrayWithArray:titleLabels];
        
        self.leftLabel = self.titleLabels[0];
        self.centerLabel = self.titleLabels[1];
        self.centerLabel.textColor = self.activeTitleColor;
        self.rightLabel = self.titleLabels[2];
        self.floatingLabel = self.titleLabels[3];
        
        self.shiftPercentage = 0.0f;
        
        self.backgroundColor = DEFAULT_CAROUSEL_TITLE_BAR_COLOR;
        
        self.currentTitleIndex = 0;
        
        [self setupCarouselTitles:[self visibleTitlesAtIndex:self.currentTitleIndex]];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake([self superview].bounds.size.width, DEFAULT_CAROUSEL_TITLE_BAR_HEIGHT);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabels enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = (UILabel *)obj;
        [label sizeToFit];
    }];
    
    self.leftLabel.center = CGPointMake(10.0f + self.leftLabel.bounds.size.width / 2, CGRectGetMidY(self.bounds));
    self.centerLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.rightLabel.center = CGPointMake(self.bounds.size.width - 10.0f - self.rightLabel.bounds.size.width / 2, CGRectGetMidY(self.bounds));
}

#pragma mark - Methods

- (NSArray *)visibleTitlesAtIndex:(NSUInteger)index
{
    NSAssert(index < self.carouselTitles.count, @"Index out of range");
    if (self.carouselTitles.count == 1) {
        return [NSArray arrayWithObject:self.carouselTitles[index]];
    }
    else {
        NSString *center = self.carouselTitles[index];
        NSString *left = self.carouselTitles[[VGIndexUtilities previousIndexOfIndex:index numberOfItems:self.carouselTitles.count]];
        NSString *right = self.carouselTitles[[VGIndexUtilities nextIndexOfIndex:index numberOfItems:self.carouselTitles.count]];
        return [NSArray arrayWithObjects:left, center, right, nil];
    }
}

- (NSString *)titleForFarLeft:(NSUInteger)index
{
    NSUInteger farLeftIndex = [VGIndexUtilities previousIndexOfIndex:[VGIndexUtilities previousIndexOfIndex:index numberOfItems:self.carouselTitles.count] numberOfItems:self.carouselTitles.count];
    return [self.carouselTitles objectAtIndex:farLeftIndex];
}

- (NSString *)titleForFarRight:(NSUInteger)index
{
    NSUInteger farRightIndex = [VGIndexUtilities nextIndexOfIndex:[VGIndexUtilities nextIndexOfIndex:index numberOfItems:self.carouselTitles.count] numberOfItems:self.carouselTitles.count];
    return [self.carouselTitles objectAtIndex:farRightIndex];
}

- (void)setupCarouselTitles:(NSArray *)carouselTitles
{
    if (carouselTitles.count > 1) {
        self.leftLabel.text = carouselTitles[0];
        self.centerLabel.text = carouselTitles[1];
        self.rightLabel.text = carouselTitles[2];
    }
    else {
        self.centerLabel.text = [carouselTitles objectAtIndex:0];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
