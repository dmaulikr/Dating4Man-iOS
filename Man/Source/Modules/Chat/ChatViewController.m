//
//  ChatViewController.m
//  dating
//
//  Created by Max on 16/2/24.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "ChatViewController.h"

#import "ChatTextLadyTableViewCell.h"
#import "ChatTextSelfTableViewCell.h"
#import "ChatSystemTipsTableViewCell.h"
#import "ChatCouponTableViewCell.h"
#import "ChatWarningTipsTableViewCell.h"

#import "ChatEmotionChooseView.h"

#import "Contact.h"
#import "Message.h"
#import "LiveChatManager.h"

#define ADD_CREDIT_URL @"ADD_CREDIT_URL"

@interface ChatViewController () <UIAlertViewDelegate, ChatTextSelfDelegate, LiveChatManagerDelegate, KKCheckButtonDelegate, ChatEmotionChooseViewDelegate, TTTAttributedLabelDelegate> {
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
 *  解析消息表情和文本消息
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSAttributedString* )parseMessageTextEmotion:(NSString* )text font:(UIFont* )font;

/**
 *  解析普通消息
 *
 *  @param text 普通文本
 *  @param font        字体
 *  @return 普通富文本消息
 */
- (NSAttributedString* )parseMessage:(NSString* )text font:(UIFont* )font;

/**
 *  解析没钱警告消息
 *
 *  @param text 没钱警告消息
 *  @param linkMessage 可以点击的文字
 *  @param font        字体
 *  @return 没钱富文本警告消息
 */
- (NSAttributedString* )parseNoMomenyWarningMessage:(NSString* )text linkMessage:(NSString* )linkMessage font:(UIFont* )font;

/**
 *  根据表情文件名字生成表情协议名字
 *
 *  @param imageName 表情文件名字
 *
 *  @return 表情协议名字
 */
- (NSString* )parseEmotionTextByImageName:(NSString* )imageName;

/**
 *  发送文本
 *
 *  @param text 发送文本
 */
- (void)sendMsg:(NSString* )text;

/**
 *  重新加载消息到界面
 *
 *  @param isReloadView 是否刷新界面
 */
- (void)reloadData:(BOOL)isReloadView;

/**
 *  清空自定义消息
 */
- (void)clearCustomMessage;

/**
 *  显示买点view
 */
- (void)addCreditsViewShow;

/**
 *  隐藏买点view
 */
- (void)addCreditsViewDismiss;

@end

@implementation ChatViewController

#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.liveChatManager = [LiveChatManager manager];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 接收Livechat事件
    [self.liveChatManager addDelegate:self];
    
    if( !self.viewDidAppearEver ) {
        // 刷新消息列表
        [self reloadData:YES];
        
        if( self.msgArray.count > 0 ) {
            // 拉到最底
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        }
        
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
    
    // 去除Livechat事件
    [self.liveChatManager removeDelegate:self];
    
    // 清空自定义消息
    [self clearCustomMessage];
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
    self.customBackTitle = @"Home";
    self.womanId = @"";
    self.firstname = @"";
    self.photoURL = @"";

    // 初始化表情文件名字
    NSMutableArray *emotionArray = [NSMutableArray array];
    NSString* imageName = nil;
    for (int i = 0; i < 20; i++) {
        imageName = [NSString stringWithFormat:@"e%d", i];
        [emotionArray addObject:imageName];
    }
    self.emotionArray = emotionArray;
    
    // 初始化自定义消息列表
    self.msgCustomDict = [NSMutableDictionary dictionary];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    UIBarButtonItem *barButtonItem = nil;
    UIButton* button = nil;

    // 标题
    ChatTitleView *titleView = [[ChatTitleView alloc] init];
    titleView.personName.text = self.firstname;
    titleView.personName.textColor = [UIColor whiteColor];
    
    ImageViewLoader *imageLoader = [[ImageViewLoader alloc] init];
    imageLoader.view = titleView.personIcon;
    imageLoader.url = self.photoURL;
    imageLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageLoader.url];
    [imageLoader loadImage];
    imageLoader.view.layer.cornerRadius = imageLoader.view.sizeWidth * 0.5;
    imageLoader.view.layer.masksToBounds = YES;
    
    self.navigationItem.titleView = titleView;
    
    // 左边按钮
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Home" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"Navigation-Back"] forState:UIControlStateNormal];
    [button sizeToFit];
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.backBarButtonItem = barButtonItem;
    
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
    [self setupInputView];
    [self setupCreditsView];
    [self setupMotionInputView];
    // 记录原始大小
//    _orgFrame = self.view.frame;
    
}

- (void)setupTableView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];

}

- (void)setupInputView {
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.emotionBtn.adjustsImageWhenHighlighted = NO;
    self.emotionBtn.selectedChangeDelegate = self;
    
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionGray"] forState:UIControlStateNormal];
    [self.emotionBtn setImage:[UIImage imageNamed:@"Chat-EmotionBlue" ] forState:UIControlStateSelected];
}

- (void)setupCreditsView {
    self.addCreditsView.hidden = YES;
    
    self.add8CreditButton.layer.borderColor = [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0].CGColor;
    self.add8CreditButton.layer.borderWidth = 1;

    self.add16CreditButton.layer.borderColor = [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0].CGColor;
    self.add16CreditButton.layer.borderWidth = 1;
}

- (void)setupMotionInputView {
    if( self.emotionInputView == nil ) {
        self.emotionInputView = [ChatEmotionChooseView emotionChooseView];
        self.emotionInputView.delegate = self;
        
        // 初始化表情图片
        NSMutableArray *emotionArray = [NSMutableArray array];
        UIImage* image = nil;
        for(NSString* imageName in self.emotionArray) {
            image = [UIImage imageNamed:imageName];
            [emotionArray addObject:image];
        }
        self.emotionInputView.emotions = emotionArray;
        
        // 增加点击事件
        [self.emotionInputView.sendButton addTarget:self action:@selector(sendMsgAction:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)addCreditsViewShow {
    // 显示买点view
    self.addCreditsView.hidden = NO;
    self.addCreditsViewHeight.constant = 130;
}

- (void)addCreditsViewDismiss {
    self.addCreditsView.hidden = YES;
    self.addCreditsViewHeight.constant = 0;
}

#pragma mark - 点击事件
- (IBAction)sendMsgAction:(id)sender {
    [self addCreditsViewDismiss];
    [self sendMsg:self.textView.text];
}

- (IBAction)buy8CreditAction:(id)sender {
    [self addCreditsViewDismiss];
}

- (IBAction)buy16CreditAction:(id)sender {
    [self addCreditsViewDismiss];
}

#pragma mark - 点击重发按钮
- (void)chatTextSelfRetryButtonClick:(ChatTextSelfTableViewCell *)cell {
    NSInteger index = cell.tag;
    Message* msg = [self.msgArray objectAtIndex:index];
    
    // 删除旧信息
    [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
    
    // 重新发送
    [self sendMsg:msg.text];
}

#pragma mark - 表情按钮选择回调
- (void)selectedChanged:(id)sender {
    [self.textView endEditing:YES];
    
    UIButton *emotionBtn = (UIButton *)sender;
    if( emotionBtn.selected == YES ) {
        // 转换成emotion的键盘
        self.textView.inputView = self.emotionInputView;
        [self.emotionInputView reloadData];
        [self.textView becomeFirstResponder];
        
    } else {
        // 切换成系统的的键盘
        self.textView.inputView = nil;
        [self.textView becomeFirstResponder];
    }
}

#pragma mark - 表情选择回调
- (void)chatEmotionChooseView:(ChatEmotionChooseView *)chatEmotionChooseView didSelectItem:(NSInteger)item {
    // 插入表情到输入框
    NSString* imageName = [self.emotionArray objectAtIndex:item];
    UIImage* image = [UIImage imageNamed:imageName];
    NSString* emotionName = [self parseEmotionTextByImageName:imageName];
    ChatEmotion* emotion = [[ChatEmotion alloc] initWithTextImage:emotionName image:image];
    [self.textView insertEmotion:emotion];

}

#pragma mark - 数据逻辑
- (void)sendMsg:(NSString* )text {
    NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@ )", text);
    
    LiveChatMsgItemObject* msg = [self.liveChatManager sendTextMsg:self.womanId text:text];
    if( msg != nil ) {
        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, msgId : %ld )", text, (long)msg.msgId);
    } else {
        NSLog(@"ChatViewController::sendMsg( 发送文本消息 : %@, 失败 )", text);
    }
    
    // 刷新界面
    [self.textView setText:@""];
    [self.textView resignFirstResponder];
    [self reloadData:YES];
    
    if( self.msgArray.count > 0 ) {
        // 拉到最底
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    NSMutableArray* dataArray = [NSMutableArray array];
    NSArray* array = [self.liveChatManager getMsgsWithUser:self.womanId];
    for(LiveChatMsgItemObject* msg in array) {
        Message* item = [[Message alloc] init];
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
                    item.text = msg.textMsg.message;
                    item.attText = [self parseMessageTextEmotion:item.text font:[UIFont systemFontOfSize:15]];
                    
                }break;
                case LCMessageItem::MessageType::MT_System:{
                    item.type = MessageTypeSystemTips;
                    item.text = msg.systemMsg.message;
                    item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:12]];
                    
                }break;
                case LCMessageItem::MessageType::MT_Warning:{
                    item.type = MessageTypeWarningTips;
                    switch (msg.warningMsg.codeType) {
                        case LCWarningItem::CodeType::NOMONEY:{
                            item.text = msg.warningMsg.message;
                            item.attText = [self parseNoMomenyWarningMessage:@"You have run out of credits. " linkMessage:@"Add credit to continue." font:[UIFont systemFontOfSize:12]];
                        
                        }break;
                        default:{
                            item.text = msg.warningMsg.message;
                            item.attText = [self parseMessage:item.text font:[UIFont systemFontOfSize:12]];
                            
                        }break;
                            
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

- (void)clearCustomMessage {
    for(NSString *key in self.msgCustomDict) {
        Message* msg = [self.msgCustomDict valueForKey:key];
        [self.liveChatManager removeHistoryMessage:self.womanId msgId:msg.msgId];
    }

}

- (NSString* )parseEmotionTextByImageName:(NSString* )imageName {
    NSMutableString* resultString = [NSMutableString stringWithString:imageName];
    
    NSRange range = [resultString rangeOfString:@"e"];
    if( range.location != NSNotFound ) {
        [resultString replaceCharactersInRange:range withString:@"[img:"];
        [resultString appendString:@"]"];
    }
    
    return resultString;
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

- (NSAttributedString* )parseMessage:(NSString* )text font:(UIFont* )font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

- (NSAttributedString* )parseNoMomenyWarningMessage:(NSString* )text linkMessage:(NSString* )linkMessage font:(UIFont* )font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    ChatTextAttachment *attachment = [[ChatTextAttachment alloc] init];
    attachment.text = linkMessage;
    attachment.url = [NSURL URLWithString:ADD_CREDIT_URL];
    NSMutableAttributedString *attributeLinkString = [[NSMutableAttributedString alloc] initWithString:linkMessage];
    [attributeLinkString addAttributes:@{
                                         NSAttachmentAttributeName : attachment,
//                                         NSUnderlineColorAttributeName : [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0],
//                                         NSForegroundColorAttributeName : [UIColor colorWithRed:19/255.0 green:174/255.0 blue:233/255.0 alpha:1.0]
                                         } range:NSMakeRange(0, linkMessage.length)];
    
    [attributeString appendAttributedString:attributeLinkString];
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
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
            CGSize viewSize = CGSizeMake(self.tableView.frame.size.width, [ChatWarningTipsTableViewCell cellHeight:self.tableView.frame.size.width detailString:item.attText]);
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
//                    cell.detailLabel.linkAttributes = attrs;
                    [cell.detailLabel addLinkToURL:attachment.url withRange:range];
                }
            }];
             
        }break;
        case MessageTypeWarningTips:{
            // 警告消息
            ChatSystemTipsTableViewCell* cell = [ChatWarningTipsTableViewCell getUITableViewCell:tableView];
            result = cell;
            
            cell.detailLabel.attributedText = item.attText;
            
        }break;
        case MessageTypeText:{
            // 文本
            switch (item.sender) {
                case MessageSenderLady: {
                    // 接收到的消息
                    ChatTextLadyTableViewCell* cell = [ChatTextLadyTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    cell.detailLabel.attributedText = item.attText;
                    
                }break;
                case MessageSenderSelf:{
                    // 发出去的消息
                    ChatTextSelfTableViewCell* cell = [ChatTextSelfTableViewCell getUITableViewCell:tableView];
                    result = cell;
                    
                    cell.delegate = self;
                    cell.detailLabel.attributedText = item.attText;
                    
                    switch (item.status) {
                        case MessageStatusProcessing: {
                            // 发送中
                            cell.activityIndicatorView.hidden = NO;
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

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    __block BOOL bFlag = NO;
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            //修改尺寸会出现了cell往上偏移,以及右边距离会改变等问题
            //            self.view.frame = CGRectMake(_orgFrame.origin.x, _orgFrame.origin.y, _orgFrame.size.width, _orgFrame.size.height - height);
            self.bottom.constant = -height;
            bFlag = YES;
            
        } else {
            self.bottom.constant = 0;
            //            self.view.frame = _orgFrame;
            
        }
    } completion:^(BOOL finished) {
        if( bFlag ) {
            if( self.msgArray.count > 0 && [self.tableView.indexPathsForVisibleRows lastObject].row != self.msgArray.count - 1 ) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
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
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        // 判断输入的字是否是回车，即按下send
        [self sendMsgAction:nil];
        
        return NO;
    }
   
    return YES;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {
    CGFloat reSizeWidth = reSize.width;
    CGFloat reSizeheight = image.size.height * reSize.width / image.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(reSizeWidth, reSizeheight));
    [image drawInRect:CGRectMake(0, 0, reSizeWidth, reSizeheight)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

#pragma mark - 点击链接回调
- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:ADD_CREDIT_URL] ) {
        [self addCreditsViewShow];
    }
}

#pragma mark - LivechatManager回调
- (void)onSendTextMsg:(LCC_ERR_TYPE)errType errMsg:(NSString* _Nonnull)errMsg msgItem:(LiveChatMsgItemObject* _Nullable)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调 )");
        if( msg != nil ) {
            if( msg.statusType == LCMessageItem::StatusType_Finish ) {
                NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调, 发送成功 : %@, toId : %@ )", msg.textMsg.message, msg.toId);
            } else {
                NSLog(@"ChatViewController::onSendTextMsg( 发送文本消息回调, 发送失败 : %@, toId : %@, errMsg : %@ )", msg.textMsg.message, msg.toId, errMsg);
            }
            
            [self reloadData:YES];
        }
        
        if( errType == LCC_ERR_NOMONEY ) {
            // 无钱显示买点
            [self addCreditsViewShow];
        }
    });

}

- (void)onSendTextMsgsFail:(LCC_ERR_TYPE)errType msgs:(NSArray* _Nonnull)msgs {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onSendTextMsgsFail( 发送消息失败回调（多条）)");
        for(LiveChatMsgItemObject* msg in msgs) {
            NSLog(@"ChatViewController::onSendTextMsgsFail( 发送消息失败回调（多条）: %@ )", msg);
        }
        [self reloadData:YES];
    });
}

- (void)onRecvTextMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onRecvTextMsg( 接收文本消息回调 fromId : %@ )", msg.fromId);
        if( msg.textMsg != nil ) {
            NSLog(@"ChatViewController::onRecvTextMsg( 接收文本消息回调 fromId : %@, message : %@ )", msg.fromId, msg.textMsg.message);
        }
        
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            [self reloadData:YES];
            
            // 拉到最底
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.msgArray.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

- (void)onRecvSystemMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onRecvSystemMsg( 接收系统消息回调 )");
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            [self reloadData:YES];
        }
    });
}

- (void)onRecvWarningMsg:(LiveChatMsgItemObject* _Nonnull)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onRecvWarningMsg( 接收警告消息 )");
        // 当前聊天女士才显示
        if( [msg.fromId isEqualToString:self.womanId] ) {
            [self reloadData:YES];
        }
    });
}

- (void)onRecvEditMsg:(NSString* _Nonnull)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onRecvEditMsg( 对方编辑消息回调 )");
        // 当前聊天女士才显示
        if( [userId isEqualToString:self.womanId] ) {
            [self reloadData:YES];
        }
    });
}

- (void)onGetHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onGetHistoryMessage( 获取单个用户历史聊天记录 )");
        // 当前聊天女士才显示
        if( [userId isEqualToString:self.womanId] ) {
            [self reloadData:YES];
        }
    });
}

- (void)onGetUsersHistoryMessage:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userIds:(NSArray* _Nonnull)userIds {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onGetHistoryMessage( 获取多个用户历史聊天记录 )");
        for(NSString* userId in userIds) {
            // 当前聊天女士才显示
            if( [userId isEqualToString:self.womanId] ) {
                [self reloadData:YES];
                break;
            }
            
        }
    });
}

- (void)onCheckTryTicket:(BOOL)success errNo:(NSString* _Nonnull)errNo errMsg:(NSString* _Nonnull)errMsg userId:(NSString* _Nonnull)userId status:(CouponStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"ChatViewController::onCheckTryTicket( 检测是否可使用试聊券回调 )");
        if( success ) {
            // 当前聊天女士才显示
            if( [userId isEqualToString:self.womanId] ) {
                if( status == CouponStatus_Yes ) {
                    NSLog(@"ChatViewController::onCheckTryTicket( 检测是否可使用试聊券回调, 可用 )");
                    
                    // 插入试聊券消息
                    Message* custom = [self insertCustomMessage];
                    custom.type = MessageTypeCoupon;
                
                    // 记录资费提示
                    custom = [self insertCustomMessage];
                    custom.type = MessageTypeSystemTips;
                    custom.text = @"send your first message to start free chat now.";
                    custom.attText = [self parseMessage:custom.text font:[UIFont systemFontOfSize:12]];

                } else {
                    NSLog(@"ChatViewController::onCheckTryTicket( 检测是否可使用试聊券回调, 不可用 )");
                    
                    // 插入资费提示
                    Message* custom = [self insertCustomMessage];
                    custom.type = MessageTypeSystemTips;
                    custom.text = @"send your first message to start free chat now.";
                    custom.attText = [self parseMessage:custom.text font:[UIFont systemFontOfSize:12]];

                }

                // 刷新界面
                [self reloadData:YES];
            }
        }

    });
}

@end
