//
//  JWURLProtocol.m
//  dating
//
//  Created by alex shum on 16/10/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "JWURLProtocol.h"

static NSString *const JWURLProtocolHandleKey = @"JWURLProtocolHandleKey";

@interface JWURLProtocol ()<NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSURLSessionDataTask *task;
@property (nonatomic, strong        ) NSURLSession         *session;
@end

@implementation JWURLProtocol


// 是否处理请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
   // NSLog(@"canInitWithRequest");
    
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    NSString *host   = [[request URL] host];
    NSString *absolute = [[request URL] absoluteString];
//    if ([absolute rangeOfString:@"/emf/"].location != NSNotFound) {
//        NSLog(@"alextest1 absolute:%@",absolute );
//    }
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        //        NSLog(@"====>%@",request.URL);
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:JWURLProtocolHandleKey inRequest:request]) {
            return NO;
        }
        
        NSURL * url = [request URL];
        NSString* strabsolute = [url absoluteString];
        if ([host isEqualToString:@"ssl.google-analytics.com"] || [strabsolute rangeOfString:@"/chat/online_ladies/"].location != NSNotFound || [strabsolute rangeOfString:@"#/?topage=emf&user_id="].location != NSNotFound) {
            return NO;
        }
        //NSLog(@"alextest canInitWithRequest strabsolute:%@", strabsolute);
        return YES;
    }
    return NO;
}

//
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    //NSLog(@"canonicalRequestForRequest");
    /** 可以在此处添加头等信息  */
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
//   if (AppDelegate().demo) {
//       NSString *authStr = @"test:5179";
//       
//       // 2> BASE64的编码,避免数据在网络上以明文传输
//       // iOS中,仅对NSData类型的数据提供了BASE64的编码支持
//       NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//      NSString *encodeStr = [authData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
//       NSString * authValue = [NSString stringWithFormat:@"Basic %@",encodeStr];
//       [mutableReqeust setValue:authValue forHTTPHeaderField:@"Authorization"];
//       //[mutableReqeust setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//        [mutableReqeust setHTTPMethod:@"POST"];
       [mutableReqeust setTimeoutInterval:30];
//   }
    return mutableReqeust;

}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    BOOL result = [super requestIsCacheEquivalent:a toRequest:b];
    //NSLog(@"requestIsCacheEquivalent result:%d", result);
    return result;
}

-(void)startLoading
{
    //NSLog(@"alextest startLoading strabsolute:%@", [[[self request] URL] absoluteString]);
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //打标签，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:JWURLProtocolHandleKey inRequest:mutableReqeust];
    
    NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
    if (AppDelegate().demo) {
        NSString *username = @"test";
        NSString *password = @"5179";
        NSString *authString = [NSString stringWithFormat:@"%@:%@",
                            username,
                            password];
    
        // 2 - convert authString to an NSData instance
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    
        // 3 - build the header string with base64 encoded data
        NSString *authHeader = [NSString stringWithFormat: @"Basic %@",
                                [authData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
        // 5 - add custom headers, including the Authorization header
        [configure setHTTPAdditionalHeaders:@{
                                              @"Accept": @"application/json",
                                              @"Authorization": authHeader
                                              }
        ];
    }
    

//    if ([[[[self request] URL] absoluteString] rangeOfString:@"/member/get_man_photo"].location != NSNotFound) {
//        NSLog(@"alextest1 absolute:%@",[[[self request] URL] absoluteString]);
//    }
    
    if ([[[[self request] URL] absoluteString] rangeOfString:@"/member/get_man_photo"].location != NSNotFound) {
        //NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[NSURL URLWithString:@""] MIMEType:@"text/html" expectedContentLength:0 textEncodingName:nil];
        //[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
        
        self.task = [self.session dataTaskWithRequest:mutableReqeust];
        [self.task resume];
        
    }

//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    
//    self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
//    
//    
//
//        self.task = [self.session dataTaskWithRequest:mutableReqeust];
//         [self.task resume];

}

-(void)stopLoading
{
    // NSLog(@"stopLoading");
    [self.session invalidateAndCancel];
    self.session = nil;
   
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
//    NSLog(@"alextest didCompleteWithError");
//    if (error != nil) {
//        
//        NSLog(@"alextest didCompleteWithError code:%ld error;%@", (long)error.code , error);
//        [self.client URLProtocol:self didFailWithError:error];
//    }else
//    {
//        [self.client URLProtocolDidFinishLoading:self];
//    }
    
    if (error == nil) {
       
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        // Do nothing.  This happens in two cases:
        //
        // o during a redirect, in which case the redirect code has already told the client about
        //   the failure
        //
        // o if the request is cancelled by a call to -stopLoading, in which case the client doesn't
        //   want to know about the failure
         //[[self client] URLProtocolDidFinishLoading:self];
        
    } else {
       // NSLog(@"alextest didCompleteWithError code:%ld error;%@", (long)error.code , error);
        [self.client URLProtocol:self didFailWithError:error];
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
   // NSLog(@"alextest didReceiveResponse");
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //NSLog(@"alextesturl didReceiveData:%lu request:%@", [data length], [[dataTask.currentRequest URL] absoluteString]);
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler
{
    // NSLog(@"alextest willCacheResponse");
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    //NSLog(@"alextest willSendRequestForAuthenticationChallenge didReceiveChallenge");
    
    
    //[challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
    //NSLog(@"willSendRequestForAuthenticationChallenge challenge.protectionSpace.authenticationMethod:%@", challenge.protectionSpace.authenticationMethod);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        //NSLog(@"willSendRequestForAuthenticationChallenge [challenge previousFailureCount] == 0");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"test"
                                                                    password:@"5179"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
    } else {
        //NSLog(@"willSendRequestForAuthenticationChallenge [challenge previousFailureCount] != 0");
        // Inform the user that the user name and password are incorrect
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

//TODO: 重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    // NSLog(@"alextest willPerformHTTPRedirection");
    
    NSMutableURLRequest *    redirectRequest;
    redirectRequest = [newRequest mutableCopy];
    [[self class] removePropertyForKey:JWURLProtocolHandleKey inRequest:redirectRequest];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
    
    [self.task cancel];
    [[self client] URLProtocol:self didFailWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    //NSLog(@"alextest cachedResponse");
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
        
        // Some stuff
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    // NSLog(@"alextest didReceiveChallenge");
    //NSLog(@"willSendRequestForAuthenticationChallenge");
    
    //[challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic];
    //NSLog(@"willSendRequestForAuthenticationChallenge challenge.protectionSpace.authenticationMethod:%@", challenge.protectionSpace.authenticationMethod);
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        //NSLog(@"willSendRequestForAuthenticationChallenge [challenge previousFailureCount] == 0");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"test"
                                                                    password:@"5179"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
    } else {
        //NSLog(@"willSendRequestForAuthenticationChallenge [challenge previousFailureCount] != 0");
        // Inform the user that the user name and password are incorrect
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

@end
