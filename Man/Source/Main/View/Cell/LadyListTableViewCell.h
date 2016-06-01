//
//  LadyListTableViewCell.h
//  DrPalm4EBaby
//
//  Created by KingsleyYau on 13-9-5.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LadyListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *ladyImageView;

@property (nonatomic, weak) IBOutlet UIImageView *onlineImageView;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;

@property (nonatomic, weak) IBOutlet UILabel *rightlLabel;
@property (nonatomic, weak) IBOutlet UIImageView *countryImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
