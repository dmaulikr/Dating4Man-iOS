//
//  CheckPaymentRequest.h
//  dating
//
//  Created by  Samson on 6/22/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionRequest.h"

@interface CheckPaymentRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable manId;
@property (nonatomic, strong) NSString* _Nullable sid;
@property (nonatomic, strong) NSString* _Nullable receipt;
@property (nonatomic, strong) NSString* _Nullable orderNo;

@property (nonatomic, strong) CheckPaymentFinishHandler _Nullable finishHandler;
@end
