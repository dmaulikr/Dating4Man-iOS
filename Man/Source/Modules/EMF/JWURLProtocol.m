//
//  JWURLProtocol.m
//  dating
//
//  Created by alex shum on 16/10/11.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "JWURLProtocol.h"

static NSString *const JWURLProtocolHandleKey = @"JWURLProtocolHandleKey";
static NSString *const PUBLICCSS01 = @"/Public/Css/jquery.mobile.min.css?v=1.51";
static NSString *const PUBLICCSS02 = @"/Public/Css/public.css?v=1.65";
static NSString *const PUBLICCSS03 = @"/Public/charmingdate/css/css.css?v=1.61";
static NSString *const PUBLICCSS04 = @"/Public/Css/women_list.css?v=1.64";
static NSString *const PUBLICCSS05 = @"/Public/Js/jquery.min.js?v=1.52";
static NSString *const PUBLICCSS06 = @"/Public/Js/jquery.mobile.js?v=1.52";
static NSString *const PUBLICCSS07 = @"/Public/Js/login.js?v=1.56";
static NSString *const PUBLICCSS08 = @"/Public/Js/blocksit.min.js";
static NSString *const PUBLICCSS09 = @"/Public/Js/jquery.form.min.js";
static NSString *const PUBLICCSS10 = @"/Public/Js/public.js?v=1.09";
static NSString *const PUBLICCSS11 = @"/Public/Js/base64.js";
static NSString *const PUBLICCSS12 = @"/Public/Js/base_jqm.js?v=1.70";
static NSString *const PUBLICCSS13 = @"/Public/Js/iscroll.js?v=1.52";
static NSString *const PUBLICCSS14 = @"/Public/Js/util.js";
static NSString *const PUBLICCSS15 = @"/Public/Js/json.js";
static NSString *const PUBLICCSS16 = @"/Public/Js/framework.chat.js?v=1.68";
static NSString *const PUBLICCSS17 = @"/Public/Js/socket.js?v=1.51";
static NSString *const PUBLICCSS18 = @"/Public/Js/touchSwipe.min.js";
static NSString *const PUBLICCSS19 = @"/Public/Js/age.scroller.js";
static NSString *const PUBLICCSS20 = @"/Public/Js/TouchSlide.1.1.source.js";
static NSString *const PUBLICCSS21 = @"/Public/Js/animation.js?v=1.52";
static NSString *const PUBLICCSS22 = @"/Public/Css/chat_scroll.css?v=1.52";
static NSString *const PUBLICCSS23 = @"/Public/Js/chat_scroll.js?v=1.52";
static NSString *const PUBLICCSS24 = @"/Public/charmingdate/css/swipe.css";
static NSString *const PUBLICCSS25 = @"/Public/Js/klass.min.js";
static NSString *const PUBLICCSS26 = @"/Public/Js/photoswipe.jquery-3.0.4.min.js?v=1.57";

static NSString *const PUBLICIMAGE01 = @"/Public/images/btn_ico/ic_expand_more_white.png";
static NSString *const PUBLICIMAGE02 = @"/Public/images/default_profile_photo_bg.jpg";
static NSString *const PUBLICIMAGE03 = @"/Public/images/btn_ico/ic_email_white.png";
static NSString *const PUBLICIMAGE04 = @"/Public/images/btn_ico/ic_love_call_white.png";
static NSString *const PUBLICIMAGE05 = @"/Public/images/btn_ico/ic_female_symble_white.png";
static NSString *const PUBLICIMAGE06 = @"/Public/images/btn_ico/ic_female_contact_white.png";
static NSString *const PUBLICIMAGE07 = @"/Public/images/btn_ico/img_cl_selection.png";
static NSString *const PUBLICIMAGE08 = @"/Public/images/btn_ico/img_ida_selection.png";
static NSString *const PUBLICIMAGE09 = @"/Public/images/btn_ico/img_ld_selection.png";
static NSString *const PUBLICIMAGE10 = @"/Public/images/btn_ico/ic_launch_left_white.png";
static NSString *const PUBLICIMAGE11 = @"/Public/images/btn_ico/ic_launch_left_back_white.png";
static NSString *const PUBLICIMAGE12 = @"/Public/images/btn_ico/img_cd_selection.png";
static NSString *const PUBLICIMAGE13 = @"/Public/images/btn_ico/ic_uploadphoto_white.png";
static NSString *const PUBLICIMAGE14 = @"/Public/images/btn_ico/logo_white.png";
static NSString *const PUBLICIMAGE15 = @"/Public/images/temporary/mobMEvPop_ad1.png";
static NSString *const PUBLICIMAGE16 = @"/Public/images/btn_ico/ic_done_green.png";
static NSString *const PUBLICIMAGE17 = @"/member/get_man_photo";
static NSString *const PUBLICIMAGE18 = @"/Public/images/logo.png";
static NSString *const PUBLICIMAGE19 = @"/%7B#photourl%23%7D";
static NSString *const PUBLICIMAGE20 = @"/Public/images/btn_ico/ic_menu_white.png";



@interface JWURLProtocol ()<NSURLSessionDataDelegate>

@property (atomic, strong, readwrite) NSURLSessionDataTask *task;
@property (nonatomic, strong        ) NSURLSession         *session;
@end

@implementation JWURLProtocol

static id<JWURLProtocolDelegate> sDelegate;

+ (id<JWURLProtocolDelegate>)delegate
{
    id<JWURLProtocolDelegate> result;
    @synchronized (self) {
        result = sDelegate;
    }
    return result;
}

+ (void)setDelegate:(id<JWURLProtocolDelegate>)delegate
{
    @synchronized (self) {
        sDelegate = delegate;
    }
}

// 是否处理请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
   // NSLog(@"canInitWithRequest");
    
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    NSString *host   = [[request URL] host];
//    NSString *absolute = [[request URL] absoluteString];
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
        // || [strabsolute rangeOfString:@"/member/get_man_photo"].location != NSNotFound
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
    [mutableReqeust setTimeoutInterval:60];
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
    


    if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE01].location != NSNotFound) {

        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE02].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE03].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE04].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE05].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE06].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE07].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE08].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE09].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE10].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE11].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE12].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE13].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE14].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE15].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE16].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE17].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE18].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE19].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICIMAGE20].location != NSNotFound) {
        
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        //[self.client URLProtocol:self didLoadData:nil];
        [self.client URLProtocolDidFinishLoading:self];
    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS01].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS02].location != NSNotFound)
//    {   // 一些图片大小排列
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS03].location != NSNotFound)
//    {
////         导航颜色？？背景颜色
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS04].location != NSNotFound)
//    {
//        
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS05].location != NSNotFound)
//    {
//        // 不能点击了
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS06].location != NSNotFound)
//    {
//        // 不能进入emf
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS07].location != NSNotFound)
//    {
//        // 登录？？？
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS08].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS09].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS10].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS11].location != NSNotFound)
//    {
//       // emf 里面的空图（your inbox is empty）
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS12].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS13].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS14].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS15].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS16].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS17].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS18].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS19].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS20].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS21].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS22].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS23].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS24].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS25].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
//    else if ([[[[self request] URL] absoluteString] rangeOfString:PUBLICCSS26].location != NSNotFound)
//    {
//        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL MIMEType:nil expectedContentLength:0 textEncodingName:nil];
//        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//        //[self.client URLProtocol:self didLoadData:nil];
//        [self.client URLProtocolDidFinishLoading:self];
//    }
    else
    {
        NSLog(@"alextest startLoading strabsolute:%@", [[[self request] URL] absoluteString]);
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
        
        self.task = [self.session dataTaskWithRequest:mutableReqeust];
        [self.task resume];
        
    }
//
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    
//    self.session  = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:queue];
//    
//    
//
//    self.task = [self.session dataTaskWithRequest:mutableReqeust];
//    [self.task resume];

}

-(void)stopLoading
{
    // NSLog(@"stopLoading");
    [self.session invalidateAndCancel];
    self.session = nil;
   
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{

    if (error == nil) {
       
        [[self client] URLProtocolDidFinishLoading:self];
    } else if ( [[error domain] isEqual:NSURLErrorDomain] && ([error code] == NSURLErrorCancelled) ) {
        //   want to know about the failure
         //[[self client] URLProtocolDidFinishLoading:self];
        id<JWURLProtocolDelegate> strongDelegate = [[self class] delegate];
        if (strongDelegate) {
            [strongDelegate JWURLProtocol:self task:task didCompleWithError:error];
        }
        
    } else {
       // NSLog(@"alextest didCompleteWithError code:%ld error;%@", (long)error.code , error);
        id<JWURLProtocolDelegate> strongDelegate = [[self class] delegate];
        if (strongDelegate) {
            [strongDelegate JWURLProtocol:self task:task didCompleWithError:error];
        }
        [self.client URLProtocol:self didFailWithError:error];
    }
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
   // NSLog(@"alextest didReceiveResponse");
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    id<JWURLProtocolDelegate> strongDelegate = [[self class] delegate];
    if (strongDelegate) {
        [strongDelegate JWURLProtocol:self task:dataTask didReceiveResponse:response];
    }
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
