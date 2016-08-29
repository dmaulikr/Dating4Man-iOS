//
//  ChatPhotoView.m
//  dating
//
//  Created by test on 16/7/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatPhotoView.h"
#import "ChatPhotoCollectionViewCell.h"

@implementation ChatPhotoView


+ (instancetype)PhotoView:(id)owner{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatPhotoView" owner:owner options:nil];
    ChatPhotoView* view = [nibs objectAtIndex:0];

    // 设置布局样式
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
//    CGFloat itemSize = [UIScreen mainScreen].bounds.size.width / 3;
//    flowlayout.itemSize = CGSizeMake(itemSize, itemSize);
    flowlayout.itemSize = CGSizeMake(150, 150);
    flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    flowlayout.sectionInset = UIEdgeInsetsMake(0, 0, 46, 0);
    view.chatPhotoCollectionView.collectionViewLayout = flowlayout;
    
    UINib *nib = [UINib nibWithNibName:@"ChatPhotoCollectionViewCell" bundle:nil];
    [view.chatPhotoCollectionView registerNib:nib forCellWithReuseIdentifier:[ChatPhotoCollectionViewCell cellIdentifier]];
    
    return view;
}

- (void)reloadData{
    [self.chatPhotoCollectionView reloadData];

}

- (void)reloadItemsAtIndexPaths:(nonnull NSArray<NSIndexPath *> *)array {
    [self.chatPhotoCollectionView performBatchUpdates:^{
        [self.chatPhotoCollectionView reloadItemsAtIndexPaths:array];
    } completion:^(BOOL finished) {
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.count = [self.delegate itemCountInChatPhotoView:self];
    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ChatPhotoCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    NSInteger row = indexPath.row;
    UIImage* image = [self.delegate chatPhotoView:self shouldDisplayItem:row];
    cell.photoImageView.image = image;
    
//    cell.photoImageView.alpha = 0.0;
//    [UIView animateWithDuration:0.3 animations:^{
//        //动画的内容
//        cell.photoImageView.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        //动画结束
//        cell.photoImageView.alpha = 1.0;
//    }];
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(chatPhotoView:didSelectItem:)]) {
        [self.delegate chatPhotoView:self didSelectItem:indexPath.row];
    }
}

- (NSIndexPath *)lastVisableIndex {
    NSIndexPath* indexPath = nil;
    NSInteger row = 0;
    for(NSIndexPath* item in self.chatPhotoCollectionView.indexPathsForVisibleItems) {
        if( item.row >= row ) {
            indexPath = item;
            row = item.row;
        }
    }
    return indexPath;
}


- (void)layoutSubviews{
    [super layoutSubviews];
}
@end
