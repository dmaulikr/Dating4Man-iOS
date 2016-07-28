//
//  LoginItemObject.h
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <manrequesthandler/item/LoginItem.h>

@interface LoginItemObject : NSObject
@property (nonatomic, strong) NSString* manid;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* firstname;
@property (nonatomic, strong) NSString* lastname;
@property (nonatomic, strong) NSString* photoURL;
@property (nonatomic, strong) NSString* reg_step;
@property (nonatomic, assign) NSInteger country;
@property (nonatomic, strong) NSString* telephone;
@property (nonatomic, assign) BOOL telephone_verify;
@property (nonatomic, assign) NSInteger telephone_cc;
@property (nonatomic, strong) NSString* sessionid;
@property (nonatomic, strong) NSString* ga_uid;
@property (nonatomic, strong) NSString* ticketid;
@property (nonatomic, strong) NSString* ga_activity;
@property (nonatomic, assign) BOOL photosend;
@property (nonatomic, assign) BOOL photoreceived;
@property (nonatomic, assign) BOOL premit;
@property (nonatomic, assign) BOOL ladyprofile;
@property (nonatomic, assign) BOOL livechat;
@property (nonatomic, assign) BOOL admirer;
@property (nonatomic, assign) BOOL bpemf;
@property (nonatomic, assign) BOOL videoreceived;
@end
