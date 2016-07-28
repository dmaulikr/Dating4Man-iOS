//
//  CrashLogManager.m
//  dating
//
//  Created by test on 16/6/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CrashLogManager.h"
#import "LoginManager.h"
#import "RequestManager.h"
#import "UploadCrashLogRequest.h"
#include "common/KZip.h"

static CrashLogManager* gManager = nil;
@interface CrashLogManager()<LoginManagerDelegate,UIApplicationDelegate>
{
    NSUncaughtExceptionHandler *_handler;
}


/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;
@property (nonatomic, strong) LoginManager* loginManager;
@property (nonatomic,strong) RequestManager *requestManager;
/** crashLog路径 */
@property (nonatomic,strong) NSString *crashPath;

@end
@implementation CrashLogManager


#pragma mark - 获取实例
+ (instancetype)manager{
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}


- (instancetype)init
{
    if(self = [super init] ) {
        self.loginManager = [LoginManager manager];
        [self.loginManager addDelegate:self];
        self.sessionManager = [SessionRequestManager manager];
        // 初始化Crash Log捕捉
        _handler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(UncaughtExceptionHandler);

        
    }
    
    return self;
}

#pragma mark - 登录
/**
 *  LoginManager登录回调处理
 *
 *  @param manager   LoginManager
 *  @param success   是否成功
 *  @param loginItem 登录item
 *  @param errnum    登录结果code
 *  @param errmsg    登录结果描述
 */
- (void)manager:(LoginManager *)manager onLogin:(BOOL)success loginItem:(LoginItemObject *)loginItem errnum:(NSString *)errnum errmsg:(NSString *)errmsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            if ( [self checkCrashLogFiles] ) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //上传崩溃日志
                    [self uploadCrashLog:[[FileCacheManager manager] crashLogPath] tmpDirectory:[[FileCacheManager manager] tmpPath]];
                });
            }
        }
    });

}






#pragma mark - Crash处理
- (BOOL)logCrashToFile:(NSString *)errorString {
    BOOL bFlag = NO;
    
    // Crash Log写入到文件
    NSDate *curDate = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@.crash", [curDate toStringCrashZipDate], nil];
    NSString *filePath = [[[FileCacheManager manager] crashLogPath] stringByAppendingPathComponent:fileName];
    bFlag = [errorString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    if(bFlag) {
//        NSLog(@"CrashLogManager::logCrashToFile( crash log has been save : %@ )", filePath);
//               exit(9);
//    }
//    sleep(1000);
    return bFlag;
}



void UncaughtExceptionHandler(NSException *exception) {
    // Objective-C 异常处理, BAD_ACCESS等错误不能捕捉
    NSArray *stack = [exception callStackReturnAddresses];
    NSArray *symbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSMutableString *reportString = [NSMutableString string];
    

    // 设备
    [reportString appendFormat:@"Name = %@\n", [[UIDevice currentDevice] name]];
    [reportString appendFormat:@"Model = %@\n", [[UIDevice currentDevice] model]];
    [reportString appendFormat:@"System = %@\n", [[UIDevice currentDevice] systemName]];
    [reportString appendFormat:@"System-Version = %@\n", [[UIDevice currentDevice] systemVersion]];
    [reportString appendFormat:@"UUID = %@\n", [[UIDevice currentDevice] identifierForVendor]];

    // 程序
    [reportString appendFormat:@"CFBundleDisplayName = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [reportString appendFormat:@"CFBundleVersion = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [reportString appendFormat:@"Version = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"]];
    
    // 原因
    [reportString appendFormat:@"ExecptionName = %@\nReason = %@\n\nSymbols = %@\n\nStack = %@\n", name, reason, symbols, stack];
    
    // Crash Log写入到文件
    [[CrashLogManager manager] logCrashToFile:reportString];
   

}

/** 清除崩溃日志目录 */
- (BOOL)clearCrashLogs{
    NSString *crashPath = [[FileCacheManager manager] crashLogPath];
    BOOL success = YES;
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:crashPath];
    for (NSString *fileName in files) {
        
        NSError *error = nil;
        
        NSString *cachPath = [crashPath stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachPath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:cachPath error:&error];
            
            
        }else{
            success = NO;
        }
        
    }
    
    return success;
}

/**
 *  检查是否存在crash文件
 *
 *  @return <#return value description#>
 */
- (BOOL)checkCrashLogFiles {
    NSString *crashPath = [[FileCacheManager manager] crashLogPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    
    return (array.count > 0)?YES:NO;
}

#pragma mark - 上传日志
- (BOOL)uploadCrashLog:(NSString *)srcDirectory tmpDirectory:(NSString *)tmpDirectory {
    UploadCrashLogRequest *request = [[UploadCrashLogRequest alloc] init];
    request.srcDirectory = srcDirectory;
    request.tmpDirectory = tmpDirectory;
    request.finishHandler = ^(BOOL success , NSString * _Nonnull errnum, NSString * _Nonnull errmsg){
        if (success) {
            NSLog(@"CrashLogManager::uploadCrashLog( crash log has been upload : 上传崩溃日志成功");
            //上传日志成功,移除本地的崩溃日志
             [self clearCrashLogs];
            
           
        }
    };
    return [self.sessionManager sendRequest:request];
}





@end
