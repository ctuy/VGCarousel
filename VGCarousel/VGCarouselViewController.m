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
@property (nonatomic) CGPoint centerCarouselInitialCenter;

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
    UIViewController *firstViewController = self.carouselViewControllers[0];
    [self addChildViewController:firstViewController];
    [self.carouselContentView addSubview:firstViewController.view];
    firstViewController.view.frame = self.carouselContentView.bounds;
    [firstViewController didMoveToParentViewController:self];
    self.centerCarouselViewController = firstViewController;
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
        NSMutableArray *carouselTitles = [NSMutableArray arrayWithCapacity:self.carouselViewControllers.count];
        [self.carouselViewControllers enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *vc = (UIViewController *)obj;
            [carouselTitles addObject:(vc.title.length > 0 ? vc.title : @"")];
        }];
        self.carouselTitles = [NSArray arrayWithArray:carouselTitles];
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
    self.carouselTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 20.0f, viewFrame.size.width, 40.0f)];
    self.carouselTitleView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.carouselTitleView];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    self.carouselContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 60.0f, viewFrame.size.width, viewFrame.size.height - 40.0f)];
    self.carouselContentView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.carouselContentView];
}

- (void)handlePanGesture:(UIGestureRecognizer *)gestureRecognizer
{
    // at initial
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [panGestureRecognizer translationInView:self.view];    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.centerCarouselInitialCenter = self.centerCarouselViewController.view.center;
            // load left and right view controllers
            // disable user interaction on all controllers
            self.centerCarouselViewController.view.userInteractionEnabled = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.centerCarouselViewController.view.center = CGPointMake(self.centerCarouselInitialCenter.x + translation.x, self.centerCarouselInitialCenter.y);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:0.3f animations:^{
                self.centerCarouselViewController.view.center = self.centerCarouselInitialCenter;
            } completion:^(BOOL finished) {
                self.centerCarouselViewController.view.userInteractionEnabled = YES;
            }];
        }
            break;
        default:
            break;
    }
    NSLog(@"translation = %@", CGPointCreateDictionaryRepresentation(translation));
}

@end
