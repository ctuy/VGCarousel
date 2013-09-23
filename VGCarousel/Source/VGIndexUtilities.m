//
//  VGIndexUtilities.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/20/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "VGIndexUtilities.h"

@implementation VGIndexUtilities

+ (NSUInteger)nextIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems
{
    return (index + 1) % numberOfItems;
}

+ (NSUInteger)previousIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems
{
    if (index == 0) {
        return (numberOfItems - 1);
    }
    else {
        return index - 1;
    }
}

@end
