//
//  PersonalProfileTableViewController.m
//  dating
//
//  Created by lance on 16/3/10.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//  个人资料页

#import "MyProfileViewController.h"
#import "MyProfileTopTableViewCell.h"
#import "CommonLeftTitleTableViewCell.h"
#import "CommonContentTableViewCell.h"
#import "UIBarButtonItem+setItemType.h"
#import "SessionRequestManager.h"
#import "UploadHeaderPhoto.h"
#import "GetPersonProfileRequest.h"
#import "StartEditResumeRequest.h"
#import "UpdateProfileRequest.h"
#import "MotifyPersonalProfileManager.h"

typedef enum {
    RowTypePhoto,
    RowTypeMessage,
    RowTypeDescription,
} RowType;



typedef enum : NSUInteger {
    Afghanistan,
    Albania,
    Algeria,
    AmericanSamoa,
    Andorra,
    Angola,
    Anguilla,
    Antartica,
    AntiguaandBarbuda,
    Argentina,
    Armenia,
    Aruba,
    AscensionIs,
    Australia,
    Austria,
    Azerbaijan,
    Bahamas,
    Bahrain,
    Bangladesh,
    Barbados,
    Belarus,
    Belgium,
    Belize,
    BeninDahomey,
    Bermuda,
    Bhutan,
    Bolivia,
    BosniaandHerzegowina,
    Botswana,
    BouvetIsland,
    Brazil,
    BritishIndianOceanTerritory,
    BruneiDarussalam,
    Bulgaria,
    BurkinaFaso,
    Burundi,
    CambodiaKampuchea,
    Cameroon,
    Canada,
    CapeVerdeIslands,
    CarriacouIslands,
    CentralAfricanRep,
    Chad,
    Chile,
    China,
    ChristmasIsIndian,
    CocosKeelingIs,
    Colombia,
    ComorosFIRep,
    CongoBrazzaville,
    CongoKinshasa,
    CookIslandsRarotonga,
    CostaRica,
    CoteDIvoire,
    Croatia,
    Cuba,
    Cyprus,
    CzechRepublic,
    Denmark,
    DjiboutiRep,
    Dominica,
    DominicanRepublic,
    EastTimor,
    Ecuador,
    Egypt,
    ElSalvador,
    FalklandIslands,
    FaroeFaeroeIs,
    FijiIslandsSuva,
    Finland,
    France,
    FrenchAntilles,
    FrenchGuiana,
    FrenchPolynesia,
    FrenchSouthernTerritory,
    Gabon,
    Gambia,
    Georgia,
    Germany,
    Ghana,
    Gibraltar,
    Greece,
    Greenland,
    Grenada,
    Guadeloupe,
    Guam,
    Guatemala,
    GuineaEquatorial,
    GuineaBissau,
    Guyana,
    Haiti,
    HeardandMcDonaldIs,
    HolyseeVaticanCityState,
    Honduras,
    HongKong,
    Hungary,
    Iceland,
    India,
    Indonesia,
    Iran,
    Iraq,
    Ireland,
    Israel,
    Italy,
    Jamaica,
    Japan,
    Jordan,
    Kazakhstan,
    Kenya,
    Kiribati,
    KoreaNorth,
    KoreaSouth,
    Kuwait,
    Kyrgyzstan,
    Laos,
    Latvia,
    Lebanon,
    Lesotho,
    Liberia,
    Libya,
    Liechtenstein,
    Lithuania,
    Luxembourg,
    MacaoMacau,
    MacedoniaFYR,
    Madagascar,
    Malawi,
    Malaysia,
    Maldives,
    Mali,
    Malta,
    MarshallIs,
    Martinique,
    Mauritania,
    Mauritius,
    MayotteFrance,
    Mexico,
    Micronesia,
    Moldova,
    Monaco,
    Mongolia,
    Montserrat,
    Morocco,
    Mozambique,
    Myanmar,
    Namibia,
    Nauru,
    Nepal,
    Netherlands,
    NetherlandAntilles,
    NewCaledonia,
    NewZealand,
    Nicaragua,
    NigerRep,
    Nigeria,
    NiueIs,
    NorfolkIsland,
    NorthernMarianaIs,
    Norway,
    Oman,
    Pakistan,
    Palau,
    PalestinianTerritory_occupied,
    Panama,
    PapuaNewGuinea,
    Paraguay,
    Peru,
    Philippines,
    PitcairnIsland,
    Poland,
    Portugal,
    PuertoRico,
    Qatar,
    ReunionIs,
    Romania,
    Russia,
    Rwanda,
    SaintKittsNevis,
    SaintLucia,
    SaintMaarten,
    SamoaAmerican,
    SanMarino,
    SaoTomeandPrincipe,
    SaudiArabia,
    SenegalRep,
    SeychellesIs,
    SierraLeone,
    Singapore,
    Slovakia,
    Slovenia,
    SolomonIs,
    Somalia,
    SouthAfrica,
    SouthGeorgia,
    Spain,
    SriLankaCeylon,
    StHelena,
    StPierreandMiquelon,
    Sudan,
    Suriname,
    SvalbardandJanMayenIs,
    Swaziland,
    Sweden,
    Switzerland,
    Syria,
    Taiwan,
    Tajikistan,
    TanzaniaZanzibar,
    Thailand,
    Togo,
    TokelauIs,
    TongaIs,
    TrinidadandTobago,
    Tunisia,
    Turkey,
    Turkmenistan,
    TurksandCaicosIs,
    TuvaluElliceIs,
    Uganda,
    Ukraine,
    UnitedArabEmirates,
    UnitedKingdom,
    UnitedStates,
    UnitedStatesminoroutlyingislands,
    Uruguay,
    Uzbekistan,
    VanuatuNewHebrides,
    Venezuela,
    Vietnam,
    VirginIsBritish,
    VirginIsUS,
    WallisandFutunaIs,
    WesternSahara,
    YemenArabRep,
    Yugoslavia,
    Zambia,
    ZimbabweRhodesia,
    Other,
} CountryListName;


@interface  MyProfileViewController()<CommonContentCellDelegate,MyProfileTopCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextViewDelegate,NSXMLParserDelegate,UIAlertViewDelegate,MotifyPersonalProfileManagerDelegate>{
    CGRect _orgFrame;
    CGRect _newFrame;
}


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
/** 保存个人描述内容 */
@property (nonatomic,strong) NSString *personalDescription;

/** 上传图片 */
@property (nonatomic,strong) UIImage *uploadingPhoto;

/** 修改个人描述 */
@property (nonatomic,strong) MotifyPersonalProfileManager *motifyManager;



@end

@implementation MyProfileViewController


- (NSMutableArray *)countryList{
    if (!_countryList) {
        _countryList = [NSMutableArray array];
    }
    return _countryList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _orgFrame = CGRectZero;
    _newFrame = CGRectZero;
    
 self.motifyManager = [MotifyPersonalProfileManager manager];
    self.motifyManager.delegate = self;
    
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 记录inputview原始大小
    if( CGRectIsEmpty(_orgFrame) ) {
        _orgFrame = self.tableView.frame;
        
    }
    
    // 是否用新frame
    if( !CGRectIsEmpty(_newFrame) ) {
        self.tableView.frame = _newFrame;
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    if( !self.viewDidAppearEver ) {
        [self setupXMLParser];
        [self getPersonalProfile];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}



#pragma mark - 界面逻辑
- (void)setupContainView{
    [super setupContainView];
    
    [self setupNavigationBar];
    [self setupTableView];
}


- (void)initCustomParam{
    // 初始化父类参数
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"", nil);
}


- (void)setupNavigationBar{
    UILabel *Profile = [[UILabel alloc] init];
    Profile.textColor = [UIColor whiteColor];
    Profile.text = NSLocalizedString(@"My Profile",nil);
    Profile.font = [UIFont boldSystemFontOfSize:15];
    [Profile sizeToFit];
    self.navigationItem.titleView = Profile;
    
    
}

- (void)setupTableView {
    //    self.tableView.separatorColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:0.6f];
    //
    //    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    //    headerView.backgroundColor = self.tableView.separatorColor;
    //    headerView.alpha = 0.4f;
    //    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [self.tableView setTableFooterView:footerView];
    
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    
    
    
}



//设置xml解析
- (void)setupXMLParser{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country_without_code" ofType:@"xml"];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    
    NSXMLParser* xmlRead = [[NSXMLParser alloc] initWithData:data];
    [xmlRead setDelegate:self];
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //         [xmlRead parse];
    //    });
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
//    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonContentTableViewCell cellHeight]);
    
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
                
                [self.imageLoader stop];
                ImageViewLoader *imageloader = [ImageViewLoader loader];
                self.imageLoader = imageloader;
                
                imageloader.view = cell.profilePicture;
                if ([self.personalItem.photoUrl isEqualToString:AppDelegate().errorUrlConnect]) {
                    cell.profilePicture.image = [UIImage imageNamed:@"MyProfile-PersonalHead"];
                }else{
                    imageloader.url = self.personalItem.photoUrl;
                    imageloader.path = [[FileCacheManager manager] imageCachePathWithUrl:imageloader.url];
                    [imageloader loadImage];
                }

                // 判断用户头像状态, 是否显示按钮
                cell.takePhotoBtn.hidden = ![self.personalItem canUpdatePhoto];


            }break;
            case RowTypeMessage:{
                // 个人信息资料
                CommonLeftTitleTableViewCell *cell = [CommonLeftTitleTableViewCell getUITableViewCell:tableView];
                result = cell;
                
                cell.profileMessage.text = [NSString stringWithFormat:@"%@, %d", self.personalItem.firstname, self.personalItem.age];
                if( self.personalItem.firstname && self.personalItem.age ) {
                    cell.profileMessage.text = [NSString stringWithFormat:@"%@, %d", self.personalItem.firstname, self.personalItem.age];
                } else {
                    cell.profileMessage.text = @"";
                }
                
                if (self.personalItem) {
                    [cell.profileLocation setTitle:self.countryList[self.personalItem.country] forState:UIControlStateNormal];
                }else{
                    [cell.profileLocation setTitle:self.countryList[Other] forState:UIControlStateNormal];
                }
                
                
                cell.profileLocation.userInteractionEnabled = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
            }break;
            case RowTypeDescription:{
                // 自我描述
                CommonContentTableViewCell  *cell = [CommonContentTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.delegate = self;
                cell.detailText.delegate = self;
                cell.detailText.text = nil;
                
                cell.descriptionLabel.text = NSLocalizedStringFromSelf(@"PERSONAL_DESCRIPTION");
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.detailText.userInteractionEnabled = NO;
                [cell.detailText resignFirstResponder];
                
                // 个人描述审核状态
                cell.editBtn.hidden = ![self.personalItem canUpdateResume];
                cell.detailText.text = [self.personalItem canUpdateResume]?self.personalItem.resume:self.personalItem.resume_content;
                
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


#pragma mark - 点击cell中按钮的操作
- (void)commonContentCellBtnDidClick:(CommonContentTableViewCell *)cell{
    if ([cell.detailText isFirstResponder]) {
        // 键盘收起
        if (self.personalDescription != nil) {
//            [self startEditResume:self.personalDescription];
            [self showLoading];
            [self.motifyManager motifyPersonalResume:self.personalDescription];
        }
        [cell.detailText resignFirstResponder];
    } else {
        // 键盘弹出
        [cell.detailText becomeFirstResponder];
    }
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
    
//    NSString *photoTips = NSLocalizedStringFromSelf(@"Photo_Type_Choose");
    NSString *photoTypeLibrary = NSLocalizedStringFromSelf(@"Photo_Library");
    NSString *photoTypeTakePhoto = NSLocalizedStringFromSelf(@"Photo_Taking");
    NSString *photoCancel = NSLocalizedStringFromSelf(@"Cancel");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:photoCancel otherButtonTitles:photoTypeTakePhoto,photoTypeLibrary, nil,nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:photoCancel otherButtonTitles:photoTypeLibrary, nil,nil];
        
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
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    
    
}

#pragma mark - 相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
//        MyProfileTopTableViewCell *cell =  [self.tableView visibleCells].firstObject;
//        cell.profilePicture.image = info[UIImagePickerControllerOriginalImage];
        
        
        self.uploadingPhoto = info[UIImagePickerControllerOriginalImage];
        
        FileCacheManager *manager = [FileCacheManager manager];
        NSString *headPhotoPath = [manager imageUploadCachePath:self.uploadingPhoto fileName:@"headPhoto.jpg"];
        [self showLoading];
        [self upLoadHeaderPhotoWithPath:headPhotoPath];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self hideLoading];
    }];
}


#pragma mark - 接口

- (BOOL)upLoadHeaderPhotoWithPath:(NSString *)path{
    self.sessionManager = [SessionRequestManager manager];
    UploadHeaderPhoto *request = [[UploadHeaderPhoto alloc] init];
    request.fileName = path;
    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                NSLog(@"MyProfileViewController::upLoadHeaderPhotoWithPath( 上传男士头像成功 )");
                NSFileManager *manager = [NSFileManager defaultManager];
                [manager removeItemAtPath:self.imageLoader.path error:nil];
                
                MyProfileTopTableViewCell *cell =  [self.tableView visibleCells].firstObject;
                cell.profilePicture.image = self.uploadingPhoto;
            } else {
                NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Upload_Photo_Fail");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }

        });
        
    };
    return [self.sessionManager sendRequest:request];
    
}

- (BOOL)getPersonalProfile{
    [self showLoading];
    
    self.sessionManager = [SessionRequestManager manager];
    GetPersonProfileRequest *request = [[GetPersonProfileRequest alloc] init];
    request.finishHandler = ^(BOOL success,PersonalProfile *item,NSString *error,NSString *errmsg){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                NSLog(@"MyProfileViewController::getPersonalProfile( 获取男士详情成功 )");
                self.personalItem = item;

                [self reloadData:YES];
            }
            
        });
    };
    return [self.sessionManager sendRequest:request];
}

//
//- (BOOL)startEditResume:(NSString * _Nullable)resume {
//    self.loadingView.hidden = NO;
//    self.view.userInteractionEnabled = NO;
//    
//    self.sessionManager = [SessionRequestManager manager];
//    StartEditResumeRequest *request = [[StartEditResumeRequest alloc] init];
//    request.finishHandler = ^(BOOL success,NSString *error,NSString *errmsg) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.loadingView.hidden = YES;
//            self.view.userInteractionEnabled = YES;
//            
//            if (success) {
//                NSLog(@"MyProfileViewController::startEditResume( 开始计时成功 )");
//                // 开始上传个人详情
//                [self updateProfile:resume];
//                
//            } else {
//                // 弹出错误
//                NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"OK") otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//        });
//    };
//    
//    return [self.sessionManager sendRequest:request];
//}

//- (BOOL)updateProfile:(NSString * _Nullable)resume{
//    self.loadingView.hidden = NO;
//    self.view.userInteractionEnabled = NO;
//    
//    self.sessionManager = [SessionRequestManager manager];
//    UpdateProfileRequest *request = [[UpdateProfileRequest alloc] init];
//    request.resume = resume;
//    request.height = self.personalItem.height;
//    request.weight = self.personalItem.weight;
//    request.smoke = self.personalItem.smoke;
//    request.drink = self.personalItem.drink;
//    request.religion = self.personalItem.religion;
//    request.education = self.personalItem.education;
//    request.profession = self.personalItem.profession;
//    request.ethnicity = self.personalItem.ethnicity;
//    request.income = self.personalItem.income;
//    request.children = self.personalItem.children;
//    request.interests = (NSMutableArray *)self.personalItem.interests;
//    request.finishHandler  = ^(BOOL success,BOOL motify,NSString *error,NSString *errmsg){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.loadingView.hidden = YES;
//            self.view.userInteractionEnabled = YES;
//            
//            if( success ) {
//                NSLog(@"MyProfileViewController::updateProfile( 更新男士详情成功 )");
//                [self getPersonalProfile];
//                
//                if( !motify ) {
//                    NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"OK") otherButtonTitles:nil, nil];
//                    [alertView show];
//                }
//                
//            } else {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errmsg delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"OK") otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//            
//        });
//
//    };
//    
//    return [self.sessionManager sendRequest:request];
//}
//

#pragma mark - 输入回调
- (void)textViewDidBeginEditing:(UITextView *)textView{

    
}

- (void)textViewDidChange:(UITextView *)textView {
    //开始计算高度
    [self.tableView beginUpdates];
    
    //获得修改文字高度
    NSValue *rowSize;
    NSInteger height = 65;
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16], NSFontAttributeName, nil];
    height += [textView.text boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 35, MAXFLOAT)
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:dict context:nil].size.height;
    height += 65;
    
    //获取原始高度
    NSDictionary *dictionary = [self.tableViewArray objectAtIndex:RowTypeDescription];
    CGSize viewSize;
    NSValue *value = [dictionary valueForKey:ROW_SIZE];
    [value getValue:&viewSize];
    //如果修改文字高度比原始高度高,增加高度使适合tableview
    if (height > viewSize.height) {
        viewSize.height += 10;
        rowSize = [NSValue valueWithCGSize:viewSize];
        [dictionary setValue:rowSize forKey:ROW_SIZE];
        [dictionary setValue:[NSNumber numberWithInteger:RowTypeDescription] forKey:ROW_TYPE];
    }
    //结束计算
    [self.tableView endUpdates];
    if( self.tableViewArray.count > 0 ) {
        // 拉到最底
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    //保存修改内容
    self.personalDescription = textView.text;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {

    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
//        self.loadingView.hidden = NO;
        [self showLoading];
//        [self startEditResume:textView.text];
        [self.motifyManager motifyPersonalResume:textView.text];
        // 判断输入的字是否是回车，即按下return
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - 弹框提示处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
      __block BOOL bFlag = NO;
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            self.tableViewBottom.constant = -height;
            bFlag = YES;
        } else {
            self.tableViewBottom.constant = 0;
        }
    } completion:^(BOOL finished) {
        if (bFlag) {
            if( self.tableViewArray.count > 0 ) {
                // 拉到最底
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    if( self.tableViewArray.count > 0 ) {
        // 拉到最底
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}


- (void)keyboardDidShow:(NSNotification *)notification {
    self.view.userInteractionEnabled = YES;
}



- (void)motifyPersonalProfileResult:(MotifyPersonalProfileManager *)manager result:(BOOL)success {
    if (!success) {
        [self hideLoading];
        NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsMessage delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        [self hideLoading];
        [self getPersonalProfile];
    }
}
@end
