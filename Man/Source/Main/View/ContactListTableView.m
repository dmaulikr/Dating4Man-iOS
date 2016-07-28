//
//  ContactListTableView.m
//  DrPalm
//
//  Created by KingsleyYau Max on 16/2/15.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import "ContactListTableView.h"
#import "ContactListTableViewCell.h"
#import "ImageViewLoader.h"

@interface ContactListTableView() {
    
}

@property (nonatomic,strong) ImageViewLoader *imageViewLoader;

@end

@implementation ContactListTableView

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
                self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                number = self.items.count;
                
            } else {
                self.separatorStyle = UITableViewCellSeparatorStyleNone;
                number = 0;
                
            }
        }
        default:break;
    }
	return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [ContactListTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;

    ContactListTableViewCell *cell = [ContactListTableViewCell getUITableViewCell:tableView];
    result = cell;
        
    // 数据填充
    LadyRecentContactObject *item = [self.items objectAtIndex:indexPath.row];
    
    // 头像
    // 显示默认头像
    [cell.ladyImageView setImage:[UIImage imageNamed:@"LadyList-Lady-Default"]];
    // 停止旧的
    if( cell.imageViewLoader ) {
        [cell.imageViewLoader stop];
    }
    // 创建新的
    cell.imageViewLoader = [ImageViewLoader loader];
    
    // 加载
    cell.imageViewLoader.view = cell.ladyImageView;
    cell.imageViewLoader.url = item.photoURL;
    cell.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:cell.imageViewLoader.url];
    [cell.imageViewLoader loadImage];
    
    cell.titleLabel.text = item.firstname;
    cell.bookmarkImageView.hidden = !item.isFavorite;
    cell.titleLabel.text = item.firstname;
    cell.onlineImageView.hidden = !item.isOnline;
    cell.inchatImageView.hidden = item.isOnline ? !item.isInChat : YES;
    
    if( item.lastInviteMessage != nil && item.lastInviteMessage.length > 0 ) {
        // 最后一条消息
        cell.detailLabel.attributedText = item.lastInviteMessage;
        
    } else {
        // 最后联系时间
        NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:item.lasttime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSLocale *usLoacal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLoacal];
        formatter.dateFormat = @"dd MMMM";
        cell.detailLabel.text = [NSString stringWithFormat:@"Last contact: %@",[formatter stringFromDate:lastTime]];
    }
    
    // 最后一行的分割线
    if( indexPath.row == self.items.count - 1 ) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    } else {
        [cell setSeparatorInset:[ContactListTableViewCell defaultInsets]];
        
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectContact:)]) {
            [self.tableViewDelegate tableView:self didSelectContact:[self.items objectAtIndex:indexPath.row]];
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
                if([self.tableViewDelegate respondsToSelector:@selector(tableView:willDeleteContact:)]) {
                    [self.tableViewDelegate tableView:self willDeleteContact:[self.items objectAtIndex:indexPath.row]];
                }
            }
            break;
        }
        default:
            break;
    }
}


//#pragma mark - 缩略图界面回调 (RequestImageViewDelegate)
//- (void)imageViewDidDisplayImage:(RequestImageView *)imageView {
//
//}

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
