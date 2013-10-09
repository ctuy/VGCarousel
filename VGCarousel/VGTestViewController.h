//
//  VGTestViewController.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/18/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VGTestViewController;

@protocol VGTestViewControllerDelegate <NSObject>

- (void)testViewControllerTappedPlus:(VGTestViewController *)testViewController;
- (void)testViewControllerTappedMinus:(VGTestViewController *)testViewController;

@end

@interface VGTestViewController : UIViewController

@property (nonatomic, strong) UIColor *loadBackgroundColor;
@property (nonatomic) BOOL enableLogging;
@property (nonatomic, assign) id <VGTestViewControllerDelegate> delegate;

@end
