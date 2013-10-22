//
//  VGLimitedPanGestureRecognizer.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 10/22/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGLimitedPanGestureRecognizer.h"

@implementation VGLimitedPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [self translationInView:self.view];
        if (fabs(translation.x) > self.view.bounds.size.width * self.percentageTranslationThreshold) {
            self.state = UIGestureRecognizerStateEnded;
        }
    }
}

@end
