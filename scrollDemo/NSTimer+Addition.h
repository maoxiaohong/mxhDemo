//
//  NSTimer+Addition.h
//  PagedScrollView
//
//  Created by 茅晓宏 on 14-1-24.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
// 5555

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)

- (void)pauseTimer;
- (void)resumeTimer;
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
