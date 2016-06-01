//
//  LadyDetailItemObject.h
//  dating
//
//  Created by test on 16/4/21.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LadyDetailItemObject : NSObject
/** 女士ID */
@property (nonatomic,strong) NSString *womanid;
/** 女士firstname */
@property (nonatomic,strong) NSString *firstname;
/** 国家 */
@property (nonatomic,strong) NSString *country;
/** 省份 */
@property (nonatomic,strong) NSString *province;
/** 出生日期 */
@property (nonatomic,strong) NSString *birthday;
/** 年龄 */
@property (nonatomic,assign) int age;
/** 星座 */
@property (nonatomic,strong) NSString *zodiac;
/** 重量 */
@property (nonatomic,strong) NSString *weight;
/** 高度 */
@property (nonatomic,strong) NSString *height;
/** 吸烟情况 */
@property (nonatomic,strong) NSString *smoke;
/** 喝酒能力 */
@property (nonatomic,strong) NSString *drink;
/** 英语能力 */
@property (nonatomic,strong) NSString *english;
/** 宗教情况 */
@property (nonatomic,strong) NSString *religion;
/** 教育情况 */
@property (nonatomic,strong) NSString *education;
/** 职业 */
@property (nonatomic,strong) NSString *profession;
/** 子女状况 */
@property (nonatomic,strong) NSString *children;
/** 婚姻状况 */
@property (nonatomic,strong) NSString *marry;
/** 个人简介 */
@property (nonatomic,strong) NSString *resume;
/** 期望开始年龄 */
@property (nonatomic,assign) int age1;
/** 期望结束年龄 */
@property (nonatomic,assign) int age2;
/** 是否在线 */
@property (nonatomic,assign) BOOL isonline;
/** 是否收藏 */
@property (nonatomic,assign) BOOL isFavorite;
/** 最后更新时间 */
@property (nonatomic,strong) NSString *last_update;
/** 是否显示love call功能 */
@property (nonatomic,assign) int show_lovecall;
/** 女士头像URL */
@property (nonatomic,strong) NSString *photoURL;
/** 女士小头像URL 100 *133 */
@property (nonatomic,strong) NSString *photoMinURL;
/** 拇指图列表 */
@property (nonatomic,strong) NSArray *thumbList;
/** 图片URL列表 */
@property (nonatomic,strong) NSArray *photoList;
/** 视频列表 */
@property (nonatomic,strong) NSArray *videoList;
/** 锁定的相片数量 */
@property (nonatomic,assign) int photoLockNum;

@end
