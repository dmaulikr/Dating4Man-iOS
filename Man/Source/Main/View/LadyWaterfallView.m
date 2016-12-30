//
//  LadyWaterfallView.m
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyWaterfallView.h"
#import "LadyCollectionViewCell.h"
@implementation LadyWaterfallView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    
    self.alwaysBounceVertical = YES;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"LadyCollectionViewCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:[LadyCollectionViewCell cellIdentifier]];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LadyCollectionViewCell *cell = (LadyCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LadyCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 数据填充
    QueryLadyListItemObject *item = [self.items objectAtIndex:indexPath.row];
    
    //在线状态
    if (item.onlineStatus== LADY_ONLINE) {
        cell.onlineImageView.backgroundColor = [UIColor greenColor];
        [cell.chatButton setBackgroundImage:[UIImage imageNamed:@"LadyList-ChatBG"] forState:UIControlStateNormal];
        [cell.chatButton setImage:[UIImage imageNamed:@"LadyList-ChatIocn-White"] forState:UIControlStateNormal];
        cell.chatButton.userInteractionEnabled = YES;
    }
    else
    {
        cell.onlineImageView.backgroundColor = [UIColor lightGrayColor];
        [cell.chatButton setBackgroundImage:[UIImage imageNamed:@"LadyList-IconBG-White"] forState:UIControlStateNormal];
        [cell.chatButton setImage:[UIImage imageNamed:@"LadyList-ChatIcon-Gray"] forState:UIControlStateNormal];
        cell.chatButton.userInteractionEnabled = NO;
    }
    cell.chatButton.tag = indexPath.row;
    [cell.chatButton addTarget:self action:@selector(chatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@\t%d",item.firstname,item.age];
    
    // 显示默认头像
    [cell.ladyImageView setImage:nil];
    if( cell.imageViewLoader ) {
        [cell.imageViewLoader stop];
    }
    // 创建新的
    cell.imageViewLoader = [ImageViewLoader loader];
    
    // 加载
    cell.imageViewLoader.view = cell.ladyImageView;
    if ([item.photoURL isEqualToString:AppDelegate().errorUrlConnect]) {
        cell.ladyImageView.image = [UIImage imageNamed:@"MyProfile-PersonalHead"];
    }else{
        cell.imageViewLoader.url = item.photoURL;
        cell.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:cell.imageViewLoader.url];
        [cell.imageViewLoader loadImage];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.waterfallViewDelegate respondsToSelector:@selector(waterfallView:didSelectLady:)]) {
        QueryLadyListItemObject *item = [self.items objectAtIndex:indexPath.row];
        [self.waterfallViewDelegate waterfallView:collectionView didSelectLady:item];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
        UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:reusableview.bounds];
        searchBar.delegate = self;
        [reusableview addSubview:searchBar];
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.frame.size.width - 30)/2.0, 240);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger y = scrollView.contentOffset.y;
    if (y <= 40) {
        self.contentInset = UIEdgeInsetsZero;
    }
}
#pragma mark headView点击事件
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if ([self.waterfallViewDelegate respondsToSelector:@selector(showSearthView)]) {
        [self.waterfallViewDelegate showSearthView];
    }
    return NO;
}
#pragma mark - 聊天按钮事件
- (void)chatButtonAction:(UIButton *)button
{
    if ([self.waterfallViewDelegate respondsToSelector:@selector(didChatButtonFromWaterfallViewIndex:)]) {
        NSInteger index = button.tag;
        [self.waterfallViewDelegate didChatButtonFromWaterfallViewIndex:index];
    }
}
@end
