//
//  StartEditResumeRequest.h
//  dating
//
//  Created by test on 16/5/30.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface StartEditResumeRequest : SessionRequest
@property (nonatomic,strong) startEditResumeFinishHandler _Nullable finishHandler;
@end
