//
//  PullTableView.m
//  TableViewPull
//
//  Created by Emre Berge Ergenekon on 2011-07-30.
//  Copyright 2011 Emre Berge Ergenekon. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullTableView.h"

@interface PullTableView (Private) <UIScrollViewDelegate>
- (void) config;
- (void) configDisplayProperties;
@end

@implementation PullTableView

# pragma mark - Initialization / Deallocation

@synthesize pullDelegate;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self config];
}


- (void)dealloc {
    [pullArrowImage release];
    [pullBackgroundColor release];
    [pullTextColor release];
    [pullLastRefreshDate release];
    if(refreshView){
        [refreshView release];
    }
    if(loadMoreView){
        [loadMoreView release];
    }
    [delegateInterceptor release];
    delegateInterceptor = nil;
    [super dealloc];
}

# pragma mark - Custom view configuration

- (void) config
{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    
    // set
//    _hasRefreshView = YES;
//    _hasLoadingMoreView = YES;
    
    /* Status Properties */
    pullTableIsRefreshing = NO;
    pullTableIsLoadingMore = NO;
    
    /* Refresh View */
//    refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
//    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//    refreshView.delegate = self;
//    [self addSubview:refreshView];
    [self reloadRefreshView];
    /* Load more view init */
//    loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
//    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    loadMoreView.delegate = self;
//    [self addSubview:loadMoreView];
    [self reloadLoadMoreView];
}

#pragma mark - refreshView create

- (void)reloadRefreshView{
    if(_hasRefreshView && !refreshView){
        refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        refreshView.delegate = self;
        [self addSubview:refreshView];
    }else if(!_hasRefreshView && refreshView){
        refreshView.delegate = nil;
        [refreshView removeFromSuperview];
        [refreshView release];
        refreshView = nil;
    }
}

#pragma mark - loadMoreView create
- (void)reloadLoadMoreView{
    if(_hasLoadingMoreView && !loadMoreView){
        loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
        loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        loadMoreView.delegate = self;
        [self addSubview:loadMoreView];
    }else if(!_hasLoadingMoreView && loadMoreView){
        loadMoreView.delegate = nil;
        [loadMoreView removeFromSuperview];
        [loadMoreView release];
        loadMoreView = nil;
    }
}

# pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(!_hasLoadingMoreView){
        return;
    }
    CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
    
    CGRect loadMoreFrame = loadMoreView.frame;
    loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
    loadMoreView.frame = loadMoreFrame;
}

#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if(delegateInterceptor) {
        super.delegate = nil;
        delegateInterceptor.receiver = delegate;
        super.delegate = (id)delegateInterceptor;
    } else {
        super.delegate = delegate;
    }
}

- (void)reloadData
{
    [super reloadData];
    // Give the footers a chance to fix it self.
    if(_hasLoadingMoreView){
        [loadMoreView egoRefreshScrollViewDidScroll:self];
    }
}

#pragma mark - Status Propreties

@synthesize pullTableIsRefreshing;
@synthesize pullTableIsLoadingMore;

- (void)setPullTableIsRefreshing:(BOOL)isRefreshing
{
    if(!_hasRefreshView){
        return;
    }
    if(!pullTableIsRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [refreshView startAnimatingWithScrollView:self];
        pullTableIsRefreshing = YES;
    } else if(pullTableIsRefreshing && !isRefreshing) {
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsRefreshing = NO;
    }
}

- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!_hasLoadingMoreView){
        return;
    }
    if(!pullTableIsLoadingMore && isLoadingMore) {
        // If not allready loading more start refreshing
        [loadMoreView startAnimatingWithScrollView:self];
        pullTableIsLoadingMore = YES;
    } else if(pullTableIsLoadingMore && !isLoadingMore) {
        [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsLoadingMore = NO;
    }
}

- (void)setHasRefreshView:(BOOL)hasRefreshView{
    _hasRefreshView = hasRefreshView;
    [self reloadRefreshView];
}

- (void)setHasLoadingMoreView:(BOOL)hasLoadingMoreView{
    _hasLoadingMoreView = hasLoadingMoreView;
    [self reloadLoadMoreView];
}
#pragma mark - Display properties

@synthesize pullArrowImage;
@synthesize pullBackgroundColor;
@synthesize pullTextColor;
@synthesize pullLastRefreshDate;

- (void)configDisplayProperties
{
    if(_hasRefreshView){
        [refreshView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    }
    if(_hasLoadingMoreView){
        [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    }
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage
{
    if(aPullArrowImage != pullArrowImage) {
        [pullArrowImage release];
        pullArrowImage = [aPullArrowImage retain];
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor
{
    if(aColor != pullBackgroundColor) {
        [pullBackgroundColor release];
        pullBackgroundColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullTextColor:(UIColor *)aColor
{
    if(aColor != pullTextColor) {
        [pullTextColor release];
        pullTextColor = [aColor retain];
        [self configDisplayProperties];
    } 
}

- (void)setPullLastRefreshDate:(NSDate *)aDate
{
    if(aDate != pullLastRefreshDate) {
        [pullLastRefreshDate release];
        pullLastRefreshDate = [aDate retain];
        if(_hasRefreshView){
            [refreshView refreshLastUpdatedDate];
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_hasRefreshView){
        [refreshView egoRefreshScrollViewDidScroll:scrollView];
    }
    if(_hasLoadingMoreView){
        [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidScroll:)]) {
        if(delegateInterceptor.receiver != self){
            [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_hasRefreshView){
        [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if(_hasLoadingMoreView){
        [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        if(delegateInterceptor.receiver != self)
            [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(_hasRefreshView){
        [refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
    }
    
    // Also forward the message to the real delegate
    if ([delegateInterceptor.receiver
         respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        if(delegateInterceptor.receiver != self)
            [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
    }
}



#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    pullTableIsRefreshing = YES;
    if([pullDelegate respondsToSelector:@selector(pullTableViewDidTriggerRefresh:)]){
        [pullDelegate pullTableViewDidTriggerRefresh:self];
    }
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
    return self.pullLastRefreshDate;
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    pullTableIsLoadingMore = YES;
    if([pullDelegate respondsToSelector:@selector(pullTableViewDidTriggerLoadMore:)]){
        [pullDelegate pullTableViewDidTriggerLoadMore:self];
    }
}


@end
