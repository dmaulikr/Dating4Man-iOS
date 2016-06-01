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
#else
#define NSLog(...) {}
#endif

#define ROW_TYPE    @"ROW_TYPE"
#define ROW_SIZE    @"ROW_SIZE"


// objc_msgSend
#define msgSend(...) ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define msgTarget(target) (__bridge void *)(target)

#define Color(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
// 文字颜色
#define RefreshLabelTextColor Color(150, 150, 150)

// 图片路径
#define RefreshSrcName(file) [@"Refresh.bundle" stringByAppendingPathComponent:file]


#endif
