//
//  VGTestViewController.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGTestViewController.h"

@interface VGTestViewController ()

@end

@implementation VGTestViewController

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
    self.view.backgroundColor = self.loadBackgroundColor;
	// Do any additional setup after loading the view.
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), self);
    }
    
    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [plusButton setTitle:@"+" forState:UIControlStateNormal];
    [plusButton sizeToFit];
    plusButton.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 4, CGRectGetMidY(self.view.bounds));
    [plusButton addTarget:self action:@selector(tappedPlus:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plusButton];
    
    UIButton *minusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [minusButton setTitle:@"-" forState:UIControlStateNormal];
    [minusButton sizeToFit];
    minusButton.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 3 / 4, CGRectGetMidY(self.view.bounds));
    [minusButton addTarget:self action:@selector(tappedMinus:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:minusButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), self);
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.title style:UIBarButtonItemStyleBordered target:self action:@selector(tappedRight:)];
    if ([self.title isEqualToString:@"VC2"]) {
        self.navigationItem.title = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), self);
    }
}

- (void)tappedRight:(id)sender
{
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), self);
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), self);
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent, self);
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (self.enableLogging) {
        NSLog(@"%@:%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent, self);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            self.view.backgroundColor = self.loadBackgroundColor;
        }];
    }];
}

- (void)tappedPlus:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(testViewControllerTappedPlus:)]) {
        [self.delegate testViewControllerTappedPlus:self];
    }
}

- (void)tappedMinus:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(testViewControllerTappedMinus:)]) {
        [self.delegate testViewControllerTappedMinus:self];
    }
}

@end
