//
//  AddFavouriteLadyRequest.h
//  dating
//
//  Created by test on 16/4/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface AddFavouriteLadyRequest : SessionRequest

/** 女士id */
@property (nonatomic,strong) NSString * _Nullable womanId;

@property (nonatomic, strong) addFavouritesLadyFinishHandler _Nullable finishHandler;

- (BOOL)sendRequest;

- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg;


@end
