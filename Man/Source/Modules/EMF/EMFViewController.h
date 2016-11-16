//
//  EMFViewController.h
//  dating
//
//  Created by alex shum on 16/10/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"

@interface EMFViewController : KKViewController

// 用户登录账号
@property(nonatomic, strong) NSString* userId;
// 用户的登录Sid
@property(nonatomic, strong) NSString* userSid;
// 开始请求webview加载
@property (nonatomic, assign) BOOL requesStart;
// 是否处理了emf_mails的请求（防止其他请求成功，却只显示空白页）
@property (nonatomic, assign) BOOL isOpenWebview;
// EMF的webview
@property (weak, nonatomic) IBOutlet UIWebView *EMFWebView;
// 加载失败／重载提示框
@property (weak, nonatomic) IBOutlet UIView *failLoadView;
// 请求EMFwebview 加载
- (void)requestEMFWebview;
// EMFwebview重新加载事件
- (IBAction)reloadWebview:(id)sender;

@end
