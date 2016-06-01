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


@interface RegisterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate,NSXMLParserDelegate>

/** cell名称 */
@property (nonatomic,strong) NSArray *dataName;
/** 辅助视图 */
@property (nonatomic,copy) NSArray *dataAccessory;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

/** 名字 */
@property (nonatomic,strong) UITextField *nameTextField;
/** 描述 */
@property (nonatomic,strong) UITextField *descriptionTextField;
/** 日期 */
@property (nonatomic,strong) UITextField *dateTextField;
/** 国家 */
@property (nonatomic,strong) UITextField *countryField;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *continueBtnBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTop;
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

@end

@implementation RegisterViewController

BOOL selectResult;

#pragma mark - lazy
- (NSArray *)dataName{
    if (!_dataName) {
        _dataName = @[@"Your gender",
                      @"Your name",
                      @"Your birthday",
                      @"Your nationality",
                      @"Decribe yourself"];
    }
    return _dataName;
}

- (NSMutableDictionary *)dataDict{
    if (!_dataDict) {
        _dataDict  = [NSMutableDictionary dictionary];
    }
    
    return _dataDict;
}


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
    [self setupSexSwitch];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self reloadData:YES];
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
- (void)initNavigationItems {
    self.customBackTitle = @"Login";
    
}
//设置导航栏
- (void)setupNavigationBar{
    [super setupNavigationBar];
    
    
    UILabel *Register = [[UILabel alloc] init];
    Register.textColor = [UIColor whiteColor];
    Register.text = @"Register";
    [Register sizeToFit];
    self.navigationItem.titleView = Register;


}

- (void)setupTableView {
    self.tableView.separatorColor = [UIColor grayColor];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    headerView.backgroundColor = self.tableView.separatorColor;
    headerView.alpha = 0.4f;
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
 
    _lastScrollOffset = -self.topView.frame.size.height;
    self.tableView.contentInset = UIEdgeInsetsMake(self.topView.frame.size.height, 0, 0, 0);
    self.mainVC.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupContainView{
    [super setupContainView];
    [self setupChoosePhotoImage];
    [self setupTableView];

}


//设置头部选择图片
- (void)setupChoosePhotoImage{
    self.choosePhotoImage.layer.cornerRadius = self.choosePhotoImage.frame.size.height * 0.5f;
    self.choosePhotoImage.layer.masksToBounds = YES;
    self.choosePhotoImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapPhotoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePhoto:)];
    [self.choosePhotoImage addGestureRecognizer:tapPhotoGesture];

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
    //宽度一般是高度的2倍
    SelectSwitch *item = [[SelectSwitch alloc] initWithFrame:CGRectMake(0, 0, 122, 36)];
    item.yesLabel.text = @"Male";
    item.noLabel.text = @"Female";
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
      number = self.dataName.count;
    }
    return number;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *result = nil;
    CommonTextFieldTableViewCell *commomCell = [CommonTextFieldTableViewCell getUITableViewCell:tableView];
    result = commomCell;
    commomCell.contentTextField.delegate = self;
    commomCell.detailLabel.text = self.dataName[indexPath.row];
    [commomCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0) {
        commomCell.contentTextField.hidden = YES;
        commomCell.accessoryView = self.selectItem;
        commomCell.accessoryView.backgroundColor = [UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0];
    }
    if (indexPath.row == 1) {
        commomCell.contentTextField.hidden = NO;
        commomCell.contentTextField.returnKeyType = UIReturnKeyDone;
        self.nameTextField = commomCell.contentTextField;
        self.nameTextField.delegate = self;
    }
    if (indexPath.row == 2 ) {
        commomCell.contentTextField.hidden = NO;
        commomCell.contentTextField.placeholder = @"Select >";
        UIDatePicker *picker = [[UIDatePicker alloc] init];
        picker.datePickerMode = UIDatePickerModeDate;
        self.picker = picker;
        commomCell.contentTextField.inputView = picker;
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelDatePicker)];
        toolBar.items = [NSArray arrayWithObject:right];
        commomCell.contentTextField.inputAccessoryView = toolBar;
        self.dateTextField = commomCell.contentTextField;
        
    }
    
    if (indexPath.row == 3){
        commomCell.contentTextField.hidden = NO;
        commomCell.contentTextField.placeholder = @"Select >";
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        self.pickerView = pickerView;
        commomCell.contentTextField.inputView = pickerView;
        UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelCountryPicker)];
        toolBar.items = [NSArray arrayWithObject:right];
        commomCell.contentTextField.inputAccessoryView = toolBar;
        self.countryField = commomCell.contentTextField;
    }
    if (indexPath.row == 4) {
        commomCell.contentTextField.hidden = NO;
        commomCell.contentTextField.returnKeyType = UIReturnKeyDone;
        self.descriptionTextField = commomCell.contentTextField;
    }
    

    return result;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat delta = offsetY - self.lastScrollOffset;
    CGFloat height = self.topView.frame.size.height - delta;
    
    if (height < 0) {
        height = 0;
    }

    self.topHeight.constant = height;
    if (height == 0) {
        self.topView.hidden = YES;
    }else{
        self.topView.hidden = NO;
    }
    
    if (self.topView.frame.size.height > 150) {
        CGRect frame = self.topView.frame;
        frame.size.height = 150;
        self.topView.frame = frame;
    }else if (self.topView.frame.size.height > 50){
        self.photoLabel.hidden = NO;
    }else if (self.topView.frame.size.height < 50){
        self.photoLabel.hidden = YES;
    }

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

#pragma mark - 监听返回按钮


//点击选择相册图片
- (IBAction)choosePhoto:(id)sender {
    [self closeKeyBoard];
    [self callSheet];
}
//点击跳转页面
- (IBAction)continue2NextPage:(id)sender {
    [self closeKeyBoard];

    RegisterSecondStepViewController *step2 = [[RegisterSecondStepViewController alloc] init];
    if (self.topImageView.image) {
        step2.profileImage = self.topImageView;
        step2.profilePhoto = self.profilePhotoPath;
    }
    step2.lastProfileObject = self.registerObj;

    [self.navigationController pushViewController:step2 animated:YES];

    NSInteger countryIndex = [self.countryList indexOfObject:self.registerObj.country];
    step2.countryIndex = (int)countryIndex;
}

//关闭键盘
- (void)closeKeyBoard {
    [self.nameTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];

}




/**
 *  退出选择日期
 */
- (void)cancelDatePicker {
    NSDate *selectDate = [self.picker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *birthday =  [dateFormatter stringFromDate:selectDate];
    self.dateTextField.text = birthday;
    self.registerObj.birthday = self.dateTextField.text;
    [self.dateTextField resignFirstResponder];
    

    
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
    if (self.countryField.text.length == 0) {
        [self pickerView:self.pickerView didSelectRow:0 inComponent:1];
    }
    self.registerObj.country = self.countryField.text;
    [self.countryField resignFirstResponder];

}


#pragma mark - 相册逻辑
- (void)callSheet{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil,nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil,nil];
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
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    
}

#pragma mark - 相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{

    [picker dismissViewControllerAnimated:YES completion:^{

        self.topImageView.image = info[UIImagePickerControllerOriginalImage];
 
       FileCacheManager *manager = [FileCacheManager manager];
        
       self.profilePhotoPath =  [manager imageUploadCachePath:self.topImageView.image uploadImageName:@"test.png"];
        

    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 输入回调
//文本框文字的改变
- (void)textViewDidChange:(UITextView *)textView {
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.registerObj.name = self.nameTextField.text;
    self.registerObj.decribe = self.descriptionTextField.text;

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        // 判断输入的字是否是回车，即按下return
        [textView resignFirstResponder];
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
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            self.continueBtnBottom.constant = -height;
        } else {
            self.continueBtnBottom.constant = 0;
        }
    } completion:^(BOOL finished) {
        
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
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}



@end
