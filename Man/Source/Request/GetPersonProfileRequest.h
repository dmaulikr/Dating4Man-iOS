//
//  GetPersonProfileRequest.h
//  dating
//
//  Created by test on 16/5/30.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface GetPersonProfileRequest : SessionRequest


@property (nonatomic, strong) getMyProfileFinishHandler _Nullable finishHandler;

- (BOOL)sendRequest;

- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg;

@end
