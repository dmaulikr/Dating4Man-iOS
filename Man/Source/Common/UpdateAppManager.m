//
//  UpdateAppManager.m
//  dating
//
//  Created by lance on 16/6/1.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "UpdateAppManager.h"


#import "ConfigManager.h"

#define UPDATEINFO_DIRECTORY    @"UpdateVersion"
#define UPDATEINFO_PLIST        @"UpdateVersionInfo"
#define APPLEID                 @"AppleId"
#define ID_KEY                  @"id"

static UpdateAppManager* gManager = nil;
@interface UpdateAppManager () 
@end

@implementation UpdateAppManager


#pragma mark - 获取实例
+ (instancetype)manager
{
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}


- (instancetype)init{
    if (self = [super init]) {
        
    }
    
    return self;
}



- (BOOL)isNewVersion:(NSString *)newVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDict objectForKey:@"Version"];
    NSArray *curArray = [curVersion componentsSeparatedByString:@"."];
    NSArray *newArray = [newVersion componentsSeparatedByString:@"."];
    // 从前面开始,比较相同位置的版本号,其中一个比当前新则返回真
    NSInteger arrayCount = MIN([curArray count], [newArray count]);
    
    for(int i = 0; i< arrayCount; i++) {

        if([[newArray objectAtIndex:i] integerValue] > [[curArray objectAtIndex:i] integerValue]) {
            return YES;
        }
        else if([[newArray objectAtIndex:i] integerValue] < [[curArray objectAtIndex:i] integerValue]){
            return NO;
        }
    }
    // 前面的版本号都相等,则当新版本号比当前版本号长返回真
    return ([newArray count] > [curArray count]?YES:NO);

}

- (BOOL)isNewVersionCode:(NSInteger)newVersionCode {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *curVersion = [infoDict objectForKey:@"Version"];
    NSInteger curVersionCode = [curVersion integerValue];
    return newVersionCode > curVersionCode?YES:NO;

}






#pragma mark - UpdateVersionInfoFunction
- (NSString*)updateVersionInfoPath{
    // 创建目录
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], UPDATEINFO_DIRECTORY]  withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@.%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], UPDATEINFO_DIRECTORY, UPDATEINFO_PLIST, @"plist"];

    return path;
}
- (BOOL)isBanned:(NSString *)newVersion {
 
    NSString *path = [self updateVersionInfoPath];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    id isBanned = [dict objectForKey:newVersion];
 return [isBanned boolValue];


}

- (BOOL)setUpdateVersionInfoBanned:(NSString *)version {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString *path = [self updateVersionInfoPath];
    [dict addEntriesFromDictionary:[NSMutableDictionary dictionaryWithContentsOfFile:path]];
    [dict setObject:[NSNumber numberWithBool:YES] forKey:version];
    return [dict writeToFile:path atomically:YES];
}





- (BOOL)sendUpdateRequest:(NSString *)url {

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *appleId = [infoDict objectForKey:APPLEID];
    [paramDict setObject:appleId forKey:ID_KEY];
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    
    return YES;
    
}

@end