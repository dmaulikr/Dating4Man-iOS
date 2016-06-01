//
//  BadgeButton.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "BadgeButton.h"

#define BADGE_TAG 62
#define BADGE_LABEL_TAG 63

@implementation BadgeButton
- (void)setBadgeValue:(NSString *)newValue {
    UIView *badgeView = [self viewWithTag:BADGE_TAG];
    
    _badgeValue = newValue;
    
    if (self.badgeValue) {
        UIFont *labelFont = [UIFont boldSystemFontOfSize:13.0f];
        
        if (!badgeView) {
            UIImage *stretchableImage = [self.imageBadge stretchableImageWithLeftCapWidth:floor(self.imageBadge.size.width / 2) - 1 topCapHeight:0];
            
            badgeView = [[UIImageView alloc] initWithImage:stretchableImage];
            badgeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            badgeView.tag = BADGE_TAG;
            
            UILabel *badgeLabel = [[UILabel alloc] initWithFrame:badgeView.frame];
            badgeLabel.backgroundColor = [UIColor clearColor];
            badgeLabel.textColor = [UIColor whiteColor];
            badgeLabel.font = labelFont;
            badgeLabel.textAlignment = UITextAlignmentCenter;
            badgeLabel.tag = BADGE_LABEL_TAG;
            [badgeView addSubview:badgeLabel];
            
        }
        
        UILabel *badgeLabel = (UILabel *)[badgeView viewWithTag:BADGE_LABEL_TAG];
        CGSize size = [self.badgeValue sizeWithFont:labelFont];
        CGFloat padding = 7.0;
        CGRect frame = badgeView.frame;
        
        if (size.width + 2 * padding > frame.size.width) {
            // resize label for more digits
            frame.size.width = size.width;
            frame.origin.x += padding;
            badgeLabel.frame = frame;
            
            // resize bubble
            frame = badgeView.frame;
            frame.size.width = size.width + padding * 2;
            badgeView.frame = frame;
        }
        badgeLabel.text = self.badgeValue;
        
        // place badgeView on top right corner
        frame.origin = CGPointMake(self.frame.size.width - floor(badgeView.frame.size.width / 2) - 5,
                                   - floor(badgeView.frame.size.height / 2) + 5);
        badgeView.frame = frame;
        
        [self addSubview:badgeView];
    } else {
        [badgeView removeFromSuperview];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
