//
//  GetCountRequest.h
//  dating
//
//  Created by Max on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

/**
 *  获取男士余额接口
 */
@interface GetCountRequest : SessionRequest
@property (nonatomic,strong) GetCountFinishHandler _Nullable finishHandler;
@end
