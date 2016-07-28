//
//  LadyListTableView.m
//  DrPalm
//
//  Created by KingsleyYau Max on 16/2/15.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import "LadyListTableView.h"
#import "LadyListTableViewCell.h"
#import "ImageViewLoader.h"
#import "FileCacheManager.h"

@interface LadyListTableView()<ImageViewLoaderDelegate>
// 回调通知外部当前显示的女士
- (void)didShowLady;
@end

@implementation LadyListTableView
@synthesize tableViewDelegate;
@synthesize items;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    self.canDeleteItem = NO;
        
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)reloadData
{
    [super reloadData];
    
    // 通知外部当前显示的女士
    [self didShowLady];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch(section) {
        case 0: {
            if(self.items.count > 0) {
                number = self.items.count;
                
            }
        }
        default:break;
    }
	return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = self.frame.size.height;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;

    LadyListTableViewCell *cell = [LadyListTableViewCell getUITableViewCell:tableView];
    result = cell;
    
    // 数据填充
    QueryLadyListItemObject *item = [self.items objectAtIndex:indexPath.row];
    
    // 名字年龄
    cell.leftLabel.text = [NSString stringWithFormat:@"%@, %d", item.firstname, item.age];
    
    // 国家
    cell.rightlLabel.text = item.country;
    
    // 在线状态
    if( item.onlineStatus == LADY_ONLINE ) {
        cell.onlineImageView.backgroundColor = [UIColor colorWithIntRGB:0 green:255 blue:0 alpha:255];
    } else {
        cell.onlineImageView.backgroundColor = [UIColor colorWithIntRGB:160 green:160 blue:160 alpha:255];
    }
    
    // 菊花
//    [cell.loadingActivity startAnimating];
//    cell.loadingActivity.hidden = NO;
//    cell.loadingView.hidden = NO;
    
    // 头像
    // 显示默认头像
    [cell.ladyImageView setImage:nil];
    // 停止旧的
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

    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectLady:)]) {
            [self.tableViewDelegate tableView:self didSelectLady:[self.items objectAtIndex:indexPath.row]];
        }
    }

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.canDeleteItem)
        return UITableViewCellEditingStyleDelete;
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            if (indexPath.row < self.items.count) {
                if([self.tableViewDelegate respondsToSelector:@selector(tableView:willDeleteLady:)]) {
                    [self.tableViewDelegate tableView:self willDeleteLady:[self.items objectAtIndex:indexPath.row]];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 停止滚动，通知外部当前显示的女士
    [self didShowLady];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 停止滚动，通知外部当前显示的女士
    [self didShowLady];
}

#pragma mark - 回调
// 回调通知外部当前显示的女士
- (void)didShowLady
{
    NSArray<NSIndexPath*>* indexPaths = self.indexPathsForVisibleRows;
    if ([indexPaths count] > 0
        && [indexPaths objectAtIndex:0].row < self.items.count)
    {
        QueryLadyListItemObject* item = [self.items objectAtIndex:[indexPaths objectAtIndex:0].row];
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didShowLady:)]) {
            [self.tableViewDelegate tableView:self didShowLady:item];
        }
    }
}

@end
