//
//  URLHandler.h
//  dating
//
//  Created by Max on 16/10/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    URLTypeNone,
    URLTypeEmf,
    URLTypeSetting,
    URLTypeLadyDetail,
    URLTypeChatLady
}URLType;

@class URLHandler;
@protocol URLHandlerDelegate <NSObject>
@optional
- (void)handler:(URLHandler * _Nonnull)handler openWithModule:(URLType)type;
@end

@interface URLHandler : NSObject

+ (instancetype _Nonnull)shareInstance;

/**
 委托
 */
@property (weak) id<URLHandlerDelegate> _Nullable delegate;

/**
 当前调用类型
 */
@property (assign, atomic, readonly) URLType type;

/**
 解析调用过来的URL

 @param url 原始链接

 @return 处理结果[YES:成功/NO:失败]
 */
- (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

/**
 处理调用过来的URL

 @return 处理结果[YES:成功/NO:不需要处理]
 */
- (BOOL)dealWithURL;

@end
