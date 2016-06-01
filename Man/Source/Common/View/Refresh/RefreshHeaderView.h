//
//  RefreshHeaderView.h
//  Refresh
//
//  Created by lance  on 16-4-10.
//  Copyright (c) 2016年 qpidnetwork. All rights reserved.
//  下拉刷新

#import "RefreshBaseView.h"

@interface RefreshHeaderView : RefreshBaseView

@property (nonatomic, copy) NSString *dateKey;
+ (instancetype)header;

@end