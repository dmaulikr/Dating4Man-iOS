//
//  ChatSecretPhotoViewController.h
//  dating
//
//  Created by test on 16/7/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "KKViewController.h"
#import "LiveChatMsgItemObject.h"



@interface ChatSecretPhotoViewController : KKViewController
@property (weak, nonatomic) IBOutlet UIImageView *secretImageView;

@property (weak, nonatomic) IBOutlet UILabel *fileName;

/**
 *  购买提示
 */
@property (weak, nonatomic) IBOutlet UILabel *creditTip;
/**
 *  购买按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
/**
 *  下载提示
 */
@property (weak, nonatomic) IBOutlet UILabel *downTip;
/**
 *  下载图片按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *downBtn;
/**
 *  保存到相册按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
/** 聊天 */
@property (nonatomic,strong) LiveChatMsgItemObject *msgItem;

/**
 *  点击购买
 *
 *  @param sender <#sender description#>
 */
- (IBAction)buySecretPhotoAction:(id)sender;

/**
 *  点击下载
 *
 *  @param sender <#sender description#>
 */
- (IBAction)downSecretPhotoAction:(id)sender;

/**
 *  点击保存到相册
 *
 *  @param sender <#sender description#>
 */
- (IBAction)saveSecretPhotoAction:(id)sender;

@end
