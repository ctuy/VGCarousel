//
//  VGIndexUtilities.h
//  VGCarousel
//
//  Created by Charles Joseph Uy on 9/20/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VGIndexUtilities : NSObject

+ (NSUInteger)nextIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems;
+ (NSUInteger)previousIndexOfIndex:(NSUInteger)index numberOfItems:(NSUInteger)numberOfItems;

@end
