//
//  BWDCycleScrollView.m
//  BWDApp
//
//  Created by forr on 15/8/11.
//  Copyright (c) 2015年 Kratos. All rights reserved.
//

#import "BTCycleScrollView.h"
#import "UIImageView+WebCache.h"


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>内部类Cell<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
NSString * const kCollectionViewCellIdentifier = @"KCOLLECTIONVIEWCELLIDENTIFIER";

@interface BWDCollectionViewCell:UICollectionViewCell
@property(strong,nonatomic)UIImageView *imageView;
@end

@implementation BWDCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end


//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>BWDCycleScrollView<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

@interface BTCycleScrollView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (assign, nonatomic) NSInteger totalItemsCount;//单元格总数
@property (weak, nonatomic)   NSTimer *timer;
@end

@implementation BTCycleScrollView

#pragma mark -lefe cycle-

+ (instancetype )cycleScrollViewWithFrame:(CGRect )frame
                          imageUrlStrings:(NSArray *)imageUrlStrings
                            localImageUrl:(BOOL )localImageUrl
{
    BTCycleScrollView *cycleScrollView = [[self alloc]initWithFrame:frame];
    
    cycleScrollView.imageUrlStrings = [NSMutableArray arrayWithArray:imageUrlStrings];
    cycleScrollView.localImageUrl = localImageUrl;
    [cycleScrollView setupParas];
    [cycleScrollView setupCollectionView];
    [cycleScrollView setupPageControl];
    return cycleScrollView;
}

- (void)setupParas
{
    self.autoScroll = YES;
    self.infiniteLoop = YES;
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGRect frame = self.bounds;
    _collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:[BWDCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self addSubview:_collectionView];
}

-(void)setupPageControl
{
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0,CGRectGetHeight(self.bounds)-40, CGRectGetWidth(self.bounds), 30)];
    _pageControl.numberOfPages = self.imageUrlStrings.count;
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    [self bringSubviewToFront:_pageControl];
    [self addSubview:_pageControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_infiniteLoop)
    {
        //若无限循环则在中间处开始滚动
        NSInteger num = _totalItemsCount * 0.5;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:num inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark -collectionViewDelegate Methods-
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BWDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                            forIndexPath:indexPath];
    NSInteger num = indexPath.item % self.imageUrlStrings.count;
    if (self.localImageUrl)
    {
        cell.imageView.image = [UIImage imageNamed:self.imageUrlStrings[num]];
    }
    else
    {
        [cell.imageView fadeImageWithUrl:self.imageUrlStrings[num]];
        
//        [cell.imageView sd_setImageWithURL:self.imageUrlStrings[num]
//                          placeholderImage:[UIImage imageNamed:self.placeholderImageName]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleScrollView:didSelectItemAtIndex:)])
    {
        [self.delegate cycleScrollView:self didSelectItemAtIndex:indexPath.item % self.imageUrlStrings.count];
    }
}

#pragma mark -scrollviewDelegate Methods-
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int itemIndex = scrollView.contentOffset.x  / self.bounds.size.width;
    int indexOnPageControl = itemIndex % self.imageUrlStrings.count;
    _pageControl.currentPage = indexOnPageControl;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_autoScroll)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_autoScroll)
    {
        [self setupTimer];
    }
}

#pragma mark -setter gettter Methods-
- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
    [_timer invalidate];
    _timer = nil;
    
    if (_autoScroll)
    {
        [self setupTimer];
    }
}

- (void)setInfiniteLoop:(BOOL)infiniteLoop
{
    _infiniteLoop = infiniteLoop;
    _totalItemsCount = _infiniteLoop?_imageUrlStrings.count*10000:_imageUrlStrings.count;
}

- (void)setImageUrlStrings:(NSMutableArray *)imageUrlStrings
{
    _imageUrlStrings = imageUrlStrings;
    _pageControl.numberOfPages = imageUrlStrings.count;
    [_collectionView reloadData];
}

#pragma mark -private Methods-
/**开启定时器,实现自动滚动图片*/
- (void)setupTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                              target:self
                                            selector:@selector(automaticScroll)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

//图片滚动操作
- (void)automaticScroll
{
    int currentIndex = _collectionView.contentOffset.x / self.bounds.size.width;
    int targetIndex = currentIndex + 1;
    //滚动结束时重置当前页为第0页
    if (targetIndex == _totalItemsCount)
    {
        if (self.infiniteLoop)
        {
            targetIndex = _totalItemsCount * 0.5;
        }
        else
        {
            targetIndex = 0;
        }
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
