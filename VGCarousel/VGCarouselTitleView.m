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

@property (nonatomic) CGFloat leftLabelInitialCenterX;
@property (nonatomic) CGFloat rightLabelInitialCenterX;

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
    
    [self layoutBasedOnPercentage];
}

- (void)layoutBasedOnPercentage
{
    if (self.shiftPercentage > 0) {
        NSArray *titles = [[self visibleTitlesAtIndex:self.currentTitleIndex] arrayByAddingObject:[self titleForFarLeft:self.currentTitleIndex]];
        [self setupCarouselTitles:titles];
    }
    else if (self.shiftPercentage < 0) {
        NSArray *titles = [[self visibleTitlesAtIndex:self.currentTitleIndex] arrayByAddingObject:[self titleForFarRight:self.currentTitleIndex]];
        [self setupCarouselTitles:titles];
    }
    else {
        [self setupCarouselTitles:[self visibleTitlesAtIndex:self.currentTitleIndex]];
    }
    
    CGPoint initialLeftCenter = CGPointMake(10.0f + self.leftLabel.bounds.size.width / 2, CGRectGetMidY(self.bounds));
    CGPoint initialCenterCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGPoint initialRightCenter = CGPointMake(self.bounds.size.width - 10.0f - self.rightLabel.bounds.size.width / 2, CGRectGetMidY(self.bounds));
    
    if (self.shiftPercentage > 0) {
        self.leftLabel.center = CGPointMake(initialLeftCenter.x + ((initialCenterCenter.x - initialLeftCenter.x) * self.shiftPercentage), initialLeftCenter.y);
        
        CGPoint finalCenterCenter = CGPointMake(self.bounds.size.width - 10.0f - (self.centerLabel.bounds.size.width / 2), initialCenterCenter.y);
        self.centerLabel.center = CGPointMake(initialCenterCenter.x + ((finalCenterCenter.x - initialCenterCenter.x) * self.shiftPercentage), initialCenterCenter.y);
        
        self.rightLabel.center = CGPointMake(initialRightCenter.x + ((initialCenterCenter.x + self.bounds.size.width - initialRightCenter.x) * self.shiftPercentage), initialRightCenter.y);
        
        CGPoint initialFloatingCenter = CGPointMake(initialCenterCenter.x - self.bounds.size.width, initialCenterCenter.y);
        
        self.floatingLabel.center = CGPointMake(initialFloatingCenter.x + ((10.0f + self.floatingLabel.bounds.size.width / 2) - initialFloatingCenter.x) * self.shiftPercentage, initialFloatingCenter.y);
        
        if (fabs(self.shiftPercentage) > self.thresholdPercentage) {
            self.leftLabel.textColor = self.activeTitleColor;
            self.centerLabel.textColor = self.inactiveTitleColor;
        }
        else {
            self.leftLabel.textColor = self.inactiveTitleColor;
            self.centerLabel.textColor = self.activeTitleColor;
        }
    }
    else if (self.shiftPercentage < 0) {
        self.leftLabel.center = CGPointMake(initialLeftCenter.x + ((initialLeftCenter.x - (initialCenterCenter.x - self.bounds.size.width)) * self.shiftPercentage), initialLeftCenter.y);
        
        CGPoint finalCenterCenter = CGPointMake(10.0f + self.centerLabel.bounds.size.width / 2, initialCenterCenter.y);
        self.centerLabel.center = CGPointMake(initialCenterCenter.x + ((initialCenterCenter.x - finalCenterCenter.x) * self.shiftPercentage), initialCenterCenter.y);
        
        self.rightLabel.center = CGPointMake(initialRightCenter.x + ((initialRightCenter.x - initialCenterCenter.x) * self.shiftPercentage), initialRightCenter.y);
        
        CGPoint initialFloatingCenter = CGPointMake(initialCenterCenter.x + self.bounds.size.width, initialCenterCenter.y);
        
        self.floatingLabel.center = CGPointMake(initialFloatingCenter.x + ((initialFloatingCenter.x - (self.bounds.size.width - 10.0f - (self.floatingLabel.bounds.size.width / 2))) * self.shiftPercentage), initialFloatingCenter.y);
        
        if (fabs(self.shiftPercentage) > self.thresholdPercentage) {
            self.rightLabel.textColor = self.activeTitleColor;
            self.centerLabel.textColor = self.inactiveTitleColor;
        }
        else {
            self.rightLabel.textColor = self.inactiveTitleColor;
            self.centerLabel.textColor = self.activeTitleColor;
        }
    }
    else {
        self.leftLabel.center = initialLeftCenter;
        self.centerLabel.center = initialCenterCenter;
        self.rightLabel.center = initialRightCenter;
    }
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
        [self.leftLabel sizeToFit];
        
        self.centerLabel.text = carouselTitles[1];
        [self.centerLabel sizeToFit];
        
        self.rightLabel.text = carouselTitles[2];
        [self.rightLabel sizeToFit];
        
        if (carouselTitles.count == 4) {
            self.floatingLabel.text = carouselTitles[3];
            [self.floatingLabel sizeToFit];
        }
    }
    else {
        self.centerLabel.text = [carouselTitles objectAtIndex:0];
        [self.centerLabel sizeToFit];
        
        self.leftLabel.frame = CGRectZero;
        self.rightLabel.frame = CGRectZero;
        self.floatingLabel.frame = CGRectZero;
    }
}

- (void)shiftRight
{
    NSUInteger nextIndex = [VGIndexUtilities previousIndexOfIndex:self.currentTitleIndex numberOfItems:self.carouselTitles.count];
    self.currentTitleIndex = nextIndex;
    self.shiftPercentage = 0.0f;
    
    UILabel *temporaryLabel = self.rightLabel;
    self.rightLabel = self.centerLabel;
    self.centerLabel = self.leftLabel;
    self.leftLabel = self.floatingLabel;
    self.floatingLabel = temporaryLabel;
}

- (void)shiftLeft
{
    NSUInteger nextIndex = [VGIndexUtilities nextIndexOfIndex:self.currentTitleIndex numberOfItems:self.carouselTitles.count];
    self.currentTitleIndex = nextIndex;
    self.shiftPercentage = 0.0f;
    
    UILabel *temporaryLabel = self.leftLabel;
    self.leftLabel = self.centerLabel;
    self.centerLabel = self.rightLabel;
    self.rightLabel = self.floatingLabel;
    self.floatingLabel = temporaryLabel;
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
