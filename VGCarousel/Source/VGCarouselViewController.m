//
//  VGCarouselViewController.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGCarouselViewController.h"
#import "VGCarouselTitleView.h"
#import "VGIndexUtilities.h"

#define DEFAULT_PERCENTAGE_TRANSLATION_THRESHOLD 0.4f

typedef NS_ENUM(NSUInteger, ScrollDirection) {
    ScrollDirectionNone = 0,
    ScrollDirectionLeft = 1,
    ScrollDirectionRight = 2
};

@interface VGCarouselViewController ()

@property (nonatomic, strong) NSArray *carouselViewControllers;

@property (nonatomic, strong) VGCarouselTitleView *carouselTitleView;
@property (nonatomic, strong) NSArray *carouselTitles;

@property (nonatomic, strong) UIView *carouselContentView;

@property (nonatomic, strong) UIViewController *centerCarouselViewController;
@property (nonatomic, strong) UIViewController *leftCarouselViewController;
@property (nonatomic, strong) UIViewController *rightCarouselViewController;

@property (nonatomic) CGPoint centerCarouselInitialCenter;
@property (nonatomic) CGPoint leftCarouselInitialCenter;
@property (nonatomic) CGPoint rightCarouselInitialCenter;

@property (nonatomic) NSUInteger indexOfCurrentCenterCarouselViewController;

@property (nonatomic) BOOL leftCarouselViewControllerTriggeredDidMove;
@property (nonatomic) BOOL rightCarouselViewControllerTriggeredDidMove;

@property (nonatomic) ScrollDirection lastScrollDirection;

@property (nonatomic) BOOL stateOfForwardAppearance;

@end

@implementation VGCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.carouselViewControllers = viewControllers;
        
        NSMutableArray *carouselTitles = [NSMutableArray arrayWithCapacity:self.carouselViewControllers.count];
        [self.carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *vc = (UIViewController *)obj;
            [carouselTitles addObject:(vc.title.length > 0 ? vc.title : @"")];
        }];
        
        self.carouselTitles = [NSArray arrayWithArray:carouselTitles];
        
        self.percentageTranslationThreshold = DEFAULT_PERCENTAGE_TRANSLATION_THRESHOLD;
    }
    return self;
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    self.view.backgroundColor = [UIColor redColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.carouselTitleView = [[VGCarouselTitleView alloc] initWithTitles:self.carouselTitles];
    self.carouselTitleView.thresholdPercentage = self.percentageTranslationThreshold;
    [self.view addSubview:self.carouselTitleView];
    [self.carouselTitleView sizeToFit];
    
    if (self.carouselViewControllers.count > 1) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    self.carouselContentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.carouselTitleView.bounds.size.height, viewFrame.size.width, viewFrame.size.height - self.carouselTitleView.bounds.size.height)];
    self.carouselContentView.backgroundColor = [UIColor yellowColor];
    self.carouselContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.carouselContentView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupInitialViewController:[self carouselViewControllerAtIndex:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)setupInitialViewController:(UIViewController *)vc
{
    [self addChildViewController:vc];
    [self.carouselContentView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.centerCarouselViewController = vc;
    self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:vc];
}

- (UIViewController *)carouselViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *vc = [self.carouselViewControllers objectAtIndex:index];
    if (!vc.isViewLoaded) {
        vc.view.frame = self.carouselContentView.bounds;
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    return vc;
}

- (UIViewController *)leftCarouselViewControllerOfViewControllerAtIndex:(NSUInteger)index
{
    NSUInteger leftIndex = [VGIndexUtilities previousIndexOfIndex:index numberOfItems:self.carouselViewControllers.count];
    UIViewController *vc = [self carouselViewControllerAtIndex:leftIndex];
    vc.view.center = self.leftCarouselInitialCenter;;
    return vc;
}

- (UIViewController *)rightCarouselViewControllerOfViewControllerAtIndex:(NSUInteger)index
{
    NSUInteger rightIndex = [VGIndexUtilities nextIndexOfIndex:index numberOfItems:self.carouselViewControllers.count];
    UIViewController *vc = [self carouselViewControllerAtIndex:rightIndex];
    vc.view.center = self.rightCarouselInitialCenter;
    return vc;
}

- (ScrollDirection)scrollDirectionForTranslation:(CGFloat)translation
{
    if (translation > 0) {
        return ScrollDirectionRight;
    }
    else if (translation < 0) {
        return ScrollDirectionLeft;
    }
    else {
        return ScrollDirectionNone;
    }
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.centerCarouselViewController.view.userInteractionEnabled = NO;
            self.centerCarouselInitialCenter = CGPointMake(CGRectGetMidX(self.carouselContentView.bounds), CGRectGetMidY(self.carouselContentView.bounds));
            self.leftCarouselInitialCenter = CGPointMake(-self.carouselContentView.bounds.size.width / 2, self.centerCarouselInitialCenter.y);
            self.rightCarouselInitialCenter = CGPointMake(self.carouselContentView.bounds.size.width + self.carouselContentView.bounds.size.width / 2, self.centerCarouselInitialCenter.y);
            self.lastScrollDirection = ScrollDirectionNone;
            self.stateOfForwardAppearance = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            float change = (translation.x / (self.view.bounds.size.width));
            change = (change > 1) ? 1 : ((change < -1) ? -1 : change);
            self.carouselTitleView.shiftPercentage = change;
            
            ScrollDirection currentDirection = [self scrollDirectionForTranslation:translation.x];
            BOOL shouldHideViewControllerFromOtherDirection = (currentDirection != self.lastScrollDirection && self.lastScrollDirection != ScrollDirectionNone && currentDirection != ScrollDirectionNone);
            self.lastScrollDirection = currentDirection;
            
            if (translation.x > 0) {
                if (!self.leftCarouselViewController) {
                    self.leftCarouselViewController = [self leftCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                    [self addChildViewController:self.leftCarouselViewController];
                    self.leftCarouselViewController.view.userInteractionEnabled = NO;
                    [self.carouselContentView addSubview:self.leftCarouselViewController.view];
                    self.leftCarouselViewControllerTriggeredDidMove = NO;
                    [self.leftCarouselViewController beginAppearanceTransition:YES animated:YES];
                }
                if (shouldHideViewControllerFromOtherDirection) {
                    if (self.rightCarouselViewController) {
                        [self.rightCarouselViewController willMoveToParentViewController:nil];
                        [self.rightCarouselViewController beginAppearanceTransition:NO animated:YES];
                    }
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.leftCarouselViewController.view.center = CGPointMake(self.leftCarouselInitialCenter.x + translation.x, self.leftCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
                    if (shouldHideViewControllerFromOtherDirection) {
                        if (self.rightCarouselViewController) {
                            self.rightCarouselViewController.view.center = self.rightCarouselInitialCenter;
                        }
                    }
                    [self.carouselTitleView layoutBasedOnPercentage];
                } completion:^(BOOL finished) {
                    if (!self.leftCarouselViewControllerTriggeredDidMove) {
                        self.leftCarouselViewControllerTriggeredDidMove = YES;
                        [self.leftCarouselViewController endAppearanceTransition];
                        [self.leftCarouselViewController didMoveToParentViewController:self];
                    }
                    if (shouldHideViewControllerFromOtherDirection) {
                        if (self.rightCarouselViewController) {
                            [self.rightCarouselViewController.view removeFromSuperview];
                            [self.rightCarouselViewController endAppearanceTransition];
                            [self.rightCarouselViewController removeFromParentViewController];
                            self.rightCarouselViewController = nil;
                        }
                    }
                }];
            }
            else if (translation.x < 0) {
                if (!self.rightCarouselViewController) {
                    self.rightCarouselViewController = [self rightCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                    [self addChildViewController:self.rightCarouselViewController];
                    self.rightCarouselViewController.view.userInteractionEnabled = NO;
                    [self.carouselContentView addSubview:self.rightCarouselViewController.view];
                    self.rightCarouselViewControllerTriggeredDidMove = NO;
                    [self.rightCarouselViewController beginAppearanceTransition:YES animated:YES];
                }
                if (shouldHideViewControllerFromOtherDirection) {
                    if (self.leftCarouselViewController) {
                        [self.leftCarouselViewController willMoveToParentViewController:nil];
                        [self.leftCarouselViewController beginAppearanceTransition:NO animated:YES];
                    }
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.rightCarouselViewController.view.center = CGPointMake(self.rightCarouselInitialCenter.x + translation.x, self.rightCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
                    if (shouldHideViewControllerFromOtherDirection) {
                        if (self.leftCarouselViewController) {
                            self.leftCarouselViewController.view.center = self.leftCarouselInitialCenter;
                        }
                    }
                    [self.carouselTitleView layoutBasedOnPercentage];
                } completion:^(BOOL finished) {
                    if (!self.rightCarouselViewControllerTriggeredDidMove) {
                        self.rightCarouselViewControllerTriggeredDidMove = YES;
                        [self.rightCarouselViewController endAppearanceTransition];
                        [self.rightCarouselViewController didMoveToParentViewController:self];
                    }
                    if (shouldHideViewControllerFromOtherDirection) {
                        if (self.leftCarouselViewController) {
                            [self.leftCarouselViewController.view removeFromSuperview];
                            [self.leftCarouselViewController endAppearanceTransition];
                            [self.leftCarouselViewController removeFromParentViewController];
                            self.leftCarouselViewController = nil;
                        }
                    }
                }];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (fabs(translation.x) > self.carouselContentView.bounds.size.width * self.percentageTranslationThreshold) {
                if (translation.x > 0) {
                    self.carouselTitleView.shiftPercentage = 1.0f;
                    [self.centerCarouselViewController willMoveToParentViewController:nil];
                    [self.centerCarouselViewController beginAppearanceTransition:NO animated:YES];
                    [UIView animateWithDuration:0.3f animations:^{
                        self.centerCarouselViewController.view.center = self.rightCarouselInitialCenter;
                        self.leftCarouselViewController.view.center = self.centerCarouselInitialCenter;
                        [self.carouselTitleView layoutBasedOnPercentage];
                    } completion:^(BOOL finished) {
                        [self.centerCarouselViewController.view removeFromSuperview];
                        [self.centerCarouselViewController endAppearanceTransition];
                        [self.centerCarouselViewController removeFromParentViewController];
                        
                        self.centerCarouselViewController = self.leftCarouselViewController;
                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.leftCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                        [self.carouselTitleView shiftRight];
                        if ([self.delegate respondsToSelector:@selector(carouselViewController:didChangeToIndex:)]) {
                            [self.delegate carouselViewController:self didChangeToIndex:self.indexOfCurrentCenterCarouselViewController];
                        }
                        self.stateOfForwardAppearance = YES;
                    }];
                }
                else if (translation.x < 0) {
                    self.carouselTitleView.shiftPercentage = -1.0f;
                    [self.centerCarouselViewController willMoveToParentViewController:nil];
                    [self.centerCarouselViewController beginAppearanceTransition:NO animated:YES];
                    [UIView animateWithDuration:0.3f animations:^{
                        self.centerCarouselViewController.view.center = self.leftCarouselInitialCenter;
                        self.rightCarouselViewController.view.center = self.centerCarouselInitialCenter;
                        [self.carouselTitleView layoutBasedOnPercentage];
                    } completion:^(BOOL finished) {
                        [self.centerCarouselViewController.view removeFromSuperview];
                        [self.centerCarouselViewController endAppearanceTransition];
                        [self.centerCarouselViewController removeFromParentViewController];

                        self.centerCarouselViewController = self.rightCarouselViewController;
                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.rightCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                        [self.carouselTitleView shiftLeft];
                        if ([self.delegate respondsToSelector:@selector(carouselViewController:didChangeToIndex:)]) {
                            [self.delegate carouselViewController:self didChangeToIndex:self.indexOfCurrentCenterCarouselViewController];
                        }
                        self.stateOfForwardAppearance = YES;
                    }];
                }
            }
            else {
                self.carouselTitleView.shiftPercentage = 0.0f;
                if (self.leftCarouselViewController) {
                    [self.leftCarouselViewController willMoveToParentViewController:nil];
                    [self.leftCarouselViewController beginAppearanceTransition:NO animated:YES];
                }
                if (self.rightCarouselViewController) {
                    [self.rightCarouselViewController willMoveToParentViewController:nil];
                    [self.rightCarouselViewController beginAppearanceTransition:NO animated:YES];
                }
                [UIView animateWithDuration:0.3f animations:^{
                    self.centerCarouselViewController.view.center = self.centerCarouselInitialCenter;
                    if (self.leftCarouselViewController) {
                        self.leftCarouselViewController.view.center = self.leftCarouselInitialCenter;
                    }
                    if (self.rightCarouselViewController) {
                        self.rightCarouselViewController.view.center = self.rightCarouselInitialCenter;
                    }
                    [self.carouselTitleView layoutBasedOnPercentage];
                } completion:^(BOOL finished) {
                    self.centerCarouselViewController.view.userInteractionEnabled = YES;
                    if (self.leftCarouselViewController) {
                        [self.leftCarouselViewController.view removeFromSuperview];
                        [self.leftCarouselViewController endAppearanceTransition];
                        [self.leftCarouselViewController removeFromParentViewController];
                        self.leftCarouselViewController = nil;
                    }
                    if (self.rightCarouselViewController) {
                        [self.rightCarouselViewController.view removeFromSuperview];
                        [self.rightCarouselViewController endAppearanceTransition];
                        [self.rightCarouselViewController removeFromParentViewController];
                        self.rightCarouselViewController = nil;
                    }
                    self.stateOfForwardAppearance = YES;
                }];                
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            self.stateOfForwardAppearance = YES;
            break;
        default:
            break;
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return self.stateOfForwardAppearance;
}

@end
