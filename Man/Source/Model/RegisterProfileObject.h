//
//  RegisterProfileObject.h
//  dating
//
//  Created by lance on 16/3/18.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterProfileObject : NSObject

/** 性别 */
@property (nonatomic,assign) BOOL isMale;
/** 姓名 */
@property (nonatomic,strong) NSString *name;
/** birthday */
@property (nonatomic,strong) NSString *birthday;
/** 国家 */
@property (nonatomic,strong) NSString *country;
/** 描述 */
@property (nonatomic,strong) NSString *decribe;
/** email */
@property (nonatomic,strong) NSString *email;
/** 密码 */
@property (nonatomic,strong) NSString *password;





@end
