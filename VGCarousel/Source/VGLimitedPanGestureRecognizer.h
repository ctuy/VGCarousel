//
//  VGLimitedPanGestureRecognizer.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 10/22/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VGLimitedPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) CGFloat percentageTranslationThreshold;

@end
