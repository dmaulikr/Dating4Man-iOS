//
//  RemoveFavouriteLadyRequest.h
//  dating
//
//  Created by test on 16/4/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface RemoveFavouriteLadyRequest : SessionRequest
/** 女士id */
@property (nonatomic,strong) NSString * _Nullable womanId;
@property (nonatomic, strong) removeFavouritesLadyFinishHandler _Nullable finishHandler;
@end
