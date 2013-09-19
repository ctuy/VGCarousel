//
//  VGCarouselViewController.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGCarouselViewController.h"

@interface VGCarouselViewController ()

@property (nonatomic, strong) NSArray *carouselViewControllers;

@property (nonatomic, strong) NSArray *carouselTitles;
@property (nonatomic, strong) UIView *carouselTitleView;
@property (nonatomic, strong) NSArray *carouselTitleLabels;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupInitialViewController:[self carouselViewControllerAtIndex:0]];
    
    self.centerCarouselInitialCenter = CGPointMake(CGRectGetMidX(self.carouselContentView.bounds), CGRectGetMidY(self.carouselContentView.bounds));
    self.leftCarouselInitialCenter = CGPointMake(-self.carouselContentView.bounds.size.width / 2, self.centerCarouselInitialCenter.y);
    self.rightCarouselInitialCenter = CGPointMake(self.carouselContentView.bounds.size.width + self.carouselContentView.bounds.size.width / 2, self.centerCarouselInitialCenter.y);
}

- (void)setupInitialViewController:(UIViewController *)vc
{
    [self addChildViewController:vc];
    [self.carouselContentView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    self.centerCarouselViewController = vc;
    self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:vc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.carouselViewControllers = viewControllers;
    }
    return self;
}

- (NSUInteger)nextIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems
{
    return (index + 1) % numberOfItems;
}

- (NSUInteger)previousIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems
{
    if (index == 0) {
        return (numberOfItems - 1);
    }
    else {
        return index - 1;
    }
}

- (NSArray *)visibleTitlesAtIndex:(NSUInteger)index
{
    NSAssert(index < self.carouselTitles.count, @"Index out of range");
    if (self.carouselTitles.count == 1) {
        return [NSArray arrayWithObject:self.carouselTitles[index]];
    }
    else {
        NSString *center = self.carouselTitles[index];
        NSString *left = self.carouselTitles[[self previousIndexOfIndex:index numberOfItems:self.carouselTitles.count]];
        NSString *right = self.carouselTitles[[self nextIndexOfIndex:index numberOfItems:self.carouselTitles.count]];
        return [NSArray arrayWithObjects:left, center, right, nil];
    }
}

- (void)loadView
{
    CGRect viewFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    self.view.backgroundColor = [UIColor redColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.carouselTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20.0f, viewFrame.size.width, 40.0f)];
    self.carouselTitleView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.carouselTitleView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.carouselContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 60.0f, viewFrame.size.width, viewFrame.size.height - 40.0f)];
    self.carouselContentView.backgroundColor = [UIColor yellowColor];
    self.carouselContentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.carouselContentView];
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
    NSUInteger leftIndex = [self previousIndexOfIndex:index numberOfItems:self.carouselViewControllers.count];
    UIViewController *vc = [self carouselViewControllerAtIndex:leftIndex];
    vc.view.center = self.leftCarouselInitialCenter;;
    return vc;
}

- (UIViewController *)rightCarouselViewControllerOfViewControllerAtIndex:(NSUInteger)index
{
    NSUInteger rightIndex = [self nextIndexOfIndex:index numberOfItems:self.carouselViewControllers.count];
    UIViewController *vc = [self carouselViewControllerAtIndex:rightIndex];
    vc.view.center = self.rightCarouselInitialCenter;
    return vc;
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [panGestureRecognizer translationInView:self.view];
//    NSLog(@"translation = %@", CGPointCreateDictionaryRepresentation(translation));
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.centerCarouselViewController.view.userInteractionEnabled = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (translation.x > 0) {
                if (!self.leftCarouselViewController) {
                    self.leftCarouselViewController = [self leftCarouselViewControllerOfViewControllerAtIndex:self.indexOfCurrentCenterCarouselViewController];
                    [self addChildViewController:self.leftCarouselViewController];
                    self.leftCarouselViewController.view.userInteractionEnabled = NO;
                    [self.carouselContentView addSubview:self.leftCarouselViewController.view];
                    self.leftCarouselViewControllerTriggeredDidMove = NO;
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.leftCarouselViewController.view.center = CGPointMake(self.leftCarouselInitialCenter.x + translation.x, self.leftCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
                } completion:^(BOOL finished) {
                    if (!self.leftCarouselViewControllerTriggeredDidMove) {
                        [self.leftCarouselViewController didMoveToParentViewController:self];
                        self.leftCarouselViewControllerTriggeredDidMove = YES;
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
                }
                [UIView animateWithDuration:0.25f animations:^{
                    self.rightCarouselViewController.view.center = CGPointMake(self.rightCarouselInitialCenter.x + translation.x, self.rightCarouselInitialCenter.y);
                    self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);                    
                } completion:^(BOOL finished) {
                    if (!self.rightCarouselViewControllerTriggeredDidMove) {
                        [self.rightCarouselViewController didMoveToParentViewController:self];
                        self.rightCarouselViewControllerTriggeredDidMove = YES;
                    }
                }];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (fabs(translation.x) > self.carouselContentView.bounds.size.width * 0.4) {
                if (translation.x > 0) {
                    // left becomes center
                    [self.centerCarouselViewController willMoveToParentViewController:nil];
                    [UIView animateWithDuration:0.3f animations:^{
                        self.centerCarouselViewController.view.center = self.rightCarouselInitialCenter;
                        self.leftCarouselViewController.view.center = self.centerCarouselInitialCenter;
                    } completion:^(BOOL finished) {
                        [self.centerCarouselViewController.view removeFromSuperview];
                        [self.centerCarouselViewController removeFromParentViewController];
                        
                        self.centerCarouselViewController = self.leftCarouselViewController;
                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.leftCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                    }];
                }
                else if (translation.x < 0) {
                    [self.centerCarouselViewController willMoveToParentViewController:nil];
                    [UIView animateWithDuration:0.3f animations:^{
                        self.centerCarouselViewController.view.center = self.leftCarouselInitialCenter;
                        self.rightCarouselViewController.view.center = self.centerCarouselInitialCenter;
                    } completion:^(BOOL finished) {
                        [self.centerCarouselViewController.view removeFromSuperview];
                        [self.centerCarouselViewController removeFromParentViewController];
                        
                        self.centerCarouselViewController = self.rightCarouselViewController;
                        self.indexOfCurrentCenterCarouselViewController = [self.carouselViewControllers indexOfObject:self.centerCarouselViewController];
                        self.rightCarouselViewController = nil;
                        self.centerCarouselViewController.view.userInteractionEnabled = YES;
                    }];
                }
            }
            else {
                if (self.leftCarouselViewController) {
                    [self.leftCarouselViewController willMoveToParentViewController:nil];
                }
                if (self.rightCarouselViewController) {
                    [self.rightCarouselViewController willMoveToParentViewController:nil];
                }
                [UIView animateWithDuration:0.3f animations:^{
                    self.centerCarouselViewController.view.center = self.centerCarouselInitialCenter;
                    if (self.leftCarouselViewController) {
                        self.leftCarouselViewController.view.center = self.leftCarouselInitialCenter;
                    }
                    if (self.rightCarouselViewController) {
                        self.rightCarouselViewController.view.center = self.rightCarouselInitialCenter;
                    }
                } completion:^(BOOL finished) {
                    self.centerCarouselViewController.view.userInteractionEnabled = YES;
                    if (self.leftCarouselViewController) {
                        [self.leftCarouselViewController.view removeFromSuperview];
                        [self.leftCarouselViewController removeFromParentViewController];
                        self.leftCarouselViewController = nil;
                    }
                    if (self.rightCarouselViewController) {
                        [self.rightCarouselViewController.view removeFromSuperview];
                        [self.rightCarouselViewController removeFromParentViewController];
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

@end
