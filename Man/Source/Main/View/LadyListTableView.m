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

@interface LadyListTableView() {
    
}
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
    if( item.onlineStatus == LADY_ONLINE ) {
        cell.onlineImageView.hidden = NO;
    } else {
        cell.onlineImageView.hidden = YES;
    }
    
    // 名字年龄
    cell.leftLabel.text = [NSString stringWithFormat:@"%@, %d", item.firstname, item.age];
    
    // 国家
    cell.rightlLabel.text = item.country;
    
    // 在线状态
    if( item.onlineStatus == LADY_ONLINE ) {
        cell.onlineImageView.hidden = NO;
    } else {
        cell.onlineImageView.hidden = YES;
    }
    
    // 菊花
//    [cell.loadingActivity startAnimating];
//    cell.loadingActivity.hidden = NO;
//    cell.loadingView.hidden = NO;
    
    // 头像
    
    cell.ladyImageView.image = [UIImage imageNamed:@"LadyList-Lady-Default"];
    NSString* imageViewLoaderString = @"imageViewLoader";
    ImageViewLoader* imageViewLoader = objc_getAssociatedObject(cell, &imageViewLoaderString);
    if( !imageViewLoader ) {
        imageViewLoader = [[ImageViewLoader alloc] init];
        objc_setAssociatedObject(cell, &imageViewLoaderString, imageViewLoader, OBJC_ASSOCIATION_RETAIN);
    }
    [imageViewLoader reset];
    imageViewLoader.view = cell.ladyImageView;
    imageViewLoader.url = item.photoURL;
    imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageViewLoader.url];
    [imageViewLoader loadImage];
    
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didShowLady:)]) {
            [self.tableViewDelegate tableView:self didShowLady:item];
        }
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

@end
