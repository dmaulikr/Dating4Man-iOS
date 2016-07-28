//
//  GetLadyDetailRequest.h
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetLadyDetailRequest : SessionRequest
/** 女士id */
@property (nonatomic,strong) NSString * _Nullable womanId;
@property (nonatomic, strong) LadyDetailFinishHandler _Nullable finishHandler;
@end
