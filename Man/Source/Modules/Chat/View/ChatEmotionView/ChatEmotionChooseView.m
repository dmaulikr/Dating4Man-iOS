//
//  ChatEmotionChooseView.m
//  dating
//
//  Created by Max on 16/5/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatEmotionChooseView.h"
#import "ChatEmotionChooseCollectionViewCell.h"

@implementation ChatEmotionChooseView 

+ (instancetype)emotionChooseView:(id)owner {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamedWithFamily:@"ChatEmotionChooseView" owner:owner options:nil];
    ChatEmotionChooseView* view = [nibs objectAtIndex:0];
    
    view.sendButton.layer.cornerRadius = view.sendButton.frame.size.height / 4;
    view.sendButton.layer.masksToBounds = YES;
    
    UINib *nib = [UINib nibWithNibName:@"ChatEmotionChooseCollectionViewCell" bundle:nil];
    [view.emotionCollectionView registerNib:nib forCellWithReuseIdentifier:[ChatEmotionChooseCollectionViewCell cellIdentifier]];
    
    return view;
}

- (void)reloadData {
    [self.emotionCollectionView reloadData];
//    self.emotionCollectionView.collectionViewLayout.collectionViewContentSize = CGSizeMake(self.frame.size.width, self.emotionCollectionView.contentSize.height);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emotions.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChatEmotionChooseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[ChatEmotionChooseCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    ChatEmotion* item = [self.emotions objectAtIndex:indexPath.item];
    cell.imageView.image = item.image;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(chatEmotionChooseView:didSelectItem:)] ) {
        [self.delegate chatEmotionChooseView:self didSelectItem:indexPath.item];
    }
}

/* 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
//    NSLog(@"layoutSubviews( self.emotionCollectionView.frame.size.width : %f )", self.emotionCollectionView.frame.size.width);
//    self.emotionCollectionView.contentSize = CGSizeMake(self.frame.size.width, self.emotionCollectionView.contentSize.height);
//    [self.emotionCollectionView layoutIfNeeded];
//    [self.emotionCollectionView reloadData];
}

@end
