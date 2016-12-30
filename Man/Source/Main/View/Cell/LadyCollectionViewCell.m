//
//  LadyCollectionViewCell.m
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LadyCollectionViewCell.h"
#define HEXCOLOR(rgbValue)			[UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgbValue & 0xFF)) / 255.0 alpha : 1.0]

@implementation LadyCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.ladyImageView.layer.cornerRadius = 5;
    self.ladyImageView.layer.masksToBounds = YES;
    self.onlineImageView.layer.cornerRadius = 4.0f;
    self.onlineImageView.layer.masksToBounds = YES;
    self.onlineImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.onlineImageView.layer.borderWidth = 2;
    
    NSArray * colorArray = @[HEXCOLOR(0x7ACA83),HEXCOLOR(0x60BFEB),HEXCOLOR(0xD774A0),HEXCOLOR(0xF47852),HEXCOLOR(0xF67D70),HEXCOLOR(0xF99B5D)];
    int x = arc4random() % 6;
    
    self.ladyImageView.backgroundColor = colorArray[x];
}

+ (NSString *)cellIdentifier {
    return @"LadyWaterfallCell";
}


@end
