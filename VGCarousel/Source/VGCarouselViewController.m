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
#import "UIViewController+VGCarousel.h"
#import "UINavigationItem+KVO.h"
#import "VGLimitedPanGestureRecognizer.h"

#define DEFAULT_PERCENTAGE_TRANSLATION_THRESHOLD 0.4f

typedef NS_ENUM(NSUInteger, ScrollDirection) {
    ScrollDirectionNone = 0,
    ScrollDirectionLeft = 1,
    ScrollDirectionRight = 2
};

@interface VGCarouselViewController ()

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

@property (nonatomic) ScrollDirection lastScrollDirection;

@property (nonatomic, strong) VGLimitedPanGestureRecognizer *panGestureRecognizer;

@end

@implementation VGCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.percentageTranslationThreshold = DEFAULT_PERCENTAGE_TRANSLATION_THRESHOLD;
    }
    return self;
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _carouselViewControllers = viewControllers;
        
        NSMutableArray *carouselTitles = [NSMutableArray arrayWithCapacity:self.carouselViewControllers.count];
        [self.carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *vc = (UIViewController *)obj;
            [self setupNavigationItemObservationForViewController:vc];
            [carouselTitles addObject:(vc.title.length > 0 ? vc.title : @"")];
        }];
        
        self.carouselTitles = [NSArray arrayWithArray:carouselTitles];
        
        self.percentageTranslationThreshold = DEFAULT_PERCENTAGE_TRANSLATION_THRESHOLD;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)viewController
{
    return [self initWithViewControllers:@[viewController]];
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.carouselTitleView = [[VGCarouselTitleView alloc] initWithTitles:self.carouselTitles];
    self.carouselTitleView.thresholdPercentage = self.percentageTranslationThreshold;
    [self.view addSubview:self.carouselTitleView];
    [self.carouselTitleView sizeToFit];
    
    if (self.carouselViewControllers.count > 1) {
        self.panGestureRecognizer = [[VGLimitedPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        self.panGestureRecognizer.percentageTranslationThreshold = self.percentageTranslationThreshold;
        [self.view addGestureRecognizer:self.panGestureRecognizer];
    }
    
    self.carouselContentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.carouselTitleView.bounds.size.height, viewFrame.size.width, viewFrame.size.height - self.carouselTitleView.bounds.size.height)];
    self.carouselContentView.backgroundColor = [UIColor clearColor];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    static dispatch_once_t onceToken;
    static NSArray *observedKeyPaths = nil;
    dispatch_once(&onceToken, ^{
        observedKeyPaths = @[@"leftBarButtonItem", @"leftBarButtonItems", @"rightBarButtonItem", @"rightBarButtonItems", @"title", @"titleView"];
    });
    if (self.navigationController) {
        UIViewController *vc = (__bridge UIViewController *)context;
        if ([vc isEqual:self.centerCarouselViewController]) {
            if ([observedKeyPaths containsObject:keyPath]) {
                NSUInteger indexOfChange = [observedKeyPaths indexOfObject:keyPath];
                switch (indexOfChange) {
                    case 0:
                        self.navigationItem.leftBarButtonItem = vc.navigationItem.leftBarButtonItem;
                        break;
                    case 1:
                        self.navigationItem.leftBarButtonItems = vc.navigationItem.leftBarButtonItems;
                        break;
                    case 2:
                        self.navigationItem.rightBarButtonItem = vc.navigationItem.rightBarButtonItem;
                        break;
                    case 3:
                        self.navigationItem.rightBarButtonItems = vc.navigationItem.rightBarButtonItems;
                        break;
                    case 4:
                        self.navigationItem.title = vc.navigationItem.title;
                        break;
                    case 5:
                        self.navigationItem.titleView = vc.navigationItem.titleView;
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

#pragma mark - Methods

- (void)setupInitialViewController:(UIViewController *)vc
{
    if (self.centerCarouselViewController) {
        if ([self.centerCarouselViewController isVisible]) {
            [self.centerCarouselViewController beginAppearanceTransition:NO animated:NO];
        }
        [self.centerCarouselViewController willMoveToParentViewController:nil];
        [self.centerCarouselViewController.view removeFromSuperview];
        if ([self.centerCarouselViewController isVisible]) {
            [self.centerCarouselViewController endAppearanceTransition];
        }
        [self.centerCarouselViewController removeFromParentViewController];
    }
    [self addChildViewController:vc];
    [self.carouselContentView addSubview:vc.view];
    if ([self.centerCarouselViewController isVisible]) {
        [vc beginAppearanceTransition:YES animated:NO];
        [vc endAppearanceTransition];
    }
    [vc didMoveToParentViewController:self];
    self.centerCarouselViewController = vc;
    self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:vc];
}

- (UIViewController *)carouselViewControllerAtIndex:(NSUInteger)index
{
    UIViewController *vc = [self.carouselViewControllers objectAtIndex:index];
    vc.view.frame = self.carouselContentView.bounds;
    if (!vc.isViewLoaded) {
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
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            float change = (translation.x / (self.view.bounds.size.width));
            change = (change > 1) ? 1 : ((change < -1) ? -1 : change);
            self.carouselTitleView.shiftPercentage = change;
            
            ScrollDirection currentDirection = [self scrollDirectionForTranslation:translation.x];
            BOOL shouldHideOppositeViewController = (currentDirection != self.lastScrollDirection && currentDirection != ScrollDirectionNone);
            self.lastScrollDirection = currentDirection;
            
            if (translation.x > 0) {
                if (self.carouselViewControllers.count > 2 && !self.leftCarouselViewController) {
                    self.leftCarouselViewController = [self leftCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                    self.leftCarouselViewController.view.userInteractionEnabled = NO;
                    [self.carouselContentView addSubview:self.leftCarouselViewController.view];
                    [self.carouselContentView sendSubviewToBack:self.leftCarouselViewController.view];
                }
                else if (!self.leftCarouselViewController) {
                    if (self.rightCarouselViewController) {
                        self.leftCarouselViewController = self.rightCarouselViewController;
                    }
                    else {
                        self.leftCarouselViewController = [self leftCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                        self.leftCarouselViewController.view.userInteractionEnabled = NO;
                        [self.carouselContentView addSubview:self.leftCarouselViewController.view];
                        [self.carouselContentView sendSubviewToBack:self.leftCarouselViewController.view];
                    }
                }
                if (shouldHideOppositeViewController && self.carouselViewControllers.count == 2) {
                    self.leftCarouselViewController.view.center = self.leftCarouselInitialCenter;
                    self.rightCarouselViewController = nil;
                }

                
                [UIView animateWithDuration:0.25f animations:^{
                    self.leftCarouselViewController.view.center = CGPointMake(self.leftCarouselInitialCenter.x + translation.x, self.leftCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
                    self.rightCarouselViewController.view.center = CGPointMake(self.rightCarouselInitialCenter.x + translation.x, self.rightCarouselInitialCenter.y);

                    [self.carouselTitleView layoutBasedOnPercentage];
                } completion:nil];
            }
            else if (translation.x < 0) {
                if (self.carouselViewControllers.count > 2 && !self.rightCarouselViewController) {
                    self.rightCarouselViewController = [self rightCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                    self.rightCarouselViewController.view.userInteractionEnabled = NO;
                    [self.carouselContentView addSubview:self.rightCarouselViewController.view];
                    [self.carouselContentView sendSubviewToBack:self.rightCarouselViewController.view];
                }
                else if (!self.rightCarouselViewController) {
                    if (self.leftCarouselViewController) {
                        self.rightCarouselViewController = self.leftCarouselViewController;
                    }
                    else {
                        self.rightCarouselViewController = [self rightCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                        self.rightCarouselViewController.view.userInteractionEnabled = NO;
                        [self.carouselContentView addSubview:self.rightCarouselViewController.view];
                        [self.carouselContentView sendSubviewToBack:self.rightCarouselViewController.view];
                    }
                }
                if (shouldHideOppositeViewController && self.carouselViewControllers.count == 2) {
                    self.rightCarouselViewController.view.center = self.rightCarouselInitialCenter;
                    self.leftCarouselViewController = nil;
                }

                [UIView animateWithDuration:0.25f animations:^{
                    self.rightCarouselViewController.view.center = CGPointMake(self.rightCarouselInitialCenter.x + translation.x, self.rightCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
                    self.leftCarouselViewController.view.center = CGPointMake(self.leftCarouselInitialCenter.x + translation.x, self.leftCarouselInitialCenter.y);

                    [self.carouselTitleView layoutBasedOnPercentage];
                } completion:nil];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (fabs(translation.x) > self.carouselContentView.bounds.size.width * self.percentageTranslationThreshold) {
                if (translation.x > 0) {
                    self.carouselTitleView.shiftPercentage = 1.0f;
                    
                    UIViewController *oldCenterViewController = self.centerCarouselViewController;
                    self.centerCarouselViewController = self.leftCarouselViewController;
                    
                    [oldCenterViewController willMoveToParentViewController:nil];
                    [oldCenterViewController beginAppearanceTransition:NO animated:YES];
                    [self addChildViewController:self.centerCarouselViewController];
                    [self.centerCarouselViewController beginAppearanceTransition:YES animated:YES];

                    [UIView animateWithDuration:0.3f animations:^{
                        oldCenterViewController.view.center = self.rightCarouselInitialCenter;
                        self.centerCarouselViewController.view.center = self.centerCarouselInitialCenter;
                        [self.carouselTitleView layoutBasedOnPercentage];
                    } completion:^(BOOL finished) {
                        [oldCenterViewController.view removeFromSuperview];
                        [oldCenterViewController endAppearanceTransition];
                        [oldCenterViewController removeFromParentViewController];
                        
                        [self.centerCarouselViewController endAppearanceTransition];
                        [self.centerCarouselViewController didMoveToParentViewController:self];

                        self.rightCarouselViewController = nil;
                        
                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.leftCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                        [self.carouselTitleView shiftRight];
                        if ([self.delegate respondsToSelector:@selector(carouselViewController:didChangeToIndex:)]) {
                            [self.delegate carouselViewController:self didChangeToIndex:self.indexOfCurrentCenterCarouselViewController];
                        }
                    }];
                }
                else if (translation.x < 0) {
                    self.carouselTitleView.shiftPercentage = -1.0f;
                    
                    UIViewController *oldCenterViewController = self.centerCarouselViewController;
                    self.centerCarouselViewController = self.rightCarouselViewController;

                    [oldCenterViewController willMoveToParentViewController:nil];
                    [oldCenterViewController beginAppearanceTransition:NO animated:YES];
                    [self addChildViewController:self.centerCarouselViewController];
                    [self.centerCarouselViewController beginAppearanceTransition:YES animated:YES];
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        oldCenterViewController.view.center = self.leftCarouselInitialCenter;
                        self.centerCarouselViewController.view.center = self.centerCarouselInitialCenter;
                        [self.carouselTitleView layoutBasedOnPercentage];
                    } completion:^(BOOL finished) {
                        [oldCenterViewController.view removeFromSuperview];
                        [oldCenterViewController endAppearanceTransition];
                        [oldCenterViewController removeFromParentViewController];
                        
                        [self.centerCarouselViewController endAppearanceTransition];
                        [self.centerCarouselViewController didMoveToParentViewController:self];
                        
                        self.leftCarouselViewController = nil;

                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.rightCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                        [self.carouselTitleView shiftLeft];
                        if ([self.delegate respondsToSelector:@selector(carouselViewController:didChangeToIndex:)]) {
                            [self.delegate carouselViewController:self didChangeToIndex:self.indexOfCurrentCenterCarouselViewController];
                        }
                    }];
                }
            }
            else {
                self.carouselTitleView.shiftPercentage = 0.0f;
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
                        self.leftCarouselViewController = nil;
                    }
                    if (self.rightCarouselViewController) {
                        [self.rightCarouselViewController.view removeFromSuperview];
                        self.rightCarouselViewController = nil;
                    }
                }];
            }
        }
            break;
        default:
            break;
    }
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return NO;
}

- (void)setCarouselViewControllers:(NSArray *)carouselViewControllers
{
    [_carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController *)obj;
        [self teardownNavigationItemObservationForViewController:vc];
    }];
    _carouselViewControllers = carouselViewControllers;
    
    NSMutableArray *carouselTitles = [NSMutableArray arrayWithCapacity:self.carouselViewControllers.count];
    [self.carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController *)obj;
        [self setupNavigationItemObservationForViewController:vc];
        [carouselTitles addObject:(vc.title.length > 0 ? vc.title : @"")];
    }];
    self.carouselTitles = [NSArray arrayWithArray:carouselTitles];
    
    self.carouselTitleView.carouselTitles = self.carouselTitles;
    
    NSUInteger indexToLoad = self.indexOfCurrentCenterCarouselViewController > (carouselViewControllers.count - 1) ? carouselViewControllers.count - 1 : self.indexOfCurrentCenterCarouselViewController;
    
    self.carouselTitleView.currentTitleIndex = indexToLoad;
    
    if ([self isViewLoaded] && self.centerCarouselViewController != [self.carouselViewControllers objectAtIndex:indexToLoad]) {
        [self setupInitialViewController:[self carouselViewControllerAtIndex:indexToLoad]];
    }
    
    if (self.carouselViewControllers.count > 1 && !self.panGestureRecognizer) {
        self.panGestureRecognizer = [[VGLimitedPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        self.panGestureRecognizer.percentageTranslationThreshold = self.percentageTranslationThreshold;
        [self.view addGestureRecognizer:self.panGestureRecognizer];
    }
    else if (self.carouselViewControllers.count == 1 && self.panGestureRecognizer) {
        [self.view removeGestureRecognizer:self.panGestureRecognizer];
        self.panGestureRecognizer = nil;
    }
}

- (void)setupNavigationItemObservationForViewController:(UIViewController *)aViewController
{
    [aViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItem" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
    [aViewController.navigationItem addObserver:self forKeyPath:@"leftBarButtonItems" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
    [aViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItem" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
    [aViewController.navigationItem addObserver:self forKeyPath:@"rightBarButtonItems" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
    [aViewController.navigationItem addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
    [aViewController.navigationItem addObserver:self forKeyPath:@"titleView" options:NSKeyValueObservingOptionNew context:(__bridge void *)(aViewController)];
}

- (void)teardownNavigationItemObservationForViewController:(UIViewController *)aViewController
{
    [aViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItem"];
    [aViewController.navigationItem removeObserver:self forKeyPath:@"leftBarButtonItems"];
    [aViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItem"];
    [aViewController.navigationItem removeObserver:self forKeyPath:@"rightBarButtonItems"];
    [aViewController.navigationItem removeObserver:self forKeyPath:@"title"];
    [aViewController.navigationItem removeObserver:self forKeyPath:@"titleView"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.centerCarouselViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.centerCarouselViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.centerCarouselViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.centerCarouselViewController endAppearanceTransition];
}

- (void)dealloc
{
    [self.carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vc = (UIViewController *)obj;
        [self teardownNavigationItemObservationForViewController:vc];
    }];
}

@end
