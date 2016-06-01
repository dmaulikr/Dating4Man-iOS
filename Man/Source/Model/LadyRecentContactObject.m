//
//  LadyRecentContactObject.m
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyRecentContactObject.h"

@implementation LadyRecentContactObject


- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.womanId = [coder decodeObjectForKey:@"womanId"];
        self.firstname = [coder decodeObjectForKey:@"firstname"];
        self.age = [coder decodeIntegerForKey:@"age"];
        self.photoURL = [coder decodeObjectForKey:@"photoURL"];
        self.photoBigURL = [coder decodeObjectForKey:@"photoBigURL"];
        self.isFavorite = [coder decodeBoolForKey:@"isFavorite"];
        self.videoCount = [coder decodeIntegerForKey:@"videoCount"];
        self.lasttime = [coder decodeIntegerForKey:@"lasttime"];
        self.isOnline = [coder decodeBoolForKey:@"isOnline"];
        self.isInChat = [coder decodeBoolForKey:@"isInChat"];
        self.lastInviteMessage = [coder decodeObjectForKey:@"lastInviteMessage"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.womanId forKey:@"womanId"];
    [coder encodeObject:self.firstname forKey:@"firstname"];
    [coder encodeInteger:self.age forKey:@"age"];
    [coder encodeObject:self.photoURL forKey:@"photoURL"];
    [coder encodeObject:self.photoBigURL forKey:@"photoBigURL"];
    [coder encodeBool:self.isFavorite forKey:@"isFavorite"];
    [coder encodeInteger:self.videoCount forKey:@"videoCount"];
    [coder encodeInteger:self.lasttime forKey:@"lasttime"];
    [coder encodeBool:self.isOnline forKey:@"isOnline"];
    [coder encodeBool:self.isInChat forKey:@"isInChat"];
    [coder encodeObject:self.lastInviteMessage forKey:@"lastInviteMessage"];
}


- (id)copyWithZone:(NSZone *)zone {
    LadyRecentContactObject *contactObject = [[[self class] allocWithZone:zone] init];
    contactObject.womanId = self.womanId;
    contactObject.firstname = [self.firstname copyWithZone:zone];
    contactObject.age = self.age;
    contactObject.photoURL = [self.photoURL copyWithZone:zone];
    contactObject.photoBigURL = [self.photoBigURL copyWithZone:zone];
    contactObject.isFavorite = self.isFavorite;
    contactObject.videoCount = self.videoCount;
    contactObject.lasttime = self.lasttime;
    contactObject.isOnline = self.isOnline;
    contactObject.isInChat = self.isInChat;
    contactObject.lastInviteMessage = self.lastInviteMessage;
    return contactObject;
}
@end
