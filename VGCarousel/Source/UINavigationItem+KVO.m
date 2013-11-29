//
//  UINavigationItem+KVO.m
//  VGCarousel
//
//  Created by Charles Joseph Uy on 11/29/13.
//  Copyright (c) 2013 Charles Joseph Uy. All rights reserved.
//

#import "UINavigationItem+KVO.h"

#import <objc/runtime.h>

// Source: https://gist.github.com/brentdax/5938102

@implementation UINavigationItem (KVO)

- (void)fdr_setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    [self willChangeValueForKey:@"leftBarButtonItems"];
    
    [self fdr_setLeftBarButtonItem:leftBarButtonItem];
    
    [self didChangeValueForKey:@"leftBarButtonItems"];
}

- (void)fdr_setLeftBarButtonItems:(NSArray *)leftBarButtonItems {
    [self willChangeValueForKey:@"leftBarButtonItem"];
    
    [self fdr_setLeftBarButtonItems:leftBarButtonItems];
    
    [self didChangeValueForKey:@"leftBarButtonItem"];
}

- (void)fdr_setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [self willChangeValueForKey:@"leftBarButtonItem"];
    [self willChangeValueForKey:@"leftBarButtonItems"];
    
    [self fdr_setLeftBarButtonItem:item animated:animated];
    
    [self didChangeValueForKey:@"leftBarButtonItems"];
    [self didChangeValueForKey:@"leftBarButtonItem"];
}

- (void)fdr_setLeftBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    [self willChangeValueForKey:@"leftBarButtonItem"];
    [self willChangeValueForKey:@"leftBarButtonItems"];
    
    [self fdr_setLeftBarButtonItems:items animated:animated];
    
    [self didChangeValueForKey:@"leftBarButtonItems"];
    [self didChangeValueForKey:@"leftBarButtonItem"];
}

- (void)fdr_setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    [self willChangeValueForKey:@"rightBarButtonItems"];
    
    [self fdr_setRightBarButtonItem:rightBarButtonItem];
    
    [self didChangeValueForKey:@"rightBarButtonItems"];
}

- (void)fdr_setRightBarButtonItems:(NSArray *)rightBarButtonItems {
    [self willChangeValueForKey:@"rightBarButtonItem"];
    
    [self fdr_setRightBarButtonItems:rightBarButtonItems];
    
    [self didChangeValueForKey:@"rightBarButtonItem"];
}

- (void)fdr_setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated {
    [self willChangeValueForKey:@"rightBarButtonItem"];
    [self willChangeValueForKey:@"rightBarButtonItems"];
    
    [self fdr_setRightBarButtonItem:item animated:animated];
    
    [self didChangeValueForKey:@"rightBarButtonItems"];
    [self didChangeValueForKey:@"rightBarButtonItem"];
}

- (void)fdr_setRightBarButtonItems:(NSArray *)items animated:(BOOL)animated {
    [self willChangeValueForKey:@"rightBarButtonItem"];
    [self willChangeValueForKey:@"rightBarButtonItems"];
    
    [self fdr_setRightBarButtonItems:items animated:animated];
    
    [self didChangeValueForKey:@"rightBarButtonItems"];
    [self didChangeValueForKey:@"rightBarButtonItem"];
}

- (void)fdr_setTitle:(NSString *)title
{
    [self willChangeValueForKey:@"title"];
    
    [self fdr_setTitle:title];
    
    [self didChangeValueForKey:@"title"];
}

- (void)fdr_setTitleView:(UIView *)titleView
{
    [self willChangeValueForKey:@"titleView"];
    
    [self fdr_setTitleView:titleView];
    
    [self didChangeValueForKey:@"titleView"];
}

+ (void)fdr_swizzle:(SEL)aSelector {
    SEL bSelector = NSSelectorFromString([NSString stringWithFormat:@"fdr_%@", NSStringFromSelector(aSelector)]);
    
    Method aMethod = class_getInstanceMethod(self, aSelector);
    Method bMethod = class_getInstanceMethod(self, bSelector);
    method_exchangeImplementations(aMethod, bMethod);
}


+ (void)load {
    [self fdr_swizzle:@selector(setLeftBarButtonItem:)];
    [self fdr_swizzle:@selector(setLeftBarButtonItems:)];
    [self fdr_swizzle:@selector(setLeftBarButtonItem:animated:)];
    [self fdr_swizzle:@selector(setLeftBarButtonItems:animated:)];
    [self fdr_swizzle:@selector(setRightBarButtonItem:)];
    [self fdr_swizzle:@selector(setRightBarButtonItems:)];
    [self fdr_swizzle:@selector(setRightBarButtonItem:animated:)];
    [self fdr_swizzle:@selector(setRightBarButtonItems:animated:)];
    [self fdr_swizzle:@selector(setTitle:)];
    [self fdr_swizzle:@selector(setTitleView:)];
}

@end
