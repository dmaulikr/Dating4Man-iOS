//
//  MonthlyFeeTipItemObject.h
//  dating
//
//  Created by lance on 16/8/17.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthlyFeeTipItemObject : NSObject

/** 月费类型 */
@property (nonatomic,assign) int menberType;
/** 价钱标题 */
@property (nonatomic,strong) NSString *priceTitle;
/** 提示列表 */
@property (nonatomic,strong) NSArray *tipArray;

@end
