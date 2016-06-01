 //
//  ContactListViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ContactListViewController.h"
#import "ChatViewController.h"
#import "ContactListTableViewCell.h"

#import "GetRecentContactListRequest.h"
#import "GetLadyDetailRequest.h"
#import "SessionRequestManager.h"

#import "ContactManager.h"
#import "LiveChatManager.h"
#import "LiveChatUserItemObject.h"

@interface ContactListViewController ()<ContactManagerDelegate, ContactListTableViewDelegate, LiveChatManagerDelegate>
 /**
 *  联系人按钮
 */
@property (strong) UIButton *contactBtn;

/**
 *  邀请按钮
 */
@property (strong) UIButton *invitationBtn;

/**
 *  列表选择器
 */
@property (weak) IBOutlet UIView *buttonBarSection;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

/**
 *  数据列表
 */
@property (nonatomic,strong) NSArray *items;

/**
 *  LiveChat管理器
 */
@property (nonatomic,strong) LiveChatManager *liveChatManager;

/**
 *  联系人管理器
 */
@property (nonatomic,strong) ContactManager *contactManager;

/**
 *  获取女士详情
 *
 *  @param womanId 女士Id
 *
 *  @return <#return value description#>
 */
- (BOOL)getLadyDetail:(NSString *)womanId;
@end

@implementation ContactListViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navLeftButton  addTarget:self.mainVC action:@selector(pageLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.liveChatManager = [LiveChatManager manager];
    self.contactManager = [ContactManager manager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
       //取出导航控制器的子控件
        NSArray *NavigationList = self.navigationController.navigationBar.subviews;
        //遍历
        for (id NavigationListObj in NavigationList) {
            //取出图片
            if ([NavigationListObj isKindOfClass:[UIImageView class]]) {
                //获取图片
                UIImageView *imageView = (UIImageView *)NavigationListObj;
                //取出图片的子控件
                NSArray *imageViewLineList = imageView.subviews;
                //遍历
                for (id imageViewLineListObj in imageViewLineList) {
                    //获取边线图
                    if ([imageViewLineListObj isKindOfClass:[UIImageView class]]) {
                        UIImageView *bottomLine = (UIImageView *)imageViewLineListObj;
                        bottomLine.hidden = YES;
                    }
                }
            }
        }
    }

    [self.liveChatManager addDelegate:self];
    [self.contactManager addDelegate:self];
    
    [self.contactManager getRecentContact];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self.liveChatManager removeDelegate:self];
    [self.contactManager removeDelegate:self];
    
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
    self.sessionManager = [SessionRequestManager manager];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    UIBarButtonItem *barButtonItem = nil;
    UIImage *image = nil;
    UIButton* button = nil;
    
    // 标题
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-ChatList"];
    [button setImage:image forState:UIControlStateDisabled];
    [button setTitle:@"Chat" forState:UIControlStateNormal];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
    // 左边按钮
    NSMutableArray *array = [NSMutableArray array];
    
    image = [UIImage imageNamed:@"Navigation-Qpid"];
    self.navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navLeftButton setImage:image forState:UIControlStateNormal];
    [self.navLeftButton sizeToFit];
    [self.navLeftButton addTarget:self.mainVC action:@selector(pageLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navLeftButton ];
    
    [array addObject:barButtonItem];
    
    self.navigationItem.leftBarButtonItems = array;
    
    [self.mainVC setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupButtonBar];
    [self setupTableView];
}

- (void)setupButtonBar {
    self.buttonBarSection.backgroundColor = self.navigationController.navigationBar.barTintColor;
    self.kkButtonBar.layer.cornerRadius = 5.0f;
    self.kkButtonBar.layer.masksToBounds = YES;
    
    NSMutableArray* array = [NSMutableArray array];
    
    // 联系人按钮
    UIButton* buttonChatList = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonChatList.layer.cornerRadius = 5.0f;
    buttonChatList.layer.masksToBounds = YES;
    UIImage *backgroundImage = [self createImageWithColor:self.navigationController.navigationBar.barTintColor];
    [buttonChatList setBackgroundImage:backgroundImage forState:UIControlStateSelected];
    [buttonChatList setTitle:@"Chat List" forState:UIControlStateNormal];
    [buttonChatList setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [buttonChatList setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [buttonChatList addTarget:self action:@selector(getContactLadyList:) forControlEvents:UIControlEventTouchUpInside];
    buttonChatList.tag = 0;
    [array addObject:buttonChatList];
    
    // 邀请按钮
    UIButton* buttonInvitation = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonInvitation.layer.cornerRadius = 5.0f;
    buttonInvitation.layer.masksToBounds = YES;
    [buttonInvitation setTitleColor:self.navigationController.navigationBar.barTintColor forState:UIControlStateNormal];
    [buttonInvitation setBackgroundImage:backgroundImage forState:UIControlStateSelected];
    [buttonInvitation setTitle:@"Invitation" forState:UIControlStateNormal];
    [buttonInvitation setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [buttonInvitation setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [buttonInvitation addTarget:self action:@selector(getInvitationLadyList:) forControlEvents:UIControlEventTouchUpInside];
    buttonChatList.tag = 1;

    [array addObject:buttonInvitation];
    
    self.kkButtonBar.isVertical = NO;
    self.kkButtonBar.blanking = 0;
    self.kkButtonBar.items = array;
    [self.kkButtonBar reloadData:NO];
    
    self.contactBtn = buttonChatList;
    self.invitationBtn = buttonInvitation;
    
    // 默认选中第一项
    self.contactBtn.selected = YES;
    self.invitationBtn.selected = NO;
}

- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];    
}

- (UIImage *)createImageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    self.tableView.items = self.items;
    
    if( isReloadView ){
        [self.tableView reloadData];
    }
}

- (void)reloadInviteList {
    NSArray* array = [self.liveChatManager getInviteUsers];
    NSMutableArray* items = [NSMutableArray array];
    for(LiveChatUserItemObject* user in array) {
        LadyRecentContactObject* item = [[LadyRecentContactObject alloc] init];
        item.womanId = user.userId;
        item.firstname = user.userName;

        // 获取女士详情
//        [self getLadyDetail:item.womanId];
        [self.liveChatManager getUserInfo:item.womanId];
        
        // 获取最后一条消息
        LiveChatMsgItemObject* msg = [self.liveChatManager getLastMsg:item.womanId];
        if( msg != nil && msg.msgType == LCMessageItem::MessageType::MT_Text && msg.textMsg ) {
            item.lastInviteMessage = [self parseMessageTextEmotion:msg.textMsg.message font:[UIFont systemFontOfSize:15]];
        }
        
        [items addObject:item];
    }
    self.items = items;
    
    [self reloadData:YES];
}

- (void)getContactLadyList:(UIButton *)btn {
    // 点击联系人按钮
    self.contactBtn.selected = YES;
    self.invitationBtn.selected = NO;
    
    // 清空列表
    self.items = [NSArray array];
    [self reloadData:YES];
    
    [self.contactManager getRecentContact];
}

- (void)getInvitationLadyList:(UIButton *)btn {
    // 点击邀请按钮
    self.invitationBtn.selected = YES;
    self.contactBtn.selected = NO;
        
    [self reloadInviteList];
}

- (BOOL)getLadyDetail:(NSString *)womanId {
    // 获取女士详情
    self.sessionManager = [SessionRequestManager manager];
    GetLadyDetailRequest *request = [[GetLadyDetailRequest alloc] init];
    request.womanId = womanId;

    request.finishHandler = ^(BOOL success, LadyDetailItemObject *item, NSString * _Nullable errnum, NSString * _Nullable errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                for(LadyRecentContactObject* contact in self.items) {
                    if( [womanId isEqualToString:contact.womanId] ) {
                        contact.photoURL = item.photoURL;
                        break;
                    }
                }
                [self reloadData:YES];
            }
    
        });
    };
    
    return [self.sessionManager sendRequest:request];
}

- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange range;
    NSRange endRange;
    NSRange valueRange;
    NSRange replaceRange;
    
    NSString* emotionOriginalString = nil;
    NSString* emotionString = nil;
    NSAttributedString* emotionAttString = nil;
    ChatTextAttachment *attachment = nil;
    UIImage* image = nil;
    
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
        emotionOriginalString = [findString substringWithRange:valueRange];
        
        valueRange = NSMakeRange(NSMaxRange(range), endRange.location - NSMaxRange(range));
        emotionString = [findString substringWithRange:valueRange];
        
        // 创建表情
        image = [UIImage imageNamed:[NSString stringWithFormat:@"e%@", emotionString]];
        attachment.image = image;
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

#pragma mark - contactListTableView回调
- (void)tableView:(ContactListTableView *)tableView didSelectContact:(LadyRecentContactObject *)item {
    ChatViewController *vc = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.firstname = item.firstname;
    vc.womanId = item.womanId;
    vc.photoURL = item.photoURL;

    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 联系人管理器回调
- (void)manager:(ContactManager * _Nonnull)manager onGetRecentContact:(BOOL)success items:(NSArray * _Nonnull)items errnum:(NSString * _Nonnull)errnum errmsg:(NSString * _Nonnull)errmsg {
    NSLog(@"ContactListViewController::onGetRecentContact( 获取联系人列表回调 )");
    if( self.contactBtn.isSelected ) {
        self.items = items;
        [self reloadData:YES];
        
//        for(LadyRecentContactObject* user in items) {
//            // 获取女士详情
//            //        [self getLadyDetail:item.womanId];
//            [self.liveChatManager getUserInfo:user.womanId];
//        }
    }
}

- (void)onChangeRecentContactStatus:(ContactManager * _Nonnull)manager {
    NSLog(@"ContactListViewController::onChangeRecentContactStatus( 联系人状态改变 )");
    if( self.contactBtn.isSelected ) {
        [self.contactManager getRecentContact];
    }
}

#pragma mark - LivechatManager回调
- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ContactListViewController::onRecvTextMsg( 接收文本消息回调 fromId : %@ )", msg.fromId);
        if( self.invitationBtn.isSelected ) {
            [self reloadInviteList];
        }
    });
}

- (void)onGetUserInfo:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId userInfo:(LiveChatUserInfoItemObject* _Nullable)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ContactListViewController::onGetUserInfo( 获取用户信息回调 userId : %@ )", userInfo.userId);
        if( self.invitationBtn.isSelected ) {
            for(LadyRecentContactObject* contact in self.items) {
                if( [userInfo.userId isEqualToString:contact.womanId] ) {
                    contact.isOnline = (userInfo.status == USTATUS_ONLINE);
                    contact.photoURL = userInfo.imgUrl;
                    break;
                }
            }
            [self reloadData:YES];
            
        }
    });
}

@end
