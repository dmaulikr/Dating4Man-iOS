//
//  ChatEmotionChooseView.h
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatEmotion.h"

@class ChatEmotionChooseView;
@protocol ChatEmotionChooseViewDelegate <NSObject>
@optional
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectItem:(NSInteger)item;
@end

@interface ChatEmotionChooseView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

/**
 *  事件回调
 */
@property (weak) id<ChatEmotionChooseViewDelegate> delegate;

/**
 *  表情选择控件
 */
@property (weak) IBOutlet UICollectionView* emotionCollectionView;

/**
 *  表情数组
 */
@property (retain) NSArray<ChatEmotion*>* emotions;
@property (weak, nonatomic) IBOutlet UIPageControl *pageView;

/**
 *  生成实例
 *
 *  @return <#return value description#>
 */
+ (instancetype)emotionChooseView:(id)owner;

/**
 *  刷新界面
 */
- (void)reloadData;

@end
