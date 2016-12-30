//
//  LadyCollectionViewCell.h
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LadyCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *onlineImageView;
@property (weak, nonatomic) IBOutlet UIImageViewTopFit *ladyImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *collect;
+ (NSString *)cellIdentifier;
@end
