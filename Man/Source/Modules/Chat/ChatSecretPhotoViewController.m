//
//  ChatSecretPhotoViewController.m
//  dating
//
//  Created by test on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatSecretPhotoViewController.h"
#import "AddCreditsViewController.h"

#import "LiveChatManager.h"
#import "RequestErrorCode.h"

typedef enum : NSUInteger {
    SecretPhotoStatusNormal,
    SecretPhotoStatusFee,
} SecretPhotoStatus;

@interface ChatSecretPhotoViewController ()<LiveChatManagerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) LiveChatManager *liveChatManager;
/** 私密照状态 */
@property (nonatomic,assign) SecretPhotoStatus status;
/** 私密照数据 */
@property (nonatomic,strong) UIImage *secretPhotoImage;
/**
 *  点击手势
 */
@property (strong) UIPinchGestureRecognizer* pinch;

/**
 *  当前获取图片
 */
@property (assign) GETPHOTO_PHOTOSIZE_TYPE photoSizeType;

@end

@implementation ChatSecretPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if( !self.viewDidAppearEver ) {
        CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        UIImageView *secretImageView = [[UIImageView alloc] initWithFrame:frame];
        secretImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.secretImageView = secretImageView;
        [self.view insertSubview:self.secretImageView atIndex:0];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        self.secretImageView.multipleTouchEnabled = YES;
        [self.secretImageView addGestureRecognizer:tap];
        self.secretImageView.userInteractionEnabled = YES;
        
        // 根据付费状态设置显示状态
        self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
        
        // 如果已经付费
        if( self.msgItem.secretPhoto.isGetCharge ) {
            if( !self.secretImageView.image ) {
                // 清晰图不存在, 直接下载
                [self downSecretPhotoAction:nil];
            }
        }
    }

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 界面初始化
- (void)setupContainView {
    [super setupContainView];
    
    self.buyBtn.layer.cornerRadius = 5.0f;
    self.buyBtn.layer.masksToBounds = YES;
    
    self.downBtn.layer.cornerRadius = 5.0f;
    self.downBtn.layer.masksToBounds = YES;
}

- (void)hideDownControll {
    self.downBtn.hidden = YES;
    self.downTip.hidden = YES;
}

- (void)showDownControll {
    self.downBtn.hidden = NO;
    self.downTip.hidden = NO;
}

- (void)hideBuyControll {
    self.creditTip.hidden = YES;
    self.buyBtn.hidden = YES;
}

- (void)showBuyControll {
    self.creditTip.hidden = NO;
    self.buyBtn.hidden = NO;
}

- (void)initCustomParam {
    [super initCustomParam]; 
    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
}

- (void)unInitCustomParam {
    [self.liveChatManager removeDelegate:self];
}

#pragma mark - 购买状态
- (void)setStatus:(SecretPhotoStatus)status {
    // 显示描述
    self.fileName.text = self.msgItem.secretPhoto.photoDesc;
    
    switch (status) {
        case SecretPhotoStatusNormal:{
            // 没付费状态(收到的图片)
            // 显示模糊图
            NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.showFuzzyFilePath];
            self.secretImageView.image = [UIImage imageWithData:data];
            if( self.secretImageView.image != nil ) {
                // 图片已经存在
                // 显示购买按钮, 提示信息
                [self showBuyControll];
                
            } else {
                // 获取模糊图, 显示菊花
                [self showLoading];
                [self.liveChatManager getPhoto:self.msgItem.fromId msgId:(int)self.msgItem.msgId sizeType:GPT_ORIGINAL];
    
            }
        }break;
        case SecretPhotoStatusFee:{
            // 付费状态
            // 隐藏购买控件
            [self hideBuyControll];
            [self hideDownControll];
            
            // 显示清晰图
            self.secretImageView.image = nil;
            if( self.msgItem.secretPhoto.srcFilePath.length > 0 ) {
                NSData *data = [NSData dataWithContentsOfFile:self.msgItem.secretPhoto.srcFilePath];
                self.secretImageView.image = [UIImage imageWithData:data];
            }
            
            if( self.secretImageView.image ) {
                // 图片已经存在
//                self.saveBtn.hidden = NO;
            
                // 增加手势
                [self.secretImageView removeGestureRecognizer:self.pinch];
                [self.secretImageView addGestureRecognizer:self.pinch];
                
            } else {
                // 显示下载控件
                [self showDownControll];
            }
            
        }break;
            
        default:
            break;
    }
}

#pragma mark - 界面事件
- (IBAction)buySecretPhotoAction:(id)sender {
    // 点击购买图片
    [self hideBuyControll];
    
    // 显示菊花
    [self showLoading];

    if( ![self.liveChatManager PhotoFee:self.msgItem.fromId msgId:(int)self.msgItem.msgId] ) {
        [self hideLoading];
    }

}

- (IBAction)downSecretPhotoAction:(id)sender {
    // 点击下载图片
    [self hideDownControll];
    
    if (self.msgItem.sendType == LCMessageItem::SendType_Send) {
        // 获取付费图片(自己发的图片), 显示菊花
        [self showLoading];
        [self.liveChatManager getPhoto:self.msgItem.toId msgId:(int)self.msgItem.msgId sizeType:GPT_ORIGINAL];
    } else {
        // 获取付费图片(收到的图片), 显示菊花
        [self showLoading];
        [self.liveChatManager getPhoto:self.msgItem.fromId msgId:(int)self.msgItem.msgId sizeType:GPT_ORIGINAL];
    }
}

/**
 *  下载图片写入相册
 *
 *
 */
- (IBAction)saveSecretPhotoAction:(id)sender {
    self.secretImageView.userInteractionEnabled = NO;
    if (self.secretImageView.image) {
        UIImageWriteToSavedPhotosAlbum(self.secretImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

/**
 *  保存图片下载完成回调
 *
 *  @param image       图片
 *  @param error       成功信息
 *  @param contextInfo 信息内容
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *successMsg = NSLocalizedStringFromSelf(@"Photo_Successful_Save");
    NSString *errorMsg = NSLocalizedStringFromSelf(@"Photo_Error");
    if (nil == error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:successMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil ,nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil,nil];
        [alert show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    self.secretImageView.userInteractionEnabled = YES;
}

#pragma mark - 手势回调
- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer{
    // 对图片进行缩放
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 私密照回调
- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgList:(NSArray<LiveChatMsgItemObject*>* _Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(LiveChatMsgItemObject* msgItem in msgList) {
            if( msgItem.msgId == self.msgItem.msgId ) {
                NSLog(@"ChatSecretPhotoViewController::onGetPhoto( 获取私密照 errType : %d, msgItem.msgId : %ld )", errType, (long)msgItem.msgId);
                
                // 停止菊花
                [self hideLoading];
                
                if (sizeType == GPT_ORIGINAL) {
                    // 保存数据
                    self.msgItem = msgItem;
                    
                    // 根据付费状态设置显示状态
                    self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
                }
            }
        }
        
    });
}

- (void)onPhotoFee:(bool)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( msgItem.msgId == self.msgItem.msgId ) {
            NSLog(@"ChatSecretPhotoViewController::onPhotoFee( 获取收费私密照 success : %d, path : %@ )", success, msgItem.secretPhoto.showSrcFilePath);
            // 保存数据
            self.msgItem = msgItem;
            
            // 停止菊花
            [self hideLoading];

            if( success ) {
                // 根据付费状态设置显示状态
                self.status = self.msgItem.secretPhoto.isGetCharge?SecretPhotoStatusFee:SecretPhotoStatusNormal;
                
                // 购买成功, 自动点击下载
                [self downSecretPhotoAction:nil];
                
            } else {
                if( [errNo isEqualToString:LIVECHAT_NO_MONEY] ) {
                    // 弹出买点
                    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromSelf(@"Add_More_Credits"), nil];
                    [sheet showInView:self.view];
                    
                } else {
                    // 直接提示错误信息
                    NSString* tips = NSLocalizedStringFromErrorCode(errNo);
                    if( tips == nil ) {
                        tips = errMsg;
                    }
                    
                    // 弹出重试
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
                    [alertView show];
                }
            }
            
        }
    });
}

#pragma mark - 底部弹出选择器回调
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if( buttonIndex != actionSheet.cancelButtonIndex ) {
        // 跳转买点
        AddCreditsViewController *vc = [[AddCreditsViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
