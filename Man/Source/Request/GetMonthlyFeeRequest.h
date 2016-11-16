//
//  GetMonthlyFeeRequest.h
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetMonthlyFeeRequest : SessionRequest
@property (nonatomic, strong) GetMonthlyFeeTipsFinishHandler _Nullable finishHandler;
@end
