//
//  ChatViewController.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatViewController.h"
#import "AddCreditsViewController.h"
#import "LadyDetailViewController.h"
#import "ChatSecretPhotoViewController.h"

#import "ChatTextLadyTableViewCell.h"
#import "ChatTextSelfTableViewCell.h"
#import "ChatSystemTipsTableViewCell.h"
#import "ChatCouponTableViewCell.h"
#import "ChatWarningTipsTableViewCell.h"
#import "ChatPhotoLadyTableViewCell.h"
#import "ChatPhotoSelfTableViewCell.h"

#import "ChatEmotionChooseView.h"
#import "ChatPhotoView.h"

#import "Contact.h"
#import "Message.h"
#import "LiveChatManager.h"

#import "Masonry.h"

#import "LadyRecentContactObject.h"
#import "ContactManager.h"

#import "ChatPhoneAlbumPhoto.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#define ADD_CREDIT_URL @"ADD_CREDIT_URL"
#define INPUTMESSAGEVIEW_MAX_HEIGHT 44.0 * 2

#define TextMessageFontSize 18
#define SystemMessageFontSize 16
#define WarningMessageFontSize 16
#define MessageGrayColor [UIColor colorWithIntRGB:180 green:180 blue:180 alpha:255]
#define halfWidth self.view.frame.size.width * 0.5f

#define PreloadPhotoCount 10

typedef enum AlertType {
    AlertType200Limited = 100000,
    AlertTypeCameraAllow,
    AlertTypeCameraDisable,
    AlertTypePhotoAllow
} AlertType;

@interface ChatViewController () <UIAlertViewDelegate, ChatTextSelfDelegate, LiveChatManagerDelegate, KKCheckButtonDelegate, ChatEmotionChooseViewDelegate, TTTAttributedLabelDelegate, ChatTextViewDelegate, ImageViewLoaderDelegate,ChatPhotoViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,ChatPhotoLadyTableViewCellDelegate,ChatPhotoSelfTableViewCellDelegate> {
    CGRect _orgFrame;
}

/**
 *  表情键盘
 */
@property (nonatomic, strong) ChatEmotionChooseView *emotionInputView;

/**
 *  表情列表
 */
@property (nonatomic, retain) NSArray *emotionArray;
/**
 *  表情列表(用于查找)
 */
@property (nonatomic, retain) NSDictionary *emotionDict;

/**
 *  消息列表
 */
@property (nonatomic, retain) NSArray *msgArray;

/**
 *  自定义消息
 */
@property (nonatomic, retain) NSMutableDictionary *msgCustomDict;

/**
 *  Livechat管理器
 */
@property (nonatomic, strong) LiveChatManager *liveChatManager;

/**
 *  单击收起输入控件手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

/**
 *  头像下载器
 */
@property (nonatomic, strong) ImageViewLoader *imageViewLoader;

/** 相册图片路径 */
@property (atomic, strong) NSMutableArray *photoPathArray;

/** 照片相册 */
@property (nonatomic,strong) ChatPhotoView *photoView;

/** 消息数据 */
@property (nonatomic,strong) LiveChatMsgItemObject *msgItem;

/** 私密照路径 */
@property (nonatomic,strong) NSString *secretPath;

/**
 *  拍照按钮图片
 */
@property (strong) UIImage* cameraImage;

/**
 *  相册是否遇加载图片
 */
@property (atomic, assign) BOOL isMorePhoto;

/**
 *  停止加载相册
 */
@property (atomic, assign) BOOL isStop;
@end

@implementation ChatViewController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // 刷新相册
    self.isStop = NO;
    [self reloadPhotoViewLibrary];
    
    if( !self.viewDidAppearEver ) {
        // 刷新消息列表
        [self reloadData:YES];
        // 拉到最底
        [self scrollToEnd:NO];
        
        // 检测用户聊天状态
        LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
        if( user.chatType != LCUserItem::ChatType::LC_CHATTYPE_IN_CHAT_CHARGE ) {
            // 检测试聊券
            [self.liveChatManager checkTryTicket:self.womanId];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 去除键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    // 停止加载相册
    self.isStop = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
     self.backTitle = NSLocalizedString(@"Chat", nil);
     
    self.womanId = @"";
    self.firstname = @"";
    self.photoURL = @"";

    self.liveChatManager = [LiveChatManager manager];
    [self.liveChatManager addDelegate:self];
    
    // 读取表情配置文件
    NSString *emotionPlistPath = [[NSBundle mainBundle] pathForResource:@"EmotionList" ofType:@"plist"];
    NSArray* emotionFileArray = [[NSArray alloc] initWithContentsOfFile:emotionPlistPath];
    
    // 初始化表情文件名字
    NSMutableArray* emotionArray = [NSMutableArray array];
    NSMutableDictionary* emotionDict = [NSMutableDictionary dictionary];
    
    ChatEmotion* emotion = nil;
    UIImage* image = nil;
    NSString* imageFileName = nil;
    NSString* imageName = nil;
    
    for(NSDictionary* dict in emotionFileArray) {
        imageFileName = [dict objectForKey:@"name"];
        image = [UIImage imageNamed:imageFileName];
        if( image != nil ) {
            imageName = [self parseEmotionTextByImageName:imageFileName];
            emotion = [[ChatEmotion alloc] initWithTextImage:imageName image:image];
            
            [emotionDict setObject:emotion forKey:imageName];
            [emotionArray addObject:emotion];
        }
    }
    
    self.emotionDict = emotionDict;
    self.emotionArray = emotionArray;
    
    // 初始化自定义消息列表
    self.msgCustomDict = [NSMutableDictionary dictionary];

    // 相册
    self.cameraImage = [UIImage imageNamed:@"Chat-Camera"];

}

- (void)unInitCustomParam {
    [self.liveChatManager removeDelegate:self];
    
    // 清空自定义消息
    [self clearCustomMessage];

}

/**
 *  初始化导航栏
 */
- (void)setupNavigationBar {
    [super setupNavigationBar];

    // 标题
    ChatTitleView *titleView = [[ChatTitleView alloc] init];
    titleView.personName.text = self.firstname;
    titleView.personName.textColor = [UIColor whiteColor];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLadyDetail)];
    [titleView addGestureRecognizer:singleTap];
    
    self.navigationItem.titleView = titleView;
    
    self.imageViewLoader = [[ImageViewLoader alloc] init];
    self.imageViewLoader.view = titleView.personIcon;
    
    // 获取本批联系人用户信息
    [self.liveChatManager getUserInfo:self.womanId];

}

/**
 *  初始化界面
 */
- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
    [self setupInputView];
    [self setupMotionInputView];
    [self setupPhotoView];
    
}

/**
 *  初始化消息列表
 */
- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];

}

/**
 *  初始化输入框
 */
- (void)setupInputView {
    // 文字输入
    self.textView.placeholder = NSLocalizedStringFromSelf(@"Tips_Input_Message_Here");
    self.textView.chatTextViewDelegate = self;

    // 表情输入
    self.emotionBtn.adjustsImageWhenHighlighted = NO;
    self.emotionBtn.selectedChangeDelegate = self;
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionGray"] forState:UIControlStateNormal];
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionBlue" ] forState:UIControlStateSelected];
    
    // 私密照输入
    self.photoBtn.selectedChangeDelegate = self;
    [self.photoBtn setImage:[UIImage imageNamed:@"Chat-Keyboard-PhotoGray"] forState:UIControlStateNormal];
    [self.photoBtn setImage:[UIImage imageNamed:@"Chat-Keyboard-PhotoBlue" ] forState:UIControlStateSelected];
}

/**
 *  初始化表情选择器
 */
- (void)setupMotionInputView {
    if( self.emotionInputView == nil ) {
        self.emotionInputView = [ChatEmotionChooseView emotionChooseView:self];
        self.emotionInputView.delegate = self;
        
        [self.view addSubview:self.emotionInputView];
        [self.emotionInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.inputMessageView.mas_width);
            make.height.equalTo(@150);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(0);
        }];
        
        // 初始化表情图片
        self.emotionInputView.emotions = self.emotionArray;
        
        // 增加点击事件
        [self.emotionInputView.sendButton addTarget:self action:@selector(sendMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

/**
 *  初始化私密照选择器
 */
- (void)setupPhotoView {
    if (self.photoView == nil) {
        self.photoView = [ChatPhotoView PhotoView:self];
        self.photoView.delegate = self;
        
        [self.view addSubview:self.photoView];
        [self.photoView mas_updateConstraints:^(MASConstraintMaker *make) {
            //            make.width.equalTo(self.inputMessageView.mas_width);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.height.equalTo(self.emotionInputView.mas_height);
            make.top.equalTo(self.inputMessageView.mas_bottom).offset(0);
            
        }];
        
        self.photoView.showDifferentStyleBtn.selectedChangeDelegate = self;
//        [self.photoView.showDifferentStyleBtn addTarget:self action:@selector(selectedChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 *  跳转女士详情界面
 */
- (void)showLadyDetail {
    LadyDetailViewController* vc = [[LadyDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.womanId = self.womanId;
    vc.backToChat = YES;
    
    KKNavigationController* nvc = (KKNavigationController* )self.navigationController;
    [nvc pushViewController:vc animated:YES];
}

#pragma mark - 头像下载完成处理
- (void)loadImageFinish:(ImageViewLoader *)imageViewLoader success:(BOOL)success {

}

#pragma mark - 文本和表情输入控件管理
/**
 *  增加点击收起键盘手势
 */
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

/**
 *  移除点击收起键盘手势
 */
- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.tableView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

/**
 *  显示系统键盘
 */
- (void)showKeyboardView {
    // 增加手势
    [self addSingleTap];
    
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];
}

/**
 *  显示表情选择
 */
- (void)showEmotionView {
    // 增加手势
    [self addSingleTap];
    
    self.photoView.hidden = YES;
    
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
    if( self.inputMessageViewBottom.constant != -self.emotionInputView.frame.size.height ) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.emotionInputView.frame.size.height withDuration:0.25];
    }
}

/**
 *  关闭所有输入控件
 */
- (void)closeAllInputView {
    // 降低加速度
    self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    // 移除手势
    [self removeSingleTap];
    
    // 关闭表情输入
    if( self.emotionBtn.selected == YES ) {
        self.emotionBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
    }
    
    if (self.photoBtn.selected == YES) {
        self.photoBtn.selected = NO;
        [self moveInputBarWithKeyboardHeight:0 withDuration:0.25];
    }
    
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
}

#pragma mark - 点击按钮事件
/**
 *  点击发送
 *
 *  @param sender 按钮
 */
- (IBAction)sendMsgAction:(id)sender {
    if( self.textView.text.length > 0 ) {
        [self sendMsg:self.textView.text];
    }
}

/**
 *  显示私密照选择器
 */
- (void)showVisualableStylePhoto {
//    [self.photoView reloadData];
    
    [self addSingleTap];
    
    self.photoView.hidden = NO;
    // 关闭系统键盘
    [self.textView resignFirstResponder];
    
    if( self.inputMessageViewBottom.constant != -self.photoView.frame.size.height ) {
        // 未显示则显示
        [self moveInputBarWithKeyboardHeight:self.photoView.frame.size.height withDuration:0.25];
    }
}

/**
 *  显示全屏样式,暂时没有用到
 */
- (void)showFullScreenStyle {
    [self.photoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputMessageView.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.top.equalTo(self.view.mas_top).offset(0);
        
    }];
    
    [self.photoView layoutIfNeeded];
}

/**
 *  显示正常样式
 */
- (void)showNormalStyle {
    [self.photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputMessageView.mas_width);
        make.height.equalTo(self.emotionInputView.mas_height);
        make.top.equalTo(self.inputMessageView.mas_bottom).offset(0);
    }];
    [self.photoView layoutIfNeeded];
}

/**
 *  关闭相册图片选择
 */
- (void)closePhotoView {
    [self.photoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputMessageView.mas_width);
        make.height.equalTo(@0);
        make.top.equalTo(self.inputMessageView.mas_bottom).offset(0);
    }];
    [self.photoView layoutIfNeeded];
}

#pragma mark - 点击消息提示按钮
- (void)chatTextSelfRetryButtonClick:(ChatTextSelfTableViewCell *)cell {
    NSInteger index = cell.tag;
    [self handleErrorMsg:index];
}

#pragma mark - 点击弹窗提示
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger index = alertView.tag;

    if( index < self.msgArray.count ) {
        Message* msg = [self.msgArray objectAtIndex:index];
        LiveChatMsgProcResultObject* procResult = msg.liveChatMsgItemObject.procResult;

        if( procResult ) {
            switch (procResult.errType) {
                case LCC_ERR_FAIL:{
                    // php错误
                    if( [procResult.errNum isEqualToString:LIVECHAT_NO_MONEY] ) {
                        // 帐号余额不足, 弹出买点
                        [self addCreditsViewShow];
                    } else {
                        // 点击重发
                        if( buttonIndex != alertView.cancelButtonIndex ) {
                            [self reSendMsg:index];
                        }
                    }
                }break;
                case LCC_ERR_NOTRANSORAGENTFOUND:// 没有找到翻译或机构
                case LCC_ERR_BLOCKUSER:// 对方为黑名单用户（聊天）
                case LCC_ERR_SIDEOFFLINE:{
                    // 对方不在线（聊天）
                    // 重新获取当前女士用户状态
                    LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
                    if( user && user.statusType == USTATUS_ONLINE ) {
                        // 用户重新在线, 重发
                        if( buttonIndex != alertView.cancelButtonIndex ) {
                            [self reSendMsg:index];
                        }
                    }
                    
                }break;
                case LCC_ERR_NOMONEY:{
                    // 帐号余额不足, 弹出买点
                    [self addCreditsViewShow];
                    
                }break;
                default:{
                    // 其他未处理错误, 重发
                    if( buttonIndex != alertView.cancelButtonIndex ) {
                        [self reSendMsg:index];
                    }
                    
                }break;
            }
            
        } else {
            switch (index) {
                case AlertType200Limited:{
                    // 200个字符限制
                }break;
                case AlertTypeCameraAllow:{
                    // 不允许相机提示
                }break;
                case AlertTypeCameraDisable:{
                    // 不能使用相册提示
                }break;
                case AlertTypePhotoAllow:{
                    // 不允许相册提示
                }break;
                    
                default:
                    break;
            }
        }
    }
    
}

#pragma mark - 点击超链接回调
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:ADD_CREDIT_URL] ) {
        [self addCreditsViewShow];
    }
}

#pragma mark - 表情按钮选择回调
- (void)selectedChanged:(id)sender {
    
    if ([sender isEqual:self.photoView.showDifferentStyleBtn]) {
        UIButton *btn = (UIButton *)sender;
        
        if (btn.selected == YES) {
            [self showFullScreenStyle];
        }else{
            [self showNormalStyle];
        }
    }else if ([sender isEqual:self.photoBtn]){
        
            // 取消按钮点击
            [self.textView endEditing:YES];
            
            UIButton *photoBtn = (UIButton *)sender;
        // 不允许访问相册,弹出提示
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
            NSString *photoLibraryAllow = NSLocalizedStringFromSelf(@"Tips_PhotoLibrary_Allow");
            UIAlertView *photoAllowAlert = [[UIAlertView alloc] initWithTitle:nil message:photoLibraryAllow delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
            photoAllowAlert.tag = AlertTypePhotoAllow;
            [photoAllowAlert show];
            return;
        }else {
            // 允许访问相册,允许按钮操作弹出相册栏
            if( photoBtn.selected == YES ) {
                self.emotionBtn.selected = NO;
                // 显示相册
                [self showVisualableStylePhoto];
                
            } else {
                // 切换成系统的的键盘
                [self showKeyboardView];
            }
        }


    }else{
        [self.textView endEditing:YES];
        
        UIButton *emotionBtn = (UIButton *)sender;
        if( emotionBtn.selected == YES ) {
            self.photoBtn.selected = NO;
            // 替换系统键盘成emotion的键盘
            //        self.textView.inputView = self.emotionInputView;
            //        self.emotionInputView.frame = CGRectMake(0, 0, self.view.frame.size.width, 218);
            //        [self.emotionInputView layoutIfNeeded];
            //
            //        [self.emotionInputView reloadData];
            //        [self.textView becomeFirstResponder];
            
            // 弹出底部emotion的键盘
            [self showEmotionView];
            
        } else {
            // 切换成系统的的键盘
            [self showKeyboardView];
        }
    }
}

#pragma mark - 选择表情回调
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectItem:(NSInteger)item {
    // 插入表情到输入框
    ChatEmotion* emotion = [self.emotionArray objectAtIndex:item];
    [self.textView insertEmotion:emotion];
}

#pragma mark - 选择私密照回调
- (NSInteger)itemCountInChatPhotoView:(ChatPhotoView *)chatPhotoView {
    NSInteger count = self.photoPathArray.count + 1;
    return count;
}

- (UIImage* )chatPhotoView:(ChatPhotoView *)chatPhotoView shouldDisplayItem:(NSInteger)item {
    UIImage* image;

    if( item <= 0 ) {
        // 显示拍摄图片
        image = self.cameraImage;
        
    } else {
        // 直接获取缓存
        ChatPhoneAlbumPhoto* albumPhoto = [self.photoPathArray objectAtIndex:item - 1];
        NSString* path = albumPhoto.filePath;
        NSData *data = [NSData dataWithContentsOfFile:path];
        image = [UIImage imageWithData:data];

    }
    
//    if( item == chatPhotoView.count - 1 && self.isMorePhoto ) {
//        self.isMorePhoto = NO;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.photoView reloadData];
//        });
//
//    }
    
    return image;
}

- (void)chatPhotoView:(ChatPhotoView *)chatPhotoView didSelectItem:(NSInteger)item {
    // 判断是否在聊用户
    if( [[ContactManager manager] isInChatUser:self.womanId] ) {
        // 选择相机
        if (item <= 0) {
            // 手机能否打开相机
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSString *mediaType = AVMediaTypeVideo;
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                // 是否给相机设置了可以访问权限
                if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                    // 无权限
                    NSString *cameraAllow = NSLocalizedStringFromSelf(@"Tips_Camera_Allow");
                    UIAlertView *cameraAlert = [[UIAlertView alloc] initWithTitle:nil message:cameraAllow delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
                    cameraAlert.tag = AlertTypeCameraAllow;
                    [cameraAlert show];
                    return;
                } else {
                    // 点击打开相机
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.allowsEditing = NO;
                    imagePicker.delegate = self;
                    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:imagePicker animated:YES completion:nil];
                }
                
            } else {
                NSString *disableCamera = NSLocalizedStringFromSelf(@"Tips_Camera_Disable");
                UIAlertView *cameraAlert = [[UIAlertView alloc] initWithTitle:nil message:disableCamera delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
                cameraAlert.tag = AlertTypeCameraDisable;
                [cameraAlert show];
            }
            
        } else {
            // 选择相册图片
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            ChatPhoneAlbumPhoto* albumPhoto = [self.photoPathArray objectAtIndex:item - 1];
            NSURL* url = albumPhoto.assertUrl;
            [library assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *ar = [asset defaultRepresentation];
                
                UIImageOrientation imageOrientation = (UIImageOrientation)[ar orientation];
                CGImageRef imageReference = [ar fullResolutionImage];
                UIImage *photoImage = [UIImage imageWithCGImage:imageReference scale:1.0 orientation:imageOrientation];
                
                // 去除图片旋转属性( fullResolutionImage 没有做旋转处理, fullScreenImage 做了旋转处理)
                UIImage* fixOrientationImage = [photoImage fixOrientation];
                
                // 保存到本地
                FileCacheManager *fileCacheManager = [FileCacheManager manager];
                NSString *path = [fileCacheManager imageUploadCachePath:fixOrientationImage fileName:ar.filename];
                
                // 发送图片
                [self sendPhoto:path];
                
            } failureBlock:^(NSError *error) {
                // 获取图片失败
                NSString *photoLibraryAllow = NSLocalizedStringFromSelf(@"Tips_PhotoLibrary_Allow");
                UIAlertView *photoAllowAlert = [[UIAlertView alloc] initWithTitle:nil message:photoLibraryAllow delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Close", nil), nil];
                photoAllowAlert.tag = AlertTypePhotoAllow;
                [photoAllowAlert show];
            }];
        }
        
    } else {
        // 必须开聊才能发送图片
        NSString *inChatTips = NSLocalizedStringFromSelf(@"Tips_InChat");
        UIAlertView *chatAlertView = [[UIAlertView alloc] initWithTitle:nil message:inChatTips delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [chatAlertView show];
    }

}

/**
 *  拍摄完图片回调
 *
 *  @param picker 相机控制
 *  @param info   图片的相关信息
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        FileCacheManager *fileCacheManager = [FileCacheManager manager];
        UIImage* image = info[UIImagePickerControllerOriginalImage];
        UIImage* fixOrientationImage = [image fixOrientation];
        
        NSString *path = [fileCacheManager imageUploadCachePath:fixOrientationImage fileName:@"secretFile"];
        [self sendPhoto:path];
    }];
    
}

/**
 *  结束操作
 *
 *  @param picker 相机控制
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 数据逻辑
/**
 *  生成相册缓存
 */
- (void)reloadPhotoViewLibrary {
    // 初始化照片
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *photoPathArray = [[NSMutableArray alloc] init];
    
//    [self.photoView reloadData];
    
//    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    NSArray* array = [NSArray arrayWithObjects:indexPath, nil];
//    [self.photoView reloadItemsAtIndexPaths:array];

    // 获取手机相册图片
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            *stop = self.isStop;
            
            if (group) {
                __block NSInteger iCount = 1;
                __block NSMutableArray* arrayIndexPath = [[NSMutableArray alloc] init];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        *stop = self.isStop;
                        
                        ALAssetRepresentation *ar = [result defaultRepresentation];

                        // 增加缩略图
//                        UIImage *photoImage = [UIImage imageWithCGImage:[result thumbnail]];
                        
                        // 生成屏幕大小的图(默认已经做了旋转处理)
                        CGImageRef imageReference = [ar fullScreenImage];
                        UIImage* photoImage = [UIImage imageWithCGImage:imageReference scale:1.0 orientation:UIImageOrientationUp];
                        
                        CGFloat imageScale = photoImage.size.height / (2 * self.photoView.bounds.size.height);
                        CGFloat width = photoImage.size.width / imageScale;
                        CGSize size = CGSizeMake(width, 2 * self.photoView.bounds.size.height);
                        
                        UIImage* scaleImage = [photoImage scaleToSize:size];
                        
                        NSString* filePath = [[FileCacheManager manager] imageCacheFromPhoneAlbumnPath:scaleImage fileName:ar.filename];
                        
                        // 增加相册图片缓存
                        ChatPhoneAlbumPhoto* albumPhoto = [[ChatPhoneAlbumPhoto alloc] init];
                        // 缩略图片缓存路径
                        albumPhoto.filePath = filePath;
                        // 相册原图路径
                        albumPhoto.assertUrl = ar.url;
                        // 相册Item
                        [photoPathArray addObject:albumPhoto];
                        
                        // 刷新界面
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(index + 1) inSection:0];
                        [arrayIndexPath addObject:indexPath];
                        
                        if( index == group.numberOfAssets - 1 || iCount++ % PreloadPhotoCount == 0 ) {
                            // 加载相册图片完成
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // 刷新图片选择器数据
                                self.photoPathArray = photoPathArray;
                                
                                // 刷新图片选择器界面
//                                [self.photoView reloadData];
                                
                                // 没有显示私密照选择界面||第一个||已经到最后一个
                                if( !self.photoBtn.selected || self.photoView.count <= 1 || ([self.photoView lastVisableIndex].row == self.photoView.count - 1) ) {
                                    NSLog(@"ChatViewController::reloadPhotoViewLibrary( self.photoPathArray.count : %ld )", (long)self.photoPathArray.count);
                                    [self.photoView reloadData];
                                } else {
                                    self.isMorePhoto = YES;
                                }
                                
                            });
                            
                            iCount = 1;
                        }
                        
                    }
                }];
                
            }
        } failureBlock:^(NSError *error) {
            
        }];
    });
}

/**
 *  更新最近联系人数据
 *
 *  @param msg 最近联系人数据
 */
- (void)updateRecents:(LiveChatMsgItemObject* )msg {
    // 更新最近联系人数据
    LadyRecentContactObject* recent = [[ContactManager manager] getOrNewRecentWithId:self.womanId];
    recent.firstname = self.firstname;
    recent.photoURL = self.photoURL;
    recent.lasttime = msg.createTime;
    // 更新联系人列表
    [[ContactManager manager] updateRecents];
}

/**
 *  重发消息
 *
 *  @param msg 消息体
 */
- (void)reSendMsg:(NSInteger)index {
    if( index < self.msgArray.count ) {
        Message* msg = [self.msgArray objectAtIndex:index];
        
        // 删除旧信息
        [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
        [self reloadData:NO];
        
        // 刷新列表
        [self.tableView beginUpdates];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        // 重新发送
        switch (msg.type) {
            case MessageTypeText:{
                [self sendMsg:msg.text];
            }break;
            case MessageTypePhoto:{
                [self sendPhoto:msg.liveChatMsgItemObject.secretPhoto.srcFilePath];
            }break;
            default:
                break;
        }
        
    }

}

/**
 *  发送文本
 *
 *  @param text 发送文本
 */
- (void)sendMsg:(NSString* )text {
    if( text.length > 200 ) {
        NSString* tips = NSLocalizedStringFromSelf(@"Local_Error_Tips_200_Input_Limited");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        alertView.tag = AlertType200Limited;
        [alertView show];
        return;
    }
    
    // 发送消息
    LiveChatMsgItemObject* msg = [self.liveChatManager sendTextMsg:self.womanId text:text];
    if( msg != nil ) {
        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, msgId : %ld )", text, (long)msg.msgId);
        
        // 更新最近联系人数据
        [self updateRecents:msg];
        
    } else {
        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, 失败 )", text);
    }
    
    // 刷新输入框
    [self.textView setText:@""];
    // 刷新默认提示
    [self.textView setNeedsDisplay];
    
    // 刷新列表
    [self reloadData:YES];
    // 拉到最低
    [self scrollToEnd:YES];
}

/**
 *  发送私密照
 *
 *  @param filePath 图片路径
 */
- (void)sendPhoto:(NSString* )filePath {
    LiveChatMsgItemObject *msg = [self.liveChatManager SendPhoto:self.womanId PhotoPath:filePath];
    self.msgItem = msg;
    
    if( msg != nil ) {
        NSLog(@"ChatViewController::sendPhoto( 发送私密照消息 : %@, msgId : %ld )", msg.secretPhoto.srcFilePath , (long)msg.msgId);
        
        // 更新最近联系人数据
        [self updateRecents:msg];
        
    } else {
        NSLog(@"ChatViewController::sendPhoto( 发送私密照消息 : %@, 失败 )", msg.secretPhoto.srcFilePath);
    }
    
    // 刷新列表
    [self reloadData:YES];
    // 拉到最低
    [self scrollToEnd:YES];
}

/**
 *  重新加载消息到界面
 *
 *  @param isReloadView 是否刷新界面
 */
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    NSMutableArray* dataArray = [NSMutableArray array];
    NSArray* array = [self.liveChatManager getMsgsWithUser:self.womanId];
    for(LiveChatMsgItemObject* msg in array) {
        Message* item = [[Message alloc] init];
        item.liveChatMsgItemObject = msg;
        item.msgId = msg.msgId;
        
        if( msg.msgType == LCMessageItem::MessageType::MT_Custom ) {
            // 自定义消息
            Message* custom = [self.msgCustomDict valueForKey:[NSString stringWithFormat:@"%ld", (long)msg.msgId]];
            if( custom != nil ) {
                item = [custom copy];
            }
            
        } else {
            // 其他
            
            // 方向
            switch (msg.sendType) {
                case LCMessageItem::SendType::SendType_Send:{
                    // 发出去的消息
                    item.sender = MessageSenderSelf;
                    
                }break;
                case LCMessageItem::SendType::SendType_Recv:{
                    // 接收到的消息
                    item.sender = MessageSenderLady;
                    
                }break;
                case LCMessageItem::SendType::SendType_System:{
                    // 系统消息
                }break;
                default:
                    break;
            }
            
            // 类型
            switch (msg.msgType) {
                case LCMessageItem::MessageType::MT_Text:{
                    // 文本
                    item.type = MessageTypeText;
                    item.text = msg.textMsg.displayMsg;
                    item.attText = [self parseMessageTextEmotion:item.text font:[UIFont systemFontOfSize:TextMessageFontSize]];
                    
                }break;
                case LCMessageItem::MessageType::MT_System:{
                    item.type = MessageTypeSystemTips;
                    
                    switch (msg.systemMsg.codeType) {
                        case LCSystemItem::MESSAGE:{
                            // 普通系统消息
                            item.text = msg.systemMsg.message;
                            
                        }break;
                        case LCSystemItem::TRY_CHAT_END:{
                            // 试聊结束消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_Your_Free_Chat_Is_Ended");
                            
                        }break;
                        case LCSystemItem::NOT_SUPPORT_TEXT:{
                            // 不支持文本消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_Text_Not_Support");
                            
                        }break;
                        case LCSystemItem::NOT_SUPPORT_EMOTION:{
                            // 试聊券系统消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_Emotion_Not_Support");
                            
                        }break;
                        case LCSystemItem::NOT_SUPPORT_VOICE:{
                            // 不支持语音消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_Voice_Not_Support");
                            
                        }break;
                        case LCSystemItem::NOT_SUPPORT_PHOTO:{
                            // 不支持私密照消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_Photo_Not_Support");
                            
                        }break;
                        case LCSystemItem::NOT_SUPPORT_MAGICICON:{
                            // 不支持小高表消息
                            item.text = msg.systemMsg.message;
                            item.text = NSLocalizedStringFromSelf(@"Tips_MagicIcon_Not_Support");
                            
                        }break;
                        default:
                            break;
                    }
                    
                    item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];
                    
                }break;
                case LCMessageItem::MessageType::MT_Warning:{
                    item.type = MessageTypeWarningTips;
                    switch (msg.warningMsg.codeType) {
                        case LCWarningItem::CodeType::NOMONEY:{
                            item.text = msg.warningMsg.message;
                            NSString* tips = NSLocalizedStringFromSelf(@"Warning_Error_Tips_No_Money");
                            NSString* linkMessage = NSLocalizedStringFromSelf(@"Tips_Add_Credit");
                            item.attText = [self parseNoMomenyWarningMessage:tips linkMessage:linkMessage font:[UIFont systemFontOfSize:WarningMessageFontSize] color:MessageGrayColor];
                            
                        }break;
                        default:{
                            item.text = msg.warningMsg.message;
                            item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];
                            
                        }break;
                            
                    }
                }break;
                case LCMessageItem::MessageType::MT_Photo:{
                    item.type = MessageTypePhoto;
                    item.secretPhotoImage = [UIImage imageNamed:@"Chat-SecretPlaceholder"];
                    
                    // 私密照
                    switch (item.sender) {
                        case MessageSenderLady:{
                            if (msg.secretPhoto) {
                                // 已经购买
                                if (msg.secretPhoto.isGetCharge) {
                                    // 获取本地清晰图片
                                    // 必须先重文件读取完整data, 如果用imageWithContentsOfFile读取会被修改的文件会crash
                                    NSData *data = [NSData dataWithContentsOfFile:msg.secretPhoto.showSrcFilePath];
                                    UIImage *secretPhotoImage = [UIImage imageWithData:data];
                                    
                                    if ( secretPhotoImage == nil ) {
                                        // 获取清晰图
                                        [self.liveChatManager getPhoto:msg.fromId msgId:(int)msg.msgId sizeType:GPT_LARGE];
                                        
                                    } else {
                                        item.secretPhotoImage = secretPhotoImage;
                                    }
                                    
                                } else {
                                    // 未购买
                                    // 获取本地模糊图
                                    NSData *data = [NSData dataWithContentsOfFile:msg.secretPhoto.showFuzzyFilePath];
                                    UIImage *secretPhotoImage = [UIImage imageWithData:data];
                                    
                                    if ( secretPhotoImage == nil ) {
                                        // 获取模糊图
                                        [self.liveChatManager getPhoto:msg.fromId msgId:(int)msg.msgId sizeType:GPT_LARGE];
                                    } else {
                                        item.secretPhotoImage = secretPhotoImage;
                                    }
                                }
                            }
                        }break;
                        case MessageSenderSelf:{
                            if (msg.secretPhoto) {
                                // 显示清晰图
                                NSData *data = nil;
                                UIImage* secretPhotoImage = nil;
                                if( msg.secretPhoto.srcFilePath.length > 0 ) {
                                    data = [NSData dataWithContentsOfFile:msg.secretPhoto.srcFilePath];
                                    secretPhotoImage = [UIImage imageWithData:data];
                                } else if( msg.secretPhoto.showSrcFilePath.length > 0 ) {
                                    data = [NSData dataWithContentsOfFile:msg.secretPhoto.showSrcFilePath];
                                    secretPhotoImage = [UIImage imageWithData:data];
                                }
                                
                                if ( secretPhotoImage == nil ) {
                                    [self.liveChatManager getPhoto:msg.toId msgId:(int)msg.msgId sizeType:GPT_LARGE];
                                } else {
                                    item.secretPhotoImage = secretPhotoImage;
                                }
                            }
                        }
                            
                        default:
                            break;
                    }

                }break;
                default:
                    break;
            }
            
            // 状态
            switch (msg.statusType) {
                case LCMessageItem::StatusType::StatusType_Processing:{
                    // 处理中
                    item.status = MessageStatusProcessing;
                }break;
                case LCMessageItem::StatusType::StatusType_Fail:{
                    // 失败
                    item.status = MessageStatusFail;
                }break;
                case LCMessageItem::StatusType::StatusType_Finish:{
                    // 完成
                    item.status = MessageStatusFinish;
                }break;
                    
                default:
                    break;
            }
        }

        [dataArray addObject:item];
    }
    self.msgArray = dataArray;
    
    if(isReloadView) {
        [self.tableView reloadData];
    }
}

- (Message* )insertCustomMessage {
    // 自定义消息类型
    LiveChatMsgItemObject* msg = [[LiveChatMsgItemObject alloc] init];
    msg.msgType = LCMessageItem::MessageType::MT_Custom;
    msg.createTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    
    // 无用代码
    msg.customMsg = [[LiveChatCustomItemObject alloc] init];
    
    // 记录自定义消息
    Message* custom = [[Message alloc] init];
    
    NSInteger msgId = [self.liveChatManager insertHistoryMessage:self.womanId msg:msg];
    custom.msgId = msgId;
    
    [self.msgCustomDict setValue:custom forKey:[NSString stringWithFormat:@"%ld", (long)msgId]];
    
    return custom;
}

/**
 *  清空自定义消息
 */
- (void)clearCustomMessage {
    for(NSString *key in self.msgCustomDict) {
        Message* msg = [self.msgCustomDict valueForKey:key];
        [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
    }

}

/**
 *  显示买点view
 */
- (void)addCreditsViewShow {
    AddCreditsViewController* vc = [[AddCreditsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  消息列表滚动到最底
 */
- (void)scrollToEnd:(BOOL)animated {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if( self.msgArray.count > 0 ) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0];
//            NSIndexPath* lastVisibleIndexPath = [self.tableView.indexPathsForVisibleRows lastObject];
            
//            BOOL animated = NO;
//            if( lastVisibleIndexPath.row != indexPath.row ) {
//                animated = YES;
//            }

            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}

- (void)getLadyDetail {
    // 获取本批联系人用户信息
    [self.liveChatManager getUsersInfo:[NSArray arrayWithObject:self.womanId]];
}

/**
 *  错误消息处理
 *
 *  @param msg 消息下标
 */
- (void)handleErrorMsg:(NSInteger)index {
    Message* msg = [self.msgArray objectAtIndex:index];
    LiveChatMsgProcResultObject* procResult = msg.liveChatMsgItemObject.procResult;
    
    if( procResult ) {
        switch (procResult.errType) {
            case LCC_ERR_FAIL:{
                // php错误
                if( [procResult.errNum isEqualToString:LIVECHAT_NO_MONEY] ) {
                    // 帐号余额不足, 弹出买点
                    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_No_Money");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                    alertView.tag = index;
                    [alertView show];
                    
                } else {
                    // 直接提示错误信息
                    NSString* tips = NSLocalizedStringFromErrorCode(procResult.errNum);
                    if( tips.length == 0 ) {
                        tips = procResult.errMsg;
                    }
                    
                    if( tips.length == 0 ) {
                        tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Other");
                    }
                    
                    // 弹出重试
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
                    
                    alertView.tag = index;
                    [alertView show];
                }
            }break;
            case LCC_ERR_UNBINDINTER:// 女士的翻译未将其绑定
            case LCC_ERR_SIDEOFFLINE:// 对方不在线
            case LCC_ERR_NOTRANSORAGENTFOUND:// 没有找到翻译或机构
            case LCC_ERR_BLOCKUSER:// 对方为黑名单用户（聊天）
            {
                // 重新获取当前女士用户状态
                LiveChatUserItemObject* user = [self.liveChatManager getUserWithId:self.womanId];
                if( user && user.statusType == USTATUS_ONLINE ) {
                    // 弹出重试
                    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Retry");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
                    
                    alertView.tag = index;
                    [alertView show];
                    
                } else {
                    // 弹出不在线
                    NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Offline");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil];
                    alertView.tag = index;
                    [alertView show];
                }
                
            }break;
            case LCC_ERR_NOMONEY:{
                // 帐号余额不足, 弹出买点
                NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_No_Money");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                alertView.tag = index;
                [alertView show];
                
            }break;
            default:{
                // 其他未处理错误
                NSString* tips = NSLocalizedStringFromSelf(@"Send_Error_Tips_Other");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
                
                alertView.tag = index;
                [alertView show];
                
            }break;
        }
    }
}

#pragma mark - 消息列表文本解析
/**
 *  根据表情文件名字生成表情协议名字
 *
 *  @param imageName 表情文件名字
 *
 *  @return 表情协议名字
 */
- (NSString* )parseEmotionTextByImageName:(NSString* )imageName {
    NSMutableString* resultString = [NSMutableString stringWithString:imageName];
    
    NSRange range = [resultString rangeOfString:@"img"];
    if( range.location != NSNotFound ) {
        [resultString replaceCharactersInRange:range withString:@"[img:"];
        [resultString appendString:@"]"];
    }
    
    return resultString;
}

/**
 *  解析消息表情和文本消息
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange range;
    NSRange endRange;
    NSRange valueRange;
    NSRange replaceRange;
    
    NSString* emotionOriginalString = nil;
//    NSString* emotionString = nil;
//    NSString* emotionFileString = nil;
    
    NSAttributedString* emotionAttString = nil;
    ChatTextAttachment *attachment = nil;
//    UIImage* image = nil;
    
    NSString* findString = attributeString.string;
    
    // 替换img
    while (
           (range = [findString rangeOfString:@"[img:"]).location != NSNotFound &&
           (endRange = [findString rangeOfString:@"]"]).location != NSNotFound &&
           range.location < endRange.location
           ) {
        // 增加表情文本
        attachment = [[ChatTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
        
        // 解析表情字串
        valueRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        // 原始字符串
        emotionOriginalString = [findString substringWithRange:valueRange];
//        // 截取表情下标
//        valueRange = NSMakeRange(NSMaxRange(range), endRange.location - NSMaxRange(range));
//        emotionString = [findString substringWithRange:valueRange];
        
        // 创建表情
//        emotionFileString = [NSString stringWithFormat:@"img%@", emotionString];
        ChatEmotion* emotion = [self.emotionDict objectForKey:emotionOriginalString];
        if( emotion != nil ) {
            attachment.image = emotion.image;
        }
        
        attachment.text = emotionOriginalString;
        
        // 生成表情富文本
        emotionAttString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        // 替换普通文本为表情富文本
        replaceRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
        [attributeString replaceCharactersInRange:replaceRange withAttributedString:emotionAttString];

        // 替换查找文本
        findString = attributeString.string;
    }
    
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
    
    return attributeString;
    
}

/**
 *  解析普通消息
 *
 *  @param text 普通文本
 *  @param font        字体
 *  @return 普通富文本消息
 */
- (NSAttributedString* )parseMessage:(NSString* )text font:(UIFont* )font color:(UIColor *)textColor{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)
    ];
    return attributeString;
}

/**
 *  解析没钱警告消息
 *
 *  @param text 没钱警告消息
 *  @param linkMessage 可以点击的文字
 *  @param font        字体
 *  @return 没钱富文本警告消息
 */
- (NSAttributedString* )parseNoMomenyWarningMessage:(NSString* )text linkMessage:(NSString* )linkMessage font:(UIFont* )font color:(UIColor *)textColor{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:textColor
                                     }
                             range:NSMakeRange(0, attributeString.length)];

    
    ChatTextAttachment *attachment = [[ChatTextAttachment alloc] init];
    attachment.text = linkMessage;
    attachment.url = [NSURL URLWithString:ADD_CREDIT_URL];
    attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
    NSMutableAttributedString *attributeLinkString = [[NSMutableAttributedString alloc] initWithString:linkMessage];
    [attributeLinkString addAttributes:@{
                                         NSFontAttributeName : font,
                                         NSAttachmentAttributeName : attachment,
//                                         NSUnderlineColorAttributeName : [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0],
//                                         NSForegroundColorAttributeName : [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0]
                                         } range:NSMakeRange(0, attributeLinkString.length)];
    
    [attributeString appendAttributedString:attributeLinkString];

    return attributeString;
}
#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.msgArray.count;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    // 数据填充
    Message* item = [self.msgArray objectAtIndex:indexPath.row];
    
    switch (item.type) {
        case MessageTypeSystemTips: {
            // 系统消息
            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatSystemTipsTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
            height = viewSize.height;
            
        }break;
        case MessageTypeWarningTips:{
            // 警告消息
            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatSystemTipsTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
            height = viewSize.height;

        }break;
        case MessageTypeText:{
            // 文本
            switch (item.sender) {
                case MessageSenderLady: {
                    // 对方
                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatTextLadyTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
                    height = viewSize.height;
                    
                }break;
                    
                case MessageSenderSelf:{
                    // 自己
                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatTextSelfTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
                    height = viewSize.height;
                    
                }break;
                default: {
                    
                }break;
            }
            
        }break;
        case MessageTypePhoto:{
            // 图片
            switch (item.sender) {
                case MessageSenderLady: {
                    // 对方
                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatPhotoLadyTableViewCell cellHeight]);
                    height = viewSize.height;
                    
                }break;
                    
                case MessageSenderSelf:{
                    // 自己
                    CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatPhotoSelfTableViewCell cellHeight]);
                    height = viewSize.height;
                    
                }break;
                default: {
                    
                }break;
            }
            
        }break;
        case MessageTypeCoupon:{
            // 试聊券
            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatCouponTableViewCell cellHeight]);
            height = viewSize.height;
            
        }break;
        default: {
            
        }break;
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;

    // 数据填充
    Message* item = [self.msgArray objectAtIndex:indexPath.row];
    
    switch (item.type) {
        case MessageTypeSystemTips: {
            // 系统提示
            ChatSystemTipsTableViewCell* cell = [ChatSystemTipsTableViewCell getUITableViewCell:tableView];
            result = cell;
            
            cell.detailLabel.attributedText = item.attText;
            cell.detailLabel.delegate = self;
            [item.attText enumerateAttributesInRange:NSMakeRange(0, item.attText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                ChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
                if( attachment && attachment.url != nil ) {
                    [cell.detailLabel addLinkToURL:attachment.url withRange:range];
                }
            }];
             
        }break;
        case MessageTypeWarningTips:{
            // 警告消息
            ChatSystemTipsTableViewCell* cell = [ChatSystemTipsTableViewCell getUITableViewCell:tableView];
            result = cell;
            
            cell.detailLabel.attributedText = item.attText;
            cell.detailLabel.delegate = self;
            [item.attText enumerateAttributesInRange:NSMakeRange(0, item.attText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                ChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
                if( attachment && attachment.url != nil ) {
                    [cell.detailLabel addLinkToURL:attachment.url withRange:range];
                }
            }];
            
        }break;
        case MessageTypeText:{
            // 文本
            switch (item.sender) {
                case MessageSenderLady: {
                    // 接收到的消息
                    ChatTextLadyTableViewCell* cell = [ChatTextLadyTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    // 用于点击重发按钮
                    result.tag = indexPath.row;
                    
                    cell.detailLabel.attributedText = item.attText;
                    
                }break;
                case MessageSenderSelf:{
                    // 发出去的消息
                    ChatTextSelfTableViewCell* cell = [ChatTextSelfTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    // 用于点击重发按钮
                    result.tag = indexPath.row;
                    
                    cell.delegate = self;
                    cell.detailLabel.attributedText = item.attText;
                    
                    switch (item.status) {
                        case MessageStatusProcessing: {
                            // 发送中
                            cell.activityIndicatorView.hidden = NO;
                            [cell.activityIndicatorView startAnimating];
                            cell.retryButton.hidden = YES;
                            
                        }break;
                        case MessageStatusFinish: {
                            // 发送成功
                            cell.activityIndicatorView.hidden = YES;
                            cell.retryButton.hidden = YES;
                            
                        }break;
                        case MessageStatusFail:{
                            // 发送失败
                            cell.activityIndicatorView.hidden = YES;
                            cell.retryButton.hidden = NO;
                            cell.delegate = self;
    
                        }break;
                        default: {
                            // 未知
                            cell.activityIndicatorView.hidden = YES;
                            cell.retryButton.hidden = YES;
                            cell.delegate = self;
                            
                        }break;
                    }
                    
                }break;
                default: {
                    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
                    result = cell;
                    
                }break;
            }
            
        }break;
        case MessageTypePhoto:{
            // 图片
            switch (item.sender) {
                case MessageSenderLady:{
                    // 接收到的消息
                    ChatPhotoLadyTableViewCell *cell = [ChatPhotoLadyTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    result.tag = indexPath.row;
                    cell.delegate = self;
                    //用于刷新图片
                    cell.detailLabel.text = [NSString stringWithFormat:@"\"%@\"", item.liveChatMsgItemObject.secretPhoto.photoDesc, nil];

                    //处理图片显示的大小
                    if (item.secretPhotoImage) {
                        cell.secretPhoto.image = item.secretPhotoImage;
                        if (cell.secretPhoto.image.size.height > 0) {
                            CGFloat heightScale = cell.secretPhoto.frame.size.height / cell.secretPhoto.image.size.height;
                            cell.secretPhoto.image = [cell.secretPhoto.image scaleToSize:CGSizeMake(cell.secretPhoto.image.size.width * heightScale, cell.secretPhoto.frame.size.height)];
                            
                            CGFloat receivePhotoWidth = cell.secretPhoto.image.size.width * cell.secretPhoto.frame.size.height / cell.secretPhoto.image.size.height;
                            if (receivePhotoWidth > halfWidth) {
                                receivePhotoWidth = halfWidth;
                            }
                            
                            cell.imageW.constant = receivePhotoWidth;
                            
                            [cell setNeedsLayout];
                        }
                        
                    }else {
                        cell.secretPhoto.image = [UIImage imageNamed:@"Chat-SecretPlaceholder"];
                        cell.loadingPhoto.hidden = YES;
                    }
                    
                }break;
                    
                case MessageSenderSelf:{
                    //发出的私密照
                    ChatPhotoSelfTableViewCell *cell = [ChatPhotoSelfTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    result.tag = indexPath.row;
                    cell.delegate = self;
                    
                    //处理图片显示的大小
                    if (item.secretPhotoImage != nil) {
                        cell.secretPhoto.image = item.secretPhotoImage;
                        
                        
                        if (cell.secretPhoto.image.size.height > 0) {
                            CGFloat receivePhotoWidth = cell.secretPhoto.image.size.width * cell.secretPhoto.frame.size.height / cell.secretPhoto.image.size.height;
                            if (receivePhotoWidth > halfWidth) {
                                receivePhotoWidth = halfWidth;
                            }
                            
                            cell.imageW.constant = receivePhotoWidth;
                            
//                            [cell setNeedsLayout];
                        }
                    }
                    
                    //获取图片发送的状态,显示图片以及加载状态
                    switch (item.status) {
                        case MessageStatusProcessing: {
                            // 发送中
                            cell.loadingActivity.hidden = NO;
                            cell.retryBtn.hidden = YES;
                            
                        }break;
                        case MessageStatusFinish: {
                            // 发送成功
                            [cell.loadingActivity stopAnimating];
                            cell.retryBtn.hidden = YES;
                            
                        }break;
                        case MessageStatusFail:{
                            // 发送失败
                            [cell.loadingActivity stopAnimating];
                            cell.retryBtn.hidden = NO;
                            cell.delegate = self;
                            
                        }break;
                        default: {
                            // 未知
                            [cell.loadingActivity stopAnimating];
                            cell.retryBtn.hidden = YES;
                            
                            
                        }break;
                    }
                    
                    
                }break;
                    
                default:
                    break;
            }
            
            
        }break;
        case MessageTypeCoupon:{
            // 试聊券
            ChatCouponTableViewCell *cell = [ChatCouponTableViewCell getUITableViewCell:tableView];
            result = cell;

        }break;
        default: {
            
        }break;
    }
    
    if( !result ) {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@""];
        if( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
        }
        result = cell;
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self closeAllInputView];
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    BOOL bFlag = NO;
    
    // Ensures that all pending layout operations have been completed
    [self.view layoutIfNeeded];
    
    if(height != 0) {
        // 弹出键盘
        
        // 增加加速度
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.inputMessageViewBottom.constant = -height;
        bFlag = YES;
        [self scrollToEnd:YES];
        
    } else {
        // 收起键盘
        self.inputMessageViewBottom.constant = 0;
        
    }
    
    [UIView animateWithDuration:duration animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if( bFlag ) {
            // 收起键盘
//            [self scrollToEnd];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    if( self.emotionBtn.selected == NO ) {
        // 没有选择表情
        [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    }else if (self.photoBtn.selected == NO) {
        [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    }

}

#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 增加手势
    [self addSingleTap];
    
    // 切换所有按钮到系统键盘状态
    self.emotionBtn.selected = NO;
    self.photoBtn.selected = NO;
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 检查是否系统表情
    if( [text isEmotion] ) {
        return NO;
    }
    
    // 判断输入的字是否是回车，即按下send
    if ([text isEqualToString:@"\n"]) {
        // 触发发送
        [self sendMsgAction:nil];
        return NO;
    }
    
    // 允许输入
    return YES;
}

#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(ChatTextView * _Nonnull)textView height:(CGFloat)height {
    if( height < INPUTMESSAGEVIEW_MAX_HEIGHT ) {
        self.inputMessageViewHeight.constant = height + 10;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView setNeedsDisplay];
    });
}

#pragma mark - LivechatManager回调
- (void)onSendTextMsg:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg msgItem:(LiveChatMsgItemObject* _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调 )");
        if( msg != nil ) {
            if( msg.statusType == LCMessageItem::StatusType_Finish ) {
                NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调, 发送成功 : %@, toId : %@ )", msg.textMsg.message, msg.toId);
            } else {
                NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调, 发送失败 : %@, toId : %@, errMsg : %@ )", msg.textMsg.message, msg.toId, errMsg);
            }
            
            [self reloadData:YES];
        }
        
    });

}

- (void)onSendTextMsgsFail:(LCC_ERR_TYPE)errType msgs:(NSArray* _Nonnull)msgs {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"ChatViewController::onSendTextMsgsFail( 发送消息失败回调（多条）)");
        for(LiveChatMsgItemObject* msg in msgs) {
            // 当前聊天女士才显示
            if( [msg.fromId isEqualToString:self.womanId] ) {
                NSLog(@"ChatViewController::onSendTextMsgsFail( 发送消息失败回调（多条）: %@ )", msg);
            }
        }
        [self reloadData:YES];
    });
}

- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvTextMsg( 接收文本消息回调 fromId : %@, message : %@ )", msg.fromId, msg.textMsg.message);
            
            [self reloadData:YES];
            [self scrollToEnd:YES];
        }
    });
}

- (void)onRecvSystemMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvSystemMsg( 接收系统消息回调 fromId : %@, message : %@ )", msg.fromId, msg.systemMsg.message);
            [self reloadData:YES];
            [self scrollToEnd:YES];
        }
    });
}

- (void)onRecvWarningMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvWarningMsg( 接收警告消息 fromId : %@, message : %@ )", msg.fromId, msg.warningMsg.message);
            [self reloadData:YES];
            [self scrollToEnd:YES];
        }
    });
}

- (void)onRecvEditMsg:(NSString* _Nonnull)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [userId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvEditMsg( 对方编辑消息回调 )");
            [self reloadData:YES];
            [self scrollToEnd:YES];
        }
    });
}

- (void)onGetHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [userId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onGetHistoryMessage( 获取单个用户历史聊天记录 )");
            [self reloadData:YES];
            [self scrollToEnd:YES];
        }
    });
}

- (void)onGetUsersHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userIds:(NSArray* _Nonnull)userIds {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(NSString* userId in userIds) {
            // 当前聊天女士才显示
            if( [userId isEqualToString:self.womanId] ) {
                NSLog(@"ChatViewController::onGetHistoryMessage( 获取多个用户历史聊天记录 )");
                [self reloadData:YES];
                [self scrollToEnd:YES];
                break;
            }
            
        }
    });
}

- (void)onCheckTryTicket:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId status:(CouponStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            // 当前聊天女士才显示
            if( [userId isEqualToString:self.womanId] ) {
                if( status == CouponStatus_Yes ) {
                    NSLog(@"ChatViewController::onCheckTryTicket( 检测是否可使用试聊券回调, 可用 userId : %@ )", userId);
                    
                    // 插入试聊券消息
                    Message* custom = [self insertCustomMessage];
                    custom.type = MessageTypeCoupon;
                
                    // 插入资费提示
                    custom = [self insertCustomMessage];
                    custom.type = MessageTypeSystemTips;
                    custom.text = NSLocalizedStringFromSelf(@"Tips_Try_Ticket_Credit_YES");
                    custom.attText = [self parseMessage:custom.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];

                } else {
                    NSLog(@"ChatViewController::onCheckTryTicket( 检测是否可使用试聊券回调, 不可用 userId : %@ )", userId);
                    
                    // 插入资费提示
                    Message* custom = [self insertCustomMessage];
                    custom.type = MessageTypeSystemTips;
                    custom.text = NSLocalizedStringFromSelf(@"Tips_Try_Ticket_Credit_NO");
                    custom.attText = [self parseMessage:custom.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];

                }

                // 刷新界面
                [self reloadData:YES];
                [self scrollToEnd:YES];

            }
        }

    });
}

- (void)onRecvTryTalkEnd:(LiveChatUserItemObject* _Nullable)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [user.userId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvTryTalkEnd( 结束试聊回调 userId : %@ )", user.userId);
//            // 插入结束试聊提示
//            Message* custom = [self insertCustomMessage];
//            custom.type = MessageTypeSystemTips;
//            custom.text = NSLocalizedStringFromSelf(@"Tips_Your_Free_Chat_Is_Ended");
//            custom.attText = [self parseMessage:custom.text font:[UIFont systemFontOfSize:SystemMessageFontSize] color:MessageGrayColor];
        }
    });
}

- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 当前聊天女士才显示
        if( [userId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onGetUserInfo( 获取用户信息回调 userId : %@, errType : %ld )", userId, (long)errType);
            if( errType == LCC_ERR_SUCCESS ) {
                self.imageViewLoader.url = userInfo.imgUrl;
                self.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewLoader.url];
                [self.imageViewLoader loadImage];
            }

            self.imageViewLoader.view.layer.cornerRadius = self.imageViewLoader.view.frame.size.width * 0.5;
            self.imageViewLoader.view.layer.masksToBounds = YES;
            
        }
    });
}

#pragma mark - 私密照回调
- (void)onGetPhoto:(LCC_ERR_TYPE)errType errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg msgList:(NSArray<LiveChatMsgItemObject*>* _Nonnull)msgList sizeType:(GETPHOTO_PHOTOSIZE_TYPE)sizeType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (errType == LCC_ERR_SUCCESS) {
            for(LiveChatMsgItemObject* msgItem in msgList) {
                if( [msgItem.fromId isEqualToString:self.womanId] ) {
                    NSLog(@"ChatViewController::onGetPhoto( 获取女士私密照回调 : %ld, fromId : %@, photoId : %@ )", (long)msgItem.msgId, msgItem.fromId, msgItem.secretPhoto.photoId);
                    [self reloadData:YES];
                    break;
                    
                } else if([msgItem.toId isEqualToString:self.womanId]) {
                    NSLog(@"ChatViewController::onGetPhoto( 获取男士私密照回调 : %ld, toId : %@, photoId : %@ )", (long)msgItem.msgId, msgItem.toId, msgItem.secretPhoto.photoId);
                    [self reloadData:YES];
                    break;
                }
            }
        }
    });
}

- (void)onPhotoFee:(bool)success errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [msgItem.fromId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onPhotoFee( 付费女士私密照回调 : %ld, fromId : %@, photoId : %@ )", (long)msgItem.msgId, msgItem.fromId, msgItem.secretPhoto.photoId);

            if (success) {
                [self reloadData:YES];
            }
            
        }
    });
}

- (void)onRecvPhoto:(LiveChatMsgItemObject *)msgItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [msgItem.fromId isEqualToString:self.womanId] ) {
            NSLog(@"ChatViewController::onRecvPhoto( 收到私密照回调 : %ld, fromId : %@, message : %@ )", (long)msgItem.msgId, msgItem.fromId, msgItem.secretPhoto.photoId);

            [self reloadData:YES];
            [self scrollToEnd:YES];

        }
    });
}

- (void)onSendPhoto:(LCC_ERR_TYPE)errType errNo:(NSString *)errNo errMsg:(NSString *)errMsg msgItem:(LiveChatMsgItemObject *)msgItem{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( msgItem != nil ) {
            if( [msgItem.toId isEqualToString:self.womanId] ) {
                if( msgItem.statusType == LCMessageItem::StatusType_Finish ) {
                    NSLog(@"ChatViewController::onSendPhoto( 发送私密照消息回调, 发送成功 : %ld, toId : %@, photoId : %@ )", (long)msgItem.msgId, msgItem.toId, msgItem.secretPhoto.photoId);
                    
                } else {
                    NSLog(@"ChatViewController::onSendPhoto( 发送私密照消息回调, 发送失败 : %ld, toId : %@, errMsg : %@ )", (long)msgItem.msgId, msgItem.toId, errMsg);
                }
                
                [self reloadData:YES];
                [self scrollToEnd:YES];
            }
        }
    });
}

#pragma mark - 私密照中操作或回调
- (void)ChatPhotoLadyTableViewCellDidLookPhoto:(ChatPhotoLadyTableViewCell *)cell {
    NSInteger index = cell.tag;
    Message *msg = [self.msgArray objectAtIndex:index];
    ChatSecretPhotoViewController *secretView = [[ChatSecretPhotoViewController alloc] initWithNibName:nil bundle:nil];
    secretView.msgItem = msg.liveChatMsgItemObject;
    [self closeAllInputView];
    [self presentViewController:secretView animated:NO completion:nil];
    
}

- (void)ChatPhotoSelfTableViewCellDidLookPhoto:(ChatPhotoSelfTableViewCell *)cell {
    NSInteger index = cell.tag;
    Message *msg = [self.msgArray objectAtIndex:index];
    ChatSecretPhotoViewController *secretView = [[ChatSecretPhotoViewController alloc] initWithNibName:nil bundle:nil];
    secretView.msgItem = msg.liveChatMsgItemObject;
    [self closeAllInputView];
    [self presentViewController:secretView animated:NO completion:nil];
}

- (void)ChatPhotoSelfTableViewCellDidClickRetryBtn:(ChatPhotoSelfTableViewCell *)cell {
    NSInteger index = cell.tag;
    [self handleErrorMsg:index];
}

@end
