//
//  VGTestViewController.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGTestViewController.h"

#define NSLOGGING   0

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
#if NSLOGGING
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#if NSLOGGING
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#if NSLOGGING
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
#if NSLOGGING
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
#if NSLOGGING
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
#endif
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
#if NSLOGGING
    NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent);
#endif
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
#if NSLOGGING
    NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent);
#endif
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

@end
