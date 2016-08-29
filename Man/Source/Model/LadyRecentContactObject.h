//
//  LadyRecentContactObject.h
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LadyRecentContactObject : NSObject


/** 女士id */
@property (nonatomic, strong) NSString* womanId;
/** 名称 */
@property (nonatomic, strong) NSString* firstname;
/** 年龄 */
@property (nonatomic, assign) NSInteger age;
/** 图片地址 */
@property (nonatomic, strong) NSString* photoURL;
/** 大图地址 */
@property (nonatomic, strong) NSString* photoBigURL;
/** 是否收藏 */
@property (nonatomic, assign) BOOL isFavorite;
/** 视频数 */
@property (nonatomic, assign) NSInteger videoCount;
/** 最后一次联系时间 */
@property (nonatomic, assign) NSInteger lasttime;
/** 在线状态 */
@property (nonatomic,assign) BOOL isOnline;
/** 在聊状态 */
@property (nonatomic,assign) BOOL isInChat;
/** 最后邀请文字 */
@property (nonatomic, strong) NSAttributedString* lastInviteMessage;
@end
