//
//  ServerViewControllerManager.m
//  dating
//
//  Created by Max on 16/8/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ServerViewControllerManager.h"

#import "ChatViewController.h"
#import "ChatViewFakeController.h"

#import "LoginManager.h"
#import "ServerManager.h"

@interface ServerViewControllerManager () {
    
}
@end

static ServerViewControllerManager* gManager = nil;

@implementation ServerViewControllerManager
#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
    }
    return self;
}

- (UIViewController* )chatViewController:(NSString* )firstname womanid:(NSString* )womanid photoURL:(NSString* )photoURL {
    UIViewController* vc = nil;
    
    if( [ServerManager manager].item != nil && ![ServerManager manager].item.fake ) {
        // 真服务器
        ChatViewController* cvc = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        vc = cvc;
        
        cvc.firstname = firstname;
        cvc.womanId = womanid;
        cvc.photoURL = photoURL;

    }  else {
        // 假服务器
        ChatViewFakeController* cvc = [[ChatViewFakeController alloc] initWithNibName:nil bundle:nil];
        vc = cvc;
        
        cvc.firstname = firstname;
        cvc.womanId = womanid;
        cvc.photoURL = photoURL;
        
    }

    return vc;
}

@end
