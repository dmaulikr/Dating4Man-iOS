//
//  LadyWaterfallView.h
//  dating
//
//  Created by Calvin on 16/12/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QueryLadyListItemObject.h"

@class LadyWaterfallView;
@protocol LadyWaterfallViewDelegate <NSObject>

- (void)didChatButtonFromWaterfallViewIndex:(NSInteger)index;
- (void)waterfallView:(UICollectionView *)waterfallView didSelectLady:(QueryLadyListItemObject *)item;
- (void)showSearthView;
@end

@interface LadyWaterfallView : UICollectionView <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate>

@property (nonatomic, weak) id <LadyWaterfallViewDelegate> waterfallViewDelegate;
@property (nonatomic, retain) NSArray *items;
@end
