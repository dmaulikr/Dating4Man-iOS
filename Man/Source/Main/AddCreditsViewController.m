//
//  addCreditsViewController.m
//  dating
//
//  Created by lance on 16/3/8.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  setting添加credits

#import "AddCreditsViewController.h"
//#import "UIBarButtonItem+setItemType.h"
#import "CommonDetailAndAccessoryTableViewCell.h"
#import "CommonTitleTableViewCell.h"
#import "CoverView.h"
#import "CreditsTipView.h"
#import "CommonData.h"

@interface AddCreditsViewController ()<creditsViewPopCreditsDelegate>

@property (nonatomic,strong) NSArray *tableViewDataArray;


@end

@implementation AddCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置导航栏
- (void)setupNavigationBar{
    [super setupNavigationBar];
    UILabel *credits = [[UILabel alloc] init];
    credits.textColor = [UIColor whiteColor];
    credits.text = @"Credits";
    [credits sizeToFit];
    self.navigationItem.titleView = credits;
    
    [self.mainVC setupNavigationBar];
}

//设置内容
- (void)setupContainView {
    [super setupContainView];
    
    [self setupTableView];
}


//设置底部
- (void)setupTableView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    

    
}



#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{

    // credits数据列表
    NSMutableArray *array = [NSMutableArray array];
    CommonData *item = [[CommonData alloc] init];
    item.creditLevel = @"Credits Balance";
    item.creditPrice = @"2.50";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"";
    item.creditPrice = @"";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"3 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"8 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"16 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"30 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"60 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    item = [[CommonData alloc] init];
    item.creditLevel = @"100 credits";
    item.creditPrice = @"$21.00";
    [array addObject:item];
    
    self.items = array;
    
    if( isReloadView ) {
        [self.tableView reloadData];
    }
}




#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    NSInteger count = 0;
    
    if ([tableView isEqual:self.tableView]) {
        count = 1;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount = 0;
    
    if ([tableView isEqual:self.tableView]) {
        dataCount = self.items.count ;
    }
    
    return dataCount;
    
  
}



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
 
    UITableViewCell *result = nil;
    CommonDetailAndAccessoryTableViewCell *commomCell = [CommonDetailAndAccessoryTableViewCell getUITableViewCell:tableView];
    result = commomCell;
    
    // 数据填充
    if (indexPath.row == 0) {
        commomCell.detailLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
        commomCell.detailLabel.font = [UIFont systemFontOfSize:17];
        commomCell.accessoryLabel.textColor = [UIColor colorWithIntRGB:94 green:94 blue:94 alpha:255];
        commomCell.accessoryLabel.font = [UIFont systemFontOfSize:16];
    }
    
    if (indexPath.row == 1) {
        CommonTitleTableViewCell *cell = [CommonTitleTableViewCell getUITableViewCell:tableView];
        result = cell;
        cell.titleLabel.text = @"ADD MORE CREDITS";
        cell.titleLabel.font = [UIFont systemFontOfSize:12];
        cell.titleLabel.textColor = [UIColor colorWithIntRGB:51 green:51 blue:51 alpha:255];
        cell.leftImageView.image = [UIImage imageNamed:@"AddCredits-ShopBus"];
        cell.separatorInset = UIEdgeInsetsZero;
        [cell layoutIfNeeded];
    }
    
 
    
    CommonData *item = [self.items objectAtIndex:indexPath.row];
    commomCell.accessoryLabel.text = item.creditPrice;
    commomCell.detailLabel.text = item.creditLevel;

    return result;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


#pragma mark - 监听返回按钮
//实现返回按钮的功能
- (void)backToSettings{
    
    [self.navigationController popViewControllerAnimated:YES];
}
//弹出提示框
- (IBAction)creditTipsNotice:(id)sender {
    //弹出蒙版
    [CoverView coverShow];
    //创建提示框并指定显示位置
    CreditsTipView *creditsTipView = [CreditsTipView showInPoint:self.view.center];
    //设置边角
    creditsTipView.layer.cornerRadius = 5.0f;
    creditsTipView.layer.masksToBounds = YES;
    creditsTipView.delegate = self;
}


//点击确定隐藏提示框并取消蒙版效果
- (void)popCreditsClickToHide:(CreditsTipView *)creditsTipView{
    [creditsTipView hideInPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) completion:^{
        
        [CoverView coverHide];
    }];
    
}
@end
