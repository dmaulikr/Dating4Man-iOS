//
//  Contact.h
//  dating
//
//  Created by Max on 16/2/19.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, strong) NSString* ladyId;
@property (nonatomic, strong) NSString* ladyName;
@property (nonatomic, strong) NSDate* lastContact;

@end
