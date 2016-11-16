//
//  CommonDefine.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h

// 仅Debug模式输出log
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#define printf(...) printf{__VA_ARGS__}
#else
#define NSLog(...) {}
#define printf(...) {}
#endif

#define ROW_TYPE    @"ROW_TYPE"
#define ROW_SIZE    @"ROW_SIZE"

#define NSLocalizedStringFromSelf(key) NSLocalizedStringFromTable(key, [[self class] description], nil)
#define NSLocalizedStringFromErrorCode(key) NSLocalizedStringFromTable(key, @"LocalizableErrorCode", nil)

// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

#define Color(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//#define errorUrl @"http://mobile.chnlove.com/Public/images/photo_unavailable.gif"
//#define errorDemoUrl @"http://demo-ios.qpidnetwork.com/Public/images/photo_unavailable.gif"


#endif
