//
//  GetPaymentOrderRequest.h
//  dating
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionRequest.h"

@interface GetPaymentOrderRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable manId;
@property (nonatomic, strong) NSString* _Nullable sid;
@property (nonatomic, strong) NSString* _Nullable number;

@property (nonatomic, strong) GetPaymentOrderFinishHandler _Nullable finishHandler;
@end
