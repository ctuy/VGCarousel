//
//  VGAppDelegate.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGAppDelegate.h"
#import "VGCarouselViewController.h"
#import "VGTestViewController.h"

@interface VGAppDelegate () <VGTestViewControllerDelegate>

@property (nonatomic, strong) VGCarouselViewController *carouselVC;
@property (nonatomic, strong) NSArray *contentVCs;

@end

@implementation VGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    
    VGTestViewController *controllerA = [[VGTestViewController alloc] initWithNibName:nil bundle:nil];
    controllerA.title = NSLocalizedString(@"VC1", @"");
    controllerA.loadBackgroundColor = [UIColor grayColor];
    controllerA.delegate = self;
    [viewControllers addObject:controllerA];

    VGTestViewController *controllerB = [[VGTestViewController alloc] initWithNibName:nil bundle:nil];
    controllerB.title = NSLocalizedString(@"VC2", @"");
    controllerB.loadBackgroundColor = [UIColor lightGrayColor];
    controllerB.delegate = self;
    [viewControllers addObject:controllerB];
    
    VGTestViewController *controllerC = [[VGTestViewController alloc] initWithNibName:nil bundle:nil];
    controllerC.title = NSLocalizedString(@"VC3", @"");
    controllerC.loadBackgroundColor = [UIColor orangeColor];
    controllerC.delegate = self;
//    [viewControllers addObject:controllerC];
    
    VGTestViewController *controllerD = [[VGTestViewController alloc] initWithNibName:nil bundle:nil];
    controllerD.title = NSLocalizedString(@"VC4", @"");
    controllerD.loadBackgroundColor = [UIColor purpleColor];
    controllerD.delegate = self;
//    [viewControllers addObject:controllerD];
    
    self.contentVCs = [NSArray arrayWithArray:viewControllers];

    self.carouselVC = [[VGCarouselViewController alloc] initWithViewControllers:self.contentVCs];
#if 1
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.carouselVC];
    self.window.rootViewController = navigationController;
#else
    self.window.rootViewController = carouselVC;
#endif
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - VGTestViewControllerDelegate

- (void)testViewControllerTappedPlus:(VGTestViewController *)testViewController
{
    if (self.carouselVC.carouselViewControllers.count < self.contentVCs.count) {
        self.carouselVC.carouselViewControllers = [self.carouselVC.carouselViewControllers arrayByAddingObject:[self.contentVCs objectAtIndex:self.carouselVC.carouselViewControllers.count]];
    }
}

- (void)testViewControllerTappedMinus:(VGTestViewController *)testViewController
{
    if (self.carouselVC.carouselViewControllers.count > 1) {
        self.carouselVC.carouselViewControllers = [self.carouselVC.carouselViewControllers subarrayWithRange:NSMakeRange(0, self.carouselVC.carouselViewControllers.count - 1)];
    }
}

@end
