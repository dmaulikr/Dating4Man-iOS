//
//  UpdateProfileRequest.h
//  dating
//
//  Created by test on 16/5/31.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SessionRequest.h"

@interface UpdateProfileRequest : SessionRequest

/** 高度 */
@property (nonatomic,assign) int height;
/** 体重 */
@property (nonatomic,assign) int weight;
/** 吸烟 */
@property (nonatomic,assign) int smoke;
/** 喝酒 */
@property (nonatomic,assign) int drink;
/** 语言 */
@property (nonatomic,assign) int language;
/** 宗教 */
@property (nonatomic,assign) int religion;
/** 教育 */
@property (nonatomic,assign) int education;
/** 职业 */
@property (nonatomic,assign) int profession;
/** 人种 */
@property (nonatomic,assign) int ethnicity;
/** 收入 */
@property (nonatomic,assign) int income;
/** 孩纸个数 */
@property (nonatomic,assign) int children;
/** 描述 */
@property (nonatomic,strong) NSString * _Nullable resume;
/** 兴趣爱好 */
@property (nonatomic,strong) NSMutableArray * _Nullable interests;

@property (nonatomic,strong) updateMyProfileFinishHandler _Nullable finishHandler;

@end
