//
//  LoginItemObject.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LoginItemObject.h"
@interface LoginItemObject () <NSCoding>
@end

@implementation LoginItemObject
- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.manid = [coder decodeObjectForKey:@"manid"];
        self.email = [coder decodeObjectForKey:@"email"];
        self.firstname = [coder decodeObjectForKey:@"firstname"];
        self.lastname = [coder decodeObjectForKey:@"lastname"];
        self.photoURL = [coder decodeObjectForKey:@"photoURL"];
        self.reg_step = [coder decodeObjectForKey:@"reg_step"];
        self.country = [coder decodeIntegerForKey:@"country"];
        self.telephone = [coder decodeObjectForKey:@"telephone"];
        self.telephone_verify = [coder decodeBoolForKey:@"telephone_verify"];
        self.telephone_cc = [coder decodeIntegerForKey:@"telephone_cc"];
        self.sessionid = [coder decodeObjectForKey:@"sessionid"];
        self.ga_uid = [coder decodeObjectForKey:@"ga_uid"];
        self.ticketid = [coder decodeObjectForKey:@"ticketid"];
        self.photosend = [coder decodeBoolForKey:@"photosend"];
        self.photoreceived = [coder decodeBoolForKey:@"photoreceived"];
        self.premit = [coder decodeBoolForKey:@"premit"];
        self.ladyprofile = [coder decodeBoolForKey:@"ladyprofile"];
        self.livechat = [coder decodeBoolForKey:@"livechat"];
        self.admirer = [coder decodeBoolForKey:@"admirer"];
        self.bpemf = [coder decodeBoolForKey:@"bpemf"];
        self.videoreceived = [coder decodeBoolForKey:@"videoreceived"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.manid forKey:@"manid"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.firstname forKey:@"firstname"];
    [coder encodeObject:self.lastname forKey:@"lastname"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.reg_step forKey:@"reg_step"];
    [coder encodeInteger:self.country forKey:@"country"];
    [coder encodeObject:self.telephone forKey:@"telephone"];
    [coder encodeBool:self.telephone_verify forKey:@"telephone_verify"];
    [coder encodeInteger:self.telephone_cc forKey:@"telephone_cc"];
    [coder encodeObject:self.sessionid forKey:@"sessionid"];
    [coder encodeObject:self.ga_uid forKey:@"ga_uid"];
    [coder encodeObject:self.ticketid forKey:@"ticketid"];
    [coder encodeBool:self.photosend forKey:@"photosend"];
    [coder encodeBool:self.photoreceived forKey:@"photoreceived"];
    [coder encodeBool:self.premit forKey:@"premit"];
    [coder encodeBool:self.ladyprofile forKey:@"ladyprofile"];
    [coder encodeBool:self.livechat forKey:@"livechat"];
    [coder encodeBool:self.admirer forKey:@"admirer"];
    [coder encodeBool:self.bpemf forKey:@"bpemf"];
    [coder encodeBool:self.videoreceived forKey:@"videoreceived"];
}

@end
