//
//  UploadHeaderPhoto.h
//  dating
//
//  Created by lance on 16/4/25.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UploadHeaderPhoto : SessionRequest

/* 文件路径 */
@property (nonatomic,strong) NSString * _Nullable fileName;

@property (nonatomic,strong) uploadHeaderPhotoFinishHandler _Nullable finishHandler;

- (BOOL)sendRequest;

- (void)callRespond:(NSString* _Nullable)errnum errmsg:(NSString* _Nullable)errmsg;



@end
