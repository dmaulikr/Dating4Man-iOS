//
//  GetRecentContactListRequest.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SessionRequest.h"

/**
 *  获取最近联系人接口
 */
@interface GetRecentContactListRequest : SessionRequest
@property (nonatomic, strong) RecentContactListFinishHandler _Nullable finishHandler;
@end
