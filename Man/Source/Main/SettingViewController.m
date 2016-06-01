//
//  SettingViewController.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "SettingViewController.h"
#import "CommonTitleDetailTableViewCell.h"
#import "LoginManager.h"
#import "AddCreditsViewController.h"
#import "PersonalProfileTableViewController.h"
#import "LoginViewController.h"
#import "AppSettingViewController.h"



typedef enum {
    RowTypeSetting,
    RowTypeAppSetting,
    RowTypeAddCredits,
} RowType;

@interface SettingViewController ()

@property (nonatomic, strong) ImageViewLoader* imageViewLoader;
@property (nonatomic, strong) NSArray *tableViewArray;

- (void)setupHeadPhoto;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navRightButton addTarget:self.mainVC action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    self.CreditsBalanceCount.layer.cornerRadius = 5.0f;
    self.CreditsBalanceCount.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 界面逻辑
- (void)setupNavigationBar {
    [super setupNavigationBar];
    UIBarButtonItem *barButtonItem = nil;
    UIImage *image = nil;
    UIButton* button = nil;
    
    // 标题
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    image = [UIImage imageNamed:@"Navigation-Setting"];
    [button setImage:image forState:UIControlStateDisabled];
    [button setTitle:@"Settings" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button sizeToFit];
    [button setEnabled:NO];
    self.navigationItem.titleView = button;
    
    // 右边按钮
    NSMutableArray *array = [NSMutableArray array];
    
    image = [UIImage imageNamed:@"Navigation-Qpid"];
    self.navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navRightButton setImage:image forState:UIControlStateNormal];
    [self.navRightButton sizeToFit];
    [self.navRightButton addTarget:self.mainVC action:@selector(pageRightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navRightButton];
    [array addObject:barButtonItem];
    
    self.navigationItem.rightBarButtonItems = array;
    
    [self.mainVC setupNavigationBar];
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupHeadPhoto];
    [self setupTableView];
}

- (void)setupHeadPhoto {
    self.imageViewHead.layer.cornerRadius = self.imageViewHead.frame.size.height / 2;
    self.imageViewHead.layer.masksToBounds = YES;
    
    self.imageViewHead.layer.borderWidth = 5.0;
    self.imageViewHead.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.imageViewLoader = [[ImageViewLoader alloc] init];
    self.imageViewLoader.view = self.imageViewHead;
    [self.imageViewLoader loadImage];
    
}

- (void)setupTableView {
    self.tableView.separatorColor = [UIColor grayColor];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    
    // 个人资料
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonTitleDetailTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeSetting] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 设置
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonTitleDetailTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeAppSetting] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 充值
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(_tableView.frame.size.width, [CommonTitleDetailTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeAddCredits] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    if(isReloadView) {
        [self.tableView reloadData];
        
        LoginItemObject* item = [LoginManager manager].loginItem;
        if( item ) {
            // 头像
            self.imageViewLoader.url = item.photoURL;
            self.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewLoader.url];
            [self.imageViewLoader loadImage];
            
            // 名字
            self.titleLabel.text = item.firstname;
        }
        
    }
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        count = 1;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        number = self.tableViewArray.count;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        height = viewSize.height;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RowTypeSetting:{
                // 个人资料
                CommonTitleDetailTableViewCell *cell = [CommonTitleDetailTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-MyProfile"]];
                cell.titleLabel.text = @"My Profile";
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
                cell.detailLabel.text = @"Edit / view profile";
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                
            }break;
            case RowTypeAppSetting:{
                // 设置
                CommonTitleDetailTableViewCell *cell = [CommonTitleDetailTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-AppSettings"]];
                cell.titleLabel.text = @"App Settings";
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:255 green:102 blue:0 alpha:255];
                cell.detailLabel.text = @"Notification account and other";
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                
            }break;
            case RowTypeAddCredits:{
                // 充值
                CommonTitleDetailTableViewCell *cell = [CommonTitleDetailTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                [cell.leftImageView setImage:[UIImage imageNamed:@"Setting-AddCredits"]];
                cell.titleLabel.textColor = [UIColor colorWithIntRGB:0 green:102 blue:255 alpha:255];
                cell.titleLabel.text = @"Add Credits";
                cell.detailLabel.text = @"Credits are used to connect people";
                cell.detailLabel.font = [UIFont systemFontOfSize:14];
                cell.detailLabel.textColor = [UIColor colorWithIntRGB:121 green:121 blue:121 alpha:255];
                [cell setSeparatorInset:UIEdgeInsetsZero];
                
            }break;
            default:break;
        }
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        KKNavigationController *nvc = (KKNavigationController *)self.navigationController;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RowTypeSetting:{
                // 个人资料
                PersonalProfileTableViewController *profile = [[PersonalProfileTableViewController alloc] init];
                
               
                
                [nvc pushViewController:profile animated:YES];
                
            }break;
            case RowTypeAppSetting:{
                // 设置
                AppSettingViewController *appSetting = [[AppSettingViewController alloc] init];
                 appSetting.customBackTitle = @"Setting";
                [nvc pushViewController:appSetting animated:YES];
            }break;
            case RowTypeAddCredits:{
                // 充值
                // 1。创建充值的控制器
                AddCreditsViewController *credits = [[AddCreditsViewController alloc] init];
                credits.customBackTitle = @"Setting";
                // 2。点击跳转
                [nvc pushViewController:credits animated:YES];
                
            }
                
                break;
            default:break;
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
