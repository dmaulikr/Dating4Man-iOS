//
//  GetQueryMemberTypeRequest.h
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetQueryMemberTypeRequest : SessionRequest
@property (nonatomic, strong) GetQueryMemberTypeFinishHandler _Nullable finishHandler;
@end
