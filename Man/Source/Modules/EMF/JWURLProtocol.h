//
//  JWURLProtocol.h
//  dating
//
//  Created by alex shum on 16/10/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JWURLProtocolDelegate;


@interface JWURLProtocol : NSURLProtocol

+ (void)setDelegate:(id<JWURLProtocolDelegate>)delegate;

@end

@protocol JWURLProtocolDelegate <NSObject>

@optional

-(void)JWURLProtocol:(JWURLProtocol *)protocol task:(NSURLSessionTask *)task didCompleWithError:(NSError *)error;

-(void)JWURLProtocol:(JWURLProtocol *)protocol task:(NSURLSessionTask *)task didCompleWithError:(NSError *)error;

-(void)JWURLProtocol:(JWURLProtocol *)protocol task:(NSURLSessionDataTask *)task didReceiveResponse:(NSURLResponse *)response;

@end
