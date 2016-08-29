//
//  ChatPhotoView.h
//  dating
//
//  Created by test on 16/7/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatPhotoView;

@protocol ChatPhotoViewDelegate <NSObject>

- (NSInteger)itemCountInChatPhotoView:(ChatPhotoView * _Nonnull)chatPhotoView;
- (UIImage* _Nullable)chatPhotoView:(ChatPhotoView * _Nonnull)chatPhotoView shouldDisplayItem:(NSInteger)item;

@optional
- (void)chatPhotoView:(ChatPhotoView * _Nonnull)chatPhotoView didSelectItem:(NSInteger)item;

@end


@interface ChatPhotoView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet UICollectionView* _Nullable chatPhotoCollectionView;

@property (weak, nonatomic) IBOutlet KKCheckButton* _Nullable showDifferentStyleBtn;

/** 代理 */
@property (nonatomic,weak) id<ChatPhotoViewDelegate> _Nullable delegate;

/**
 * 元素个数
 */
@property (assign) NSInteger count;

+ (instancetype _Nullable)PhotoView:(id _Nullable)owner;

/**
 *  刷新界面
 */
- (void)reloadData;

- (void)reloadItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)array;

- (NSIndexPath * _Nullable)lastVisableIndex;

@end
