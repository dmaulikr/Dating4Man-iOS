//
//  MotifyPersonalProfileManager.m
//  dating
//
//  Created by lance on 16/8/3.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MotifyPersonalProfileManager.h"

#import "GetPersonProfileRequest.h"
#import "StartEditResumeRequest.h"
#import "UpdateProfileRequest.h"

@interface MotifyPersonalProfileManager ()

/** 任务管理 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;

/** 个人信息 */
@property (nonatomic,strong) PersonalProfile *personalItem;
@end


static MotifyPersonalProfileManager *gManager = nil;
@implementation MotifyPersonalProfileManager

+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.personalItem = nil;
        self.sessionManager = [SessionRequestManager manager]; 
    }
    return self;
}



- (void)motifyPersonalResume:(NSString *)resume {
    [self getPersonalProfileResume:resume];

}




- (BOOL)getPersonalProfileResume:(NSString *)resume{

    self.sessionManager = [SessionRequestManager manager];
    GetPersonProfileRequest *request = [[GetPersonProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success,PersonalProfile *item,NSString *error,NSString *errmsg){
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"MyProfileViewController::getPersonalProfile( 获取男士详情成功 )");
                self.personalItem = item;
                [self startEditResume:resume];
            });
            
        }else{
            if (self.delegate &&[self.delegate respondsToSelector:@selector(motifyPersonalProfileResult:result:)]) {
                [self.delegate motifyPersonalProfileResult:self result:NO];
            }
        }
        
    };
    return [self.sessionManager sendRequest:request];
}



- (BOOL)startEditResume:(NSString * _Nullable)resume {

    
    self.sessionManager = [SessionRequestManager manager];
    StartEditResumeRequest *request = [[StartEditResumeRequest alloc] init];
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                NSLog(@"MyProfileViewController::startEditResume( 开始计时成功 )");
                // 开始上传个人详情
                [self updateProfile:resume];
                
            } else {
                if (self.delegate &&[self.delegate respondsToSelector:@selector(motifyPersonalProfileResult:result:)]) {
                    [self.delegate motifyPersonalProfileResult:self result:NO];
                }
                // 弹出错误
//                NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                [alertView show];
            }
        });
    };
    
    return [self.sessionManager sendRequest:request];
}

- (BOOL)updateProfile:(NSString * _Nullable)resume{

    
    self.sessionManager = [SessionRequestManager manager];
    UpdateProfileRequest *request = [[UpdateProfileRequest alloc] init];
    request.resume = resume;
    request.height = self.personalItem.height;
    request.weight = self.personalItem.weight;
    request.smoke = self.personalItem.smoke;
    request.drink = self.personalItem.drink;
    request.religion = self.personalItem.religion;
    request.education = self.personalItem.education;
    request.profession = self.personalItem.profession;
    request.ethnicity = self.personalItem.ethnicity;
    request.income = self.personalItem.income;
    request.children = self.personalItem.children;
    request.interests = (NSMutableArray *)self.personalItem.interests;
    request.finishHandler  = ^(BOOL success,BOOL motify,NSString *error,NSString *errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{

            
            if( success ) {
                NSLog(@"MyProfileViewController::updateProfile( 更新男士详情成功 )");
                
                if( !motify ) {
//                    NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                    [alertView show];
                    if (self.delegate &&[self.delegate respondsToSelector:@selector(motifyPersonalProfileResult:result:)]) {
                        [self.delegate motifyPersonalProfileResult:self result:NO];
                    }
                    
                }
                if (self.delegate &&[self.delegate respondsToSelector:@selector(motifyPersonalProfileResult:result:)]) {
                    [self.delegate motifyPersonalProfileResult:self result:YES];
                }
            } else {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//                [alertView show];
                if (self.delegate &&[self.delegate respondsToSelector:@selector(motifyPersonalProfileResult:result:)]) {
                    [self.delegate motifyPersonalProfileResult:self result:NO];
                }
            }
            
        });
        
    };
    
    return [self.sessionManager sendRequest:request];
}

@end
