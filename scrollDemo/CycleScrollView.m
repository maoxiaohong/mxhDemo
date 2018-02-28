//
//  CycleScrollView.m
//  PagedScrollView
//
//  Created by 陈政 on 14-1-23.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//

#import "CycleScrollView.h"
#import "NSTimer+Addition.h"

@interface CycleScrollView () <UIScrollViewDelegate>

@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;

@property (nonatomic , assign) NSTimeInterval animationDuration;

@property (nonatomic, strong) UIPageControl *pageControl;

// add by yangxu
@property (nonatomic, strong) Class reuseClass;
// end

@end

@implementation CycleScrollView


- (void)dealloc
{
    if (_animationTimer) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _totalPageCount = totalPagesCount();
    if (_totalPageCount > 0) {
        // by yangxu
        self.scrollView.contentSize = CGSizeMake(_totalPageCount * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        [self configReuseViews];
        if (_totalPageCount > 1) {
            self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        }
        self.currentPageIndex = 0;
        self.pageControl.numberOfPages = _totalPageCount;
        // end
        [self configContentViews];
        if (_totalPageCount > 1) {
            [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
        }
    }
}

// yangxu
- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
    self.pageControl.currentPage = _currentPageIndex;
}

- (void)setShowPageControl:(BOOL)showPageControl
{
    self.pageControl.hidden = !showPageControl;
}

// end


- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration registerDisplayClass:(Class)reuseClass
{
    if (animationDuration > 0.0) {

        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.animationTimer pauseTimer];
        
    }
    self.reuseClass = reuseClass;
    
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        // yangxu
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 30, CGRectGetWidth(self.frame), 20)];
        self.showPageControl = YES;
        [self addSubview:self.pageControl];
        
        self.resuseViews = [[NSMutableArray alloc] initWithCapacity:0];
        // end
    }
    return self;
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
    }
    if (_totalPageCount > 1) {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
    if (_totalPageCount > 1) {
        NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        
        if (self.fetchContentViewAtIndex) {
            [self.contentViews addObject:self.fetchContentViewAtIndex(previousPageIndex)];
            [self.contentViews addObject:self.fetchContentViewAtIndex(_currentPageIndex)];
            [self.contentViews addObject:self.fetchContentViewAtIndex(rearPageIndex)];
        }
    } else {
        if (self.fetchContentViewAtIndex) {
            [self.contentViews addObject:self.fetchContentViewAtIndex(_currentPageIndex)];
        }
    }
}

// yangxu
- (void)configReuseViews
{
    if ([_resuseViews count] < _totalPageCount) {
        NSInteger count = _totalPageCount - [_resuseViews count];
        for (int i = 0; i < count; i++) {
            UIView *view = [[self.reuseClass alloc] initWithFrame:self.scrollView.bounds];
            [_resuseViews addObject:view];
        }
    }
    
    /*
    [_resuseViews removeAllObjects];
    for (int i = 0; i < _totalPageCount; i++) {
        UIView *view = [[self.reuseClass alloc] initWithFrame:self.scrollView.bounds];
        [_resuseViews addObject:view];
    }
     */
}
// end


- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_totalPageCount > 1) {
        [self.animationTimer pauseTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_totalPageCount > 1) {
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int contentOffsetX = scrollView.contentOffset.x;
    //    NSLog(@"%d", self.scrollView.contentSize.width);
    
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
        NSLog(@"next，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(self.scrollView.contentOffset.x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
//    [self.scrollView setContentOffset:newOffset animated:YES];
    [self.scrollView setContentOffset:newOffset animated:NO];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
*/

@end
