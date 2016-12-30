//
//  LadyListTableView.h
//  DrPalm
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Lady.h"
#import "QueryLadyListItemObject.h"

@class LadyListTableView;
//@class Lady;
@class QueryLadyListItemObject;
@protocol LadyListTableViewDelegate <NSObject>
@optional
- (void)needReloadData:(LadyListTableView *)tableView;
- (void)tableView:(LadyListTableView *)tableView didShowLady:(QueryLadyListItemObject *)item;
- (void)tableView:(LadyListTableView *)tableView didSelectLady:(QueryLadyListItemObject *)item;
//- (void)tableView:(LadyListTableView *)tableView willDeleteLady:(Lady *)item;
- (void)tableView:(LadyListTableView *)tableView willDeleteLady:(QueryLadyListItemObject *)item;
- (void)tableViewDidResetView:(LadyListTableView *)tableView;


- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface LadyListTableView : UITableView <UITableViewDataSource, UITableViewDelegate>{
    
}

@property (nonatomic, weak) IBOutlet id <LadyListTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;

@end
