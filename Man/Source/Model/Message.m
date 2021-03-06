//
//  Message.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "Message.h"

@implementation Message

- (id)init {
    if( self = [super init] ) {
        self.msgId = -1;
        self.sender = MessageSenderUnknow;
        self.type = MessageTypeUnknow;
        self.status = MessageStatusUnknow;
        self.text = nil;
        self.attText = nil;
        self.secretPhotoImage = nil;
        self.emotionDefault = nil;
        self.emotionAnimationArray = nil;
//        self.attText = [[NSAttributedString alloc] init];
//        self.secretPhotoImage = [[UIImage alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.msgId = [coder decodeIntegerForKey:@"msgId"];
        self.text = [coder decodeObjectForKey:@"text"];
        self.attText = [coder decodeObjectForKey:@"attText"];
        self.sender = (Sender)[[coder decodeObjectForKey:@"sender"] intValue];
        self.type = (Type)[[coder decodeObjectForKey:@"type"] intValue];
        self.status = (Status)[[coder decodeObjectForKey:@"status"] intValue];
        self.secretPhotoImage = [coder decodeObjectForKey:@"secretPhotoImage"];
        self.emotionDefault = [coder decodeObjectForKey:@"emotionDefault"];
        self.emotionAnimationArray = [coder decodeObjectForKey:@"emotionAnimationArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.msgId forKey:@"msgId"];
    [coder encodeObject:self.text forKey:@"text"];
    [coder encodeObject:self.attText forKey:@"attText"];
    [coder encodeObject:[NSNumber numberWithInt:self.sender] forKey:@"sender"];
    [coder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
    [coder encodeObject:[NSNumber numberWithInt:self.status] forKey:@"status"];
    [coder encodeObject:self.secretPhotoImage forKey:@"secretPhotoImage"];
    [coder encodeObject:self.emotionDefault forKey:@"emotionDefault"];
    [coder encodeObject:self.emotionAnimationArray forKey:@"emotionAnimationArray"];
}

- (id)copyWithZone:(NSZone *)zone {
    Message *messageItem = [[[self class] allocWithZone:zone] init];
    messageItem.msgId = self.msgId;
    messageItem.text = [self.text copy];
    messageItem.attText = [self.attText copy];
    messageItem.sender = self.sender;
    messageItem.type = self.type;
    messageItem.status = self.status;
    messageItem.secretPhotoImage = [self.secretPhotoImage copy];
    messageItem.emotionDefault = [self.emotionDefault copy];
    messageItem.emotionAnimationArray = [[NSArray alloc] initWithArray:self.emotionAnimationArray copyItems:YES];
    return messageItem;
}
@end
