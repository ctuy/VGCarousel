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
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"%@:%@", self.title, NSStringFromSelector(_cmd));
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent);
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    NSLog(@"%@:%@:%@", self.title, NSStringFromSelector(_cmd), parent);
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
