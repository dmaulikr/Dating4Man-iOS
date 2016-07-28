//
//  UploadCrashLogRequest.h
//  dating
//
//  Created by test on 16/6/20.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UploadCrashLogRequest : SessionRequest

/** crashLog路径 */
@property (nonatomic,strong) NSString* _Nullable srcDirectory;
@property (nonatomic,strong) NSString* _Nullable tmpDirectory;

@property (nonatomic,strong) UploadCrashLogFinishHandler _Nullable finishHandler;

@end
