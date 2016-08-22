//
//  BWDCycleScrollView.h
//  BWDApp
//
//  Created by forr on 15/8/11.
//  Copyright (c) 2015年 Kratos. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BTCycleScrollViewDelegate;



@interface BTCycleScrollView : UIView

/**
 存放网络图片地址集,更新网络图片只需对该数组重新赋值即可。
 支持本地图片,!!!但必需设置isLocalImageUrl属性
 */
@property (nonatomic,strong) NSMutableArray *imageUrlStrings;
/**
 代理
 */
@property (nonatomic,weak) id<BTCycleScrollViewDelegate> delegate;
/**
 是否自动滚动，默认是
 */
@property (nonatomic,assign) BOOL autoScroll;
/**
 是否无限循环，默认是
 */
@property (nonatomic,assign) BOOL infiniteLoop;
/**
 是否本地图片，不是则网络图片，默认否
 */
@property (nonatomic,assign) BOOL localImageUrl;

/**
 加载时默认占位图
 */
@property (nonatomic,copy) NSString *placeholderImageName;

/**
 初始化方法
 @param frame 位置大小
 @param imageUrlStrings 图片地址
 @param isLocalImageUrl 是否本地图片，不是则为网络图片
 @return 返回本实例对象
 */
+ (instancetype )cycleScrollViewWithFrame:(CGRect )frame
                          imageUrlStrings:(NSArray *)imageUrlStrings
                          localImageUrl:(BOOL )localImageUrl;


@end

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>协议<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

@protocol BTCycleScrollViewDelegate <NSObject>
/**
 点击图片时后回调
 @param cycleScrollView 本对象
 @param index           被选中图片的下标
 */
-(void)cycleScrollView:(BTCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger )index;

@end


