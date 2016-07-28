//
//  RegisterViewController.m
//  dating
//
//  Created by lance on 16/3/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterSecondStepViewController.h"
#import "CommonDetailTableViewCell.h"
#import "CommonTextFieldTableViewCell.h"
#import "RegisterItemObject.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SelectSwitch.h"
#import "RegisterHeaderViewCell.h"

#define maxInput 30

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


typedef enum : NSUInteger {
    RegisterMsgTypeHeaderPhoto,
    RegisterMsgTypeGender,
    RegisterMsgTypeName,
    RegisterMsgTypeBirthDay,
    RegisterMsgTypeNationality,
    RegisterMsgTypeDecribe
} RegisterMsgType;

typedef enum : NSUInteger {
    RegisterTextfieldTypeName = 70,
    RegisterTextfieldTypeDate,
    RegisterTextfieldTypeNationlity,
    RegisterTextfieldTypeDescribe,
} RegisterTextfieldType;



@interface RegisterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate,NSXMLParserDelegate,RegisterHeaderViewCellDelegate>

/** cell名称 */
@property (nonatomic,strong) NSArray *dataName;
/** 辅助视图 */
@property (nonatomic,copy) NSArray *dataAccessory;


/** 名字 */
@property (nonatomic,strong) UITextField *nameTextField;
/** 描述 */
@property (nonatomic,strong) UITextField *descriptionTextField;
/** 日期 */
@property (nonatomic,strong) UITextField *dateTextField;
/** 国家 */
@property (nonatomic,strong) UITextField *countryField;

/** 字典 */
@property (nonatomic,strong) NSMutableDictionary *dataDict;
/** basicData */
@property (nonatomic,assign) CGFloat lastScrollOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topHeight;
/** actionSheet */
@property (nonatomic,strong) UIActionSheet *actionSheet;
/** 头部视图 */
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIButton *photoLabel;
/** 相册保存的路径 */
@property (nonatomic,strong) NSString *profilePhotoPath;

/** 注册信息 */
@property (nonatomic,strong) RegisterProfileObject *registerObj;

/** 日期选择器 */
@property (nonatomic,strong) UIDatePicker *picker;
/** 国家选择器 */
@property (nonatomic,strong) UIPickerView *pickerView;

/** 性别选择 */
@property (nonatomic,strong) SelectSwitch *selectItem;
/** 国家列表 */
@property (nonatomic,strong) NSMutableArray *countryList;
/** 国家名字 */
@property (nonatomic,strong) NSString *countryName;
/** 标签 */
@property (nonatomic,strong) NSString *elementTag;

@property (nonatomic, strong) NSArray *tableViewArray;

@end

@implementation RegisterViewController

#pragma mark - lazy

- (NSMutableArray *)countryList{
    if (!_countryList) {
        _countryList = [NSMutableArray array];
    }
    return _countryList;
}


- (RegisterProfileObject *)registerObj{
    if (!_registerObj) {
        _registerObj = [[RegisterProfileObject alloc] init];
    }
    
    return _registerObj;
}


#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupXMLParser];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    self.continueBtn.adjustsImageWhenHighlighted = YES;
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]){
        //取出导航控制器的子控件
        NSArray *NavigationList = self.navigationController.navigationBar.subviews;
        //遍历
        for (id NavigationListObj in NavigationList) {
            //取出图片
            if ([NavigationListObj isKindOfClass:[UIImageView class]]) {
                //获取图片
                UIImageView *imageView = (UIImageView *)NavigationListObj;
                //取出图片的子控件
                NSArray *imageViewLineList = imageView.subviews;
                //遍历
                for (id imageViewLineListObj in imageViewLineList) {
                    //获取边线图
                    if ([imageViewLineListObj isKindOfClass:[UIImageView class]]) {
                        UIImageView *bottomLine = (UIImageView *)imageViewLineListObj;
                        bottomLine.hidden = YES;
                    }
                }
            }
        }
    }
    [self reloadData:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}





- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}

#pragma mark - 界面逻辑
- (void)initCustomParam {
//    self.customBackTitle = NSLocalizedString(@"Login", nil);
    [super initCustomParam];
    self.backTitle = NSLocalizedString(@"Register", nil);
}

//设置导航栏
- (void)setupNavigationBar{
    [super setupNavigationBar];
    
    
    UILabel *Register = [[UILabel alloc] init];
    Register.textColor = [UIColor whiteColor];
    Register.text = NSLocalizedString(@"Register", nil);
    [Register sizeToFit];
    self.navigationItem.titleView = Register;
    
    
}

- (void)setupTableView {
    self.mainVC.pagingScrollView.delaysContentTouches = NO;
    self.tableView.delaysContentTouches = NO;
    
//    self.tableView.backgroundColor = self.navigationController.navigationBar.barTintColor;
    
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
    
}

- (void)setupContainView{
    [super setupContainView];
    [self setupTableView];
    [self setupSexSwitch];
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

//设置性别选择
- (void)setupSexSwitch{
    SelectSwitch *item = [[SelectSwitch alloc] initWithFrame:CGRectMake(0, 0, 160, 36)];
    item.yesLabel.text = @"Male";
    item.yesLabel.font = [UIFont systemFontOfSize:16];
    item.noLabel.text = @"Female";
        item.noLabel.font = [UIFont systemFontOfSize:16];
    //默认为女士
    if (self.registerObj.isMale == YES) {
        item.isYes = YES;
    }else{
        item.isYes = NO;
    }
    
    [item addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventValueChanged];
    self.selectItem = item;
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
    viewSize = CGSizeMake(self.tableView.frame.size.width, [RegisterHeaderViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeHeaderPhoto] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 性别
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeGender] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // 姓名
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeName] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    //出生日期
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeBirthDay] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    //国家
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeNationality] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
//    //个人描述
//    dictionary = [NSMutableDictionary dictionary];
//    viewSize = CGSizeMake(self.tableView.frame.size.width, [CommonTextFieldTableViewCell cellHeight]);
//    rowSize = [NSValue valueWithCGSize:viewSize];
//    [dictionary setValue:rowSize forKey:ROW_SIZE];
//    [dictionary setValue:[NSNumber numberWithInteger:RegisterMsgTypeDecribe] forKey:ROW_TYPE];
//    [array addObject:dictionary];
    
    self.tableViewArray = array;
    
    if (isReloadView) {
        [self.tableView reloadData];
        
    }
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)

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



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *result = nil;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        
        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        CommonTextFieldTableViewCell *commomCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
        result = commomCell;
        [commomCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // 类型
        RegisterMsgType type = (RegisterMsgType)[[dictionarry valueForKey:ROW_TYPE] intValue];
        switch (type) {
            case RegisterMsgTypeHeaderPhoto:{
                RegisterHeaderViewCell *headerCell = [RegisterHeaderViewCell getUITableViewCell:tableView];
                [headerCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                headerCell.backgroundColor = self.navigationController.navigationBar.barTintColor;
                result = headerCell;
                headerCell.delegate = self;
//                headerCell.headerPhoto.image = self.registerObj.headerImage;
                if (self.registerObj.headerImage) {
                    headerCell.addPhotoImageView.image = self.registerObj.headerImage;
                }else{
                    headerCell.addPhotoImageView.image = [UIImage imageNamed:@"Register-UploadPhoto"];
                }
               
//                if (headerCell.headerPhoto.image) {
//                    headerCell.headerPhoto.backgroundColor = [UIColor clearColor];
//                }else{
//                    headerCell.headerPhoto.backgroundColor = self.navigationController.navigationBar.barTintColor;
//                }
                
            }break;
            case RegisterMsgTypeGender:{
                CommonTextFieldTableViewCell *commomCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
                result = commomCell;
                [commomCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_GENDER");
                commomCell.contentTextField.hidden = YES;
                commomCell.accessoryView = self.selectItem;
                commomCell.contentTextField.inputView = nil;
                commomCell.contentTextField.inputAccessoryView = nil;
                commomCell.accessoryView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
            }break;
            case RegisterMsgTypeName:{
                commomCell.accessoryView = nil;
                commomCell.contentTextField.inputView = nil;
                commomCell.contentTextField.inputAccessoryView = nil;
                commomCell.contentTextField.delegate = self;
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_NAME");
                commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"ENTER");
                commomCell.contentTextField.hidden = NO;
                commomCell.contentTextField.returnKeyType = UIReturnKeyDone;
                commomCell.contentTextField.tag = RegisterTextfieldTypeName;
                self.nameTextField = commomCell.contentTextField;
                commomCell.contentTextField.text = self.registerObj.name;
            }break;
            case RegisterMsgTypeBirthDay:{
                commomCell.accessoryView = nil;
                [commomCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                commomCell.contentTextField.delegate = self;
                commomCell.contentTextField.hidden = NO;
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_BIRTHDAY");
                commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"SELECT");
                UIDatePicker *picker = [[UIDatePicker alloc] init];
                picker.datePickerMode = UIDatePickerModeDate;
                NSTimeInterval interval =  60 * 60 * 24 * 365 * 18;
                NSDate *eighteenDate = [NSDate dateWithTimeIntervalSinceNow:-interval];
                picker.maximumDate = eighteenDate;
                  interval =  float(60.0f * 60.0f * 24.0f * 365.0f * 99.0f);
                eighteenDate = [NSDate dateWithTimeIntervalSinceNow:-interval];
                picker.minimumDate = eighteenDate;
                if (self.registerObj.birthday.length > 0) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *date=[formatter dateFromString:self.registerObj.birthday];
                    [picker setDate:date animated:NO];
                }
                
                UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelDatePicker)];
                //                toolBar.items = [NSArray arrayWithObject:right];
                toolBar.items = [NSArray arrayWithObjects:space,right, nil];
                commomCell.contentTextField.inputAccessoryView = toolBar;
                commomCell.contentTextField.inputView = picker;
                self.picker = picker;
                
                commomCell.contentTextField.tag = RegisterTextfieldTypeDate;
                self.dateTextField = commomCell.contentTextField;
                commomCell.contentTextField.text = self.registerObj.birthday;
                
                
            }break;
            case RegisterMsgTypeNationality:{
                commomCell.accessoryView = nil;
                commomCell.contentTextField.delegate = self;
                commomCell.contentTextField.hidden = NO;
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"YOUR_NATIONALITY");
                commomCell.contentTextField.placeholder = NSLocalizedStringFromSelf(@"SELECT");
//                UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 215)];
                UIPickerView *pickerView = [[UIPickerView alloc] init];
                pickerView.dataSource = self;
                pickerView.delegate = self;
                if (self.registerObj.country.length > 0) {
                    [pickerView selectRow:[self.countryList indexOfObject:self.registerObj.country] inComponent:0 animated:NO];
                }
                UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelCountryPicker)];
                toolBar.items = [NSArray arrayWithObjects:space,right, nil];
                commomCell.contentTextField.inputAccessoryView = toolBar;
                commomCell.contentTextField.inputView = pickerView;
                self.pickerView = pickerView;
                commomCell.contentTextField.tag = RegisterTextfieldTypeNationlity;
                self.countryField = commomCell.contentTextField;
                commomCell.contentTextField.text = self.registerObj.country;
                
            }break;
            case RegisterMsgTypeDecribe:{
                commomCell.accessoryView = nil;
                commomCell.contentTextField.inputAccessoryView = nil;
                commomCell.contentTextField.inputView = nil;
                commomCell.detailLabel.text = NSLocalizedStringFromSelf(@"DECRIBE_YOURSELF");
                commomCell.contentTextField.placeholder =  NSLocalizedStringFromSelf(@"ENTER");
                commomCell.contentTextField.delegate = self;
                commomCell.contentTextField.hidden = NO;
                commomCell.contentTextField.returnKeyType = UIReturnKeyDone;
                self.descriptionTextField = commomCell.contentTextField;
                commomCell.contentTextField.tag = RegisterTextfieldTypeDescribe;
                commomCell.contentTextField.text = self.registerObj.decribe;
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



#pragma mark - pickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.countryList.count;
}


#pragma mark -  pickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.countryList objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.countryField.text = [self.countryList objectAtIndex:row];
}

#pragma mark - 按钮点击事件

//点击选择相册图片
- (void)registerHeaderViewAddPhoto:(RegisterHeaderViewCell *)cell{
    [self closeKeyBoard];
    [self callSheet];
}



//点击跳转页面
- (IBAction)continue2NextPage:(id)sender {
    
    if ([self.nameTextField isFirstResponder] || [self.dateTextField isFirstResponder] || [self.countryField isFirstResponder] || [self.descriptionTextField isFirstResponder]) {
        if ([self.dateTextField isFirstResponder]) {
            [self cancelDatePicker];
        }
        
        if ([self.countryField isFirstResponder]) {
//            [self cancelCountryPicker];
        }
        
        [self closeKeyBoard];
    }else{
        
        NSString *tipsPhoto = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_PHOTO");
         NSString *tipsName = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_NAME");
         NSString *tipsBirthday = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_BIRTHDAY");
         NSString *tipsNationality = NSLocalizedStringFromSelf(@"TIPS_REGISTERMESSAGE_NATIONALITY");
        NSString *confirm = NSLocalizedStringFromSelf(@"OK");
        
        if (!self.registerObj.headerImage) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsPhoto delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        if (self.registerObj.name.length == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsName delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        if (self.registerObj.birthday.length == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsBirthday delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        
        // 检测国家是否为空
//        if (self.registerObj.country.length == 0) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:tipsNationality delegate:self cancelButtonTitle:confirm otherButtonTitles:nil, nil];
//            [alertView show];
//            return;
//        }
        
        
        
        
        RegisterSecondStepViewController *step2 = [[RegisterSecondStepViewController alloc] init];
        if (self.registerObj.headerImage) {
            step2.profileImage = self.registerObj.headerImage;
            step2.profilePhoto = self.profilePhotoPath;
        }
        step2.lastProfileObject = self.registerObj;
        
        [self.navigationController pushViewController:step2 animated:YES];
        
        NSInteger countryIndex = -1;
        if( self.registerObj.country.length > 0 ) {
            countryIndex = [self.countryList indexOfObject:self.registerObj.country];
        } else {
            countryIndex = self.countryList.count - 1;
        }
        step2.countryIndex = (int)countryIndex;
    }
    
    //    [self closeKeyBoard];
    
    
}

//关闭键盘
- (void)closeKeyBoard {
    [self.nameTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
    [self.countryField resignFirstResponder];
    [self.dateTextField resignFirstResponder];
}




/**
 *  退出选择日期
 */
- (void)cancelDatePicker {
    
    if (self.dateTextField.tag == RegisterTextfieldTypeDate) {
        NSDate *selectDate = [self.picker date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *birthday =  [dateFormatter stringFromDate:selectDate];
        self.dateTextField.text = birthday;
        self.registerObj.birthday = self.dateTextField.text;
        [self.dateTextField resignFirstResponder];
        [self reloadData:YES];
    }
}


/**
 *  性别的选择
 *
 *  @param sexSelect 性别选择控件
 */
- (void)sexSelect:(SelectSwitch *)sexSelect{
    self.registerObj.isMale = sexSelect.isYes;
}



/**
 *  退出国家选择
 */
- (void)cancelCountryPicker{
    
    if (self.countryField.tag == RegisterTextfieldTypeNationlity) {
        if (self.countryField.text.length == 0) {
            [self pickerView:self.pickerView didSelectRow:0 inComponent:1];
        }
        self.registerObj.country = self.countryField.text;
        [self.countryField resignFirstResponder];
        [self reloadData:YES];
    }
    
}


#pragma mark - 相册逻辑
- (void)callSheet{
    
//    NSString *photoTips = NSLocalizedStringFromSelf(@"Photo_Type_Choose");
    NSString *photoTypeLibrary = NSLocalizedStringFromSelf(@"PHOTO_LIBRARY");
    NSString *photoTypeTakePhoto = NSLocalizedStringFromSelf(@"PHOTO_TAKING");
    NSString *photoCancel = NSLocalizedStringFromSelf(@"Cancel");
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:photoCancel otherButtonTitles:photoTypeTakePhoto,photoTypeLibrary, nil,nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:photoCancel otherButtonTitles:photoTypeLibrary, nil,nil];
    }
    self.actionSheet.tag = 1001;
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1001) {
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
        imagePicker.sourceType = sourceType;
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        //        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //            imagePicker.allowsEditing = NO;
        //            imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1, 1);
        //        }
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    
}

#pragma mark - 相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        self.registerObj.headerImage = info[UIImagePickerControllerOriginalImage];
        
        FileCacheManager *manager = [FileCacheManager manager];
        
        self.profilePhotoPath =  [manager imageUploadCachePath:self.registerObj.headerImage uploadImageName:@"headPhoto.png"];
        
        [self reloadData:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

        
    }];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - 输入回调

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == RegisterTextfieldTypeName) {
        self.registerObj.name = self.nameTextField.text;
    }else if (textField.tag == RegisterTextfieldTypeDate){
        self.registerObj.birthday = self.dateTextField.text;
    }else if (textField.tag == RegisterTextfieldTypeNationlity){
        self.registerObj.country = self.countryField.text;
    }else if (textField.tag == RegisterTextfieldTypeDescribe){
        self.registerObj.decribe = self.descriptionTextField.text;
    }
    
    
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]){
        // 判断输入的字是否是回车，即按下return
        [textField resignFirstResponder];
        return NO;
    }
    if (range.location >= maxInput) {
        return NO;
    }
    
    //国家和日期不允许输入
    if (textField.tag == RegisterTextfieldTypeDate || textField.tag == RegisterTextfieldTypeNationlity) {
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //    self.registerObj = [[RegisterProfileObject alloc] init];
    if( self.nameTextField == textField ) {
        self.registerObj.name = self.nameTextField.text;
        [self.nameTextField resignFirstResponder];
    } else if( self.descriptionTextField == textField ) {
        self.registerObj.decribe = self.descriptionTextField.text;
        [self.descriptionTextField resignFirstResponder];
    }
    
    return YES;
}



#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    __block BOOL bFlag = NO;
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            self.continueBtnBottom.constant = -height;
            bFlag = YES;
        } else {
            self.continueBtnBottom.constant = 0;
        }
    } completion:^(BOOL finished) {
        if (bFlag) {
            [self.view setNeedsDisplay];
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
    
   
    
//        if( self.tableViewArray.count > 0 ) {
//            // 拉到最底
//            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count - 1 inSection:0];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
//    if( self.tableViewArray.count > 0 ) {
//        // 拉到最底
//        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count - 1 inSection:0];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}




- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];

}


@end
