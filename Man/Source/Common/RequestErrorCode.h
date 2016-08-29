//
//  RequestErrorCode.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#ifndef RequestErrorCode_h
#define RequestErrorCode_h

/**
 *  Session失效
 */
#define SESSION_TIMEOUT @"MBCE0003"

/**
 *  验证码不正确
 */
#define CHECKCODE_EMPTY @"MBCE1012"
#define CHECKCODE_ERROR @"MBCE1013"

/**
 *  Livechat消费余额不足
 */
#define LIVECHAT_NO_MONEY @"ERROR00003"

#endif /* RequestErrorCode_h */
