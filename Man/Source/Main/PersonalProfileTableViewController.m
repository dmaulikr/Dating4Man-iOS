//
//  PersonalProfileTableViewController.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  个人资料页

#import "PersonalProfileTableViewController.h"
//#import "UIBarButtonItem+setItemType.h"
#import "MyProfileTopTableViewCell.h"
#import "CommonLeftTitleTableViewCell.h"
#import "CommonContentTableViewCell.h"
#import "UIBarButtonItem+setItemType.h"
#import "SessionRequestManager.h"
#import "UploadHeaderPhoto.h"
#import "GetPersonProfileRequest.h"
#import "StartEditResumeRequest.h"
#import "UpdateProfileRequest.h"

typedef enum {
    RowTypePhoto,
    RowTypeMessage,
    RowTypeDescription,
} RowType;


@interface PersonalProfileTableViewController ()<CommonContentCellDelegate,MyProfileTopCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextViewDelegate,NSXMLParserDelegate>

@property (nonatomic, strong) NSArray *tableViewArray;

/** actionSheet */
@property (nonatomic,strong) UIActionSheet *actionSheet;

/** 个人资料头像图片 */
@property (nonatomic,weak) UIImageView *topImageView;

/** 任务管理 */
@property (nonatomic,strong) SessionRequestManager *sessionManager;

/** 个人详情模型 */
@property (nonatomic,strong) PersonalProfile *personalItem;

/** 国家列表 */
@property (nonatomic,strong) NSMutableArray *countryList;
/** 国家名字 */
@property (nonatomic,strong) NSString *countryName;
/** 标签 */
@property (nonatomic,strong) NSString *elementTag;

/** 保存图片路径 */
@property (nonatomic,strong) ImageViewLoader *imageLoader;
@end

@implementation PersonalProfileTableViewController


- (NSMutableArray *)countryList{
    if (!_countryList) {
        _countryList = [NSMutableArray array];
    }
    return _countryList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupTableView];
    
    
   
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
   
     [self setupXMLParser];
        [self getPersonalProfile];
        [self reloadData:YES];
    
}



- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



#pragma mark - 界面逻辑
- (void)setupNavigationBar{
    UILabel *Profile = [[UILabel alloc] init];
    Profile.textColor = [UIColor whiteColor];
    Profile.text = @"My Profile";
    Profile.font = [UIFont boldSystemFontOfSize:15];
    [Profile sizeToFit];
    self.navigationItem.titleView = Profile;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem barButtonItemWithNormalImage:@"Navigation-Back" HighlightImage:@"Navigation-Back" normaltitle:@"Setting" Highlighted:@"Setting" target:self action:@selector(backToSettings)];
}

- (void)setupTableView {
    self.tableView.separatorColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:0.6f];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [self.tableView setTableFooterView:footerView];
    
  
    
}


//设置xml解析
- (void)setupXMLParser{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country_without_code" ofType:@"xml"];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];
    [xmlRead setDelegate:self];
    [xmlRead parse];
    [file closeFile];
}



#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{

    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGSize viewSize;
    NSValue *rowSize;
    
    // 头部
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [MyProfileTopTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypePhoto] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 个人信息与地址
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonLeftTitleTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeMessage] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 个人信息描述
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonContentTableViewCell cellHeight:self.tableView.frame.size.width detailString:self.personalItem.resume]);

    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeDescription] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    if(isReloadView) {
        [self.tableView reloadData];
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
            case RowTypePhoto:{
                // 头部
                MyProfileTopTableViewCell *cell = [MyProfileTopTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.delegate = self;
                ImageViewLoader *imageloader = [[ImageViewLoader alloc] init];
                imageloader.view = (UIImageView *)cell.profilePicture;
                imageloader.url = self.personalItem.photoUrl;
                imageloader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageloader.url];
                [imageloader loadImage];
                self.imageLoader = imageloader;
                cell.profilePicture.contentMode = UIViewContentModeScaleToFill;

            }break;
            case RowTypeMessage:{
                // 个人信息资料
                CommonLeftTitleTableViewCell *cell = [CommonLeftTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
 
                cell.profileMessage.text = @"firstname,18";
                
                cell.profileMessage.text = [NSString stringWithFormat:@"%@,%d",self.personalItem.firstname,self.personalItem.age];
                if (self.personalItem.firstname.length == 0 || self.personalItem.age == 0) {
                    cell.profileMessage.text = @"firstname,18";
                }
                

                [cell.profileLocation setTitle:self.countryList[self.personalItem.country] forState:UIControlStateNormal];
                cell.profileLocation.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
            }break;
            case RowTypeDescription:{
                // 自我描述
                CommonContentTableViewCell  *cell = [CommonContentTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.delegate = self;
                cell.detailText.delegate = self;
                cell.detailText.text = self.personalItem.resume;
                cell.descriptionLabel.text = @"YOUR SELF-DESCRIPTION";
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                
             
            }break;
            default:
                break;
        }
    }
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


#pragma mark - 点击cell中按钮的操作
- (void)commonContentCellBtnDidClick:(CommonContentTableViewCell *)cell{
    
    [self startEditResume];
    
    [cell.detailText becomeFirstResponder];
}

- (void)myProfileTopCellPhotoBtnDidClick:(MyProfileTopTableViewCell *)cell{

    
    [self callSheet];
 
    
    
}

#pragma mark - XML
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName

  namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *)qName

    attributes: (NSDictionary *)attributeDict{
    
    self.elementTag = elementName;
    
    if ([elementName isEqualToString:@"resources"]){
        
        
        
    }else if ([elementName isEqualToString:@"country_without_code"]){
        
        self.countryList = [[NSMutableArray alloc] init];
        
    }
    
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (self.countryName == nil) {
        self.countryName = @"";
    }
    
    if ([self.elementTag isEqualToString:@"item"]) {
        
        self.countryName = string;
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"item"]) {
        [self.countryList addObject:self.countryName];
    }
    
    
    
}


- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    
}




#pragma mark - 相册逻辑
- (void)callSheet{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil,nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil,nil];
    
    }
    self.actionSheet.tag = 1000;
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                    break;
                case 1:
                    //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }else{
            if (buttonIndex == 0){
                return;
            }else{
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            
        }
        //点击打开相册
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        
        [self presentViewController:imagePicker animated:YES completion:nil];

    }

    
}

#pragma mark - 相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        MyProfileTopTableViewCell *cell =  [self.tableView visibleCells].firstObject;
        cell.profilePicture.image = info[UIImagePickerControllerOriginalImage];

        FileCacheManager *manager = [FileCacheManager manager];
        NSString *headPhotoPath = [manager imageUploadCachePath:cell.profilePicture.image uploadImageName:@"headPhoto.png"];
        [self upLoadHeaderPhotoWithPath:headPhotoPath];


    }];
    
  
}



#pragma mark - 接口

- (BOOL)upLoadHeaderPhotoWithPath:(NSString *)path{
    self.sessionManager = [SessionRequestManager manager];
    UploadHeaderPhoto *request = [[UploadHeaderPhoto alloc] init];
    request.fileName = path;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        if (success) {
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:self.imageLoader.path error:nil];
        }

    };
    return [self.sessionManager sendRequest:request];
    
}

- (BOOL)getPersonalProfile{
    self.sessionManager = [SessionRequestManager manager];
    GetPersonProfileRequest *request = [[GetPersonProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success,PersonalProfile *item,NSString *error,NSString *errmsg){
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.personalItem = item;
                [self reloadData:YES];
            });
            
        }

    };
    return [self.sessionManager sendRequest:request];
}


- (BOOL)startEditResume{
    self.sessionManager = [SessionRequestManager manager];
    StartEditResumeRequest *request = [[StartEditResumeRequest alloc] init];
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        
    };
    
    return [self.sessionManager sendRequest:request];
}





- (BOOL)updateProfile:(NSString * _Nullable)resume{
    
    
    self.sessionManager = [SessionRequestManager manager];
    UpdateProfileRequest *request = [[UpdateProfileRequest alloc] init];
    request.resume = resume;
    request.height = self.personalItem.height;
    request.weight = self.personalItem.weight;
    request.smoke = self.personalItem.smoke;
    request.drink = self.personalItem.drink;
    request.religion = self.personalItem.religion;
    request.education = self.personalItem.education;
    request.profession = self.personalItem.profession;
    request.ethnicity = self.personalItem.ethnicity;
    request.income = self.personalItem.income;
    request.children = self.personalItem.children;
    request.interests = (NSMutableArray *)self.personalItem.interests;
    request.finishHandler  = ^(BOOL success,BOOL motify,NSString *error,NSString *errmsg){
        
    };
    
    return [self.sessionManager sendRequest:request];
}


#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextView *)UITextView{

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        

        [self updateProfile:textView.text];
        // 判断输入的字是否是回车，即按下return
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}



#pragma mark - 处理键盘回调


- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat endHeight = self.tableView.contentSize.height + keyboardRect.size.height;
    self.tableView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, endHeight);
    self.tableView.contentOffset = CGPointMake(0, self.tableView.originY);
    
    

}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat endHeight = self.tableView.contentSize.height - keyboardRect.size.height;
    self.tableView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, endHeight);
}




@end
