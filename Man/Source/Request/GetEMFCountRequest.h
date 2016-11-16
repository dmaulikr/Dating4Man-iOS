//
//  GetEMFCountRequest.h
//  dating
//
//  Created by alex shum on 16/10/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

/**
 *  获取EMF邮件数接口
 */
@interface GetEMFCountRequest : SessionRequest
@property (nonatomic,strong) GetEMFCountFinishHandler _Nullable finishHandler;

@end
