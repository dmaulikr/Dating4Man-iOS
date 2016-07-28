//
//  RemoveContactListRequset.h
//  dating
//
//  Created by lance on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface RemoveContactListRequset : SessionRequest
/** 女士id */
@property (nonatomic,strong) NSArray * _Nullable womanIdArray;
@property (nonatomic, strong) removeContactLishFinishHandler _Nullable finishHandler;
@end
