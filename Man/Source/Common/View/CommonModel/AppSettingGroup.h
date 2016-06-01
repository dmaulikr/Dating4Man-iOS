//
//  AppSettingGroup.h
//  dating
//
//  Created by test on 16/5/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettingGroup : NSObject


/** 组标题 */
@property (nonatomic,strong) NSString *groupTitle;
/** 组数据 */
@property (nonatomic,strong) NSArray *groupData;

@end
