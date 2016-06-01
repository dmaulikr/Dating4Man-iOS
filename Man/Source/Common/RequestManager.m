//
//  RequestManager.m
//  dating
//
//  Created by Max on 16/2/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "RequestManager.h"
#include <manrequesthandler/HttpRequestManager.h>
#include <manrequesthandler/HttpRequestHostManager.h>
#include <manrequesthandler/RequestAuthorizationController.h>
#include <manrequesthandler/RequestLadyController.h>
#include <manrequesthandler/RequestOtherController.h>
#include <manrequesthandler/RequestProfileController.h>

static RequestManager* gManager = nil;
@interface RequestManager () {
    HttpRequestManager mHttpRequestManager;
    HttpRequestHostManager mHttpRequestHostManager;
    RequestAuthorizationController* mpRequestAuthorizationController;
    RequestLadyController* mpRequestLadyController;
    RequestOtherController* mpRequestOtherController;
    RequestProfileController *mpRequestProfileController;
}

@property (nonatomic, strong) NSMutableDictionary* delegateDictionary;

@end

@implementation RequestManager

#pragma mark - 登陆认证模块回调
void onLoginWithFacebook(long requestId, bool success, LoginFacebookItem item, string errnum, string errmsg,
                         LoginErrorItem errItem);
void onRegister(long requestId, bool success, RegisterItem item, string errnum, string errmsg);
void onLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg);
void onGetCheckCode(long requestId, bool success, const char* data, int len, string errnum, string errmsg);
void onFindPassword(long requestId, bool success, string tips, string errnum, string errmsg);

RequestAuthorizationControllerCallback gRequestAuthorizationControllerCallback {
    NULL,
    onRegister,
    onGetCheckCode,
    onLogin,
    onFindPassword,
    NULL,
    NULL,
    NULL,
    NULL
};

#pragma mark - online列表模块回调
void onQueryLadyList(long requestId, bool success, list<Lady> ladyList, int totalCount, string errnum, string errmsg);
void onQueryLadyDetail(long requestId, bool success, LadyDetail item, string errnum, string errmsg);
void onAddFavouritesLady(long requestId, bool success, string errnum, string errmsg);
void onRemoveFavouritesLady(long requestId, bool success, string errnum, string errmsg);
void onRecentContact(long requestId, bool success, const string& errnum, const string& errmsg, const list<LadyRecentContact>& list);
void onRemoveContactList(long requestId, bool success, string errnum, string errmsg);

RequestLadyControllerCallback gRequestLadyControllerCallback {
    NULL,
    NULL,
    onQueryLadyList,
    onQueryLadyDetail,
    onAddFavouritesLady,
    onRemoveFavouritesLady,
    NULL,
    onRecentContact,
    onRemoveContactList,
    NULL,
    NULL,
};

#pragma mark - 其他模块回调
class RequestOtherControllerCallback : public IRequestOtherControllerCallback {
public:
    RequestOtherControllerCallback() {};
    virtual ~RequestOtherControllerCallback() {};
    
public:
    virtual void OnEmotionConfig(long requestId, bool success, const string& errnum, const string& errmsg, const OtherEmotionConfigItem& item){};
    virtual void OnGetCount(long requestId, bool success, const string& errnum, const string& errmsg, const OtherGetCountItem& item){};
    virtual void OnPhoneInfo(long requestId, bool success, const string& errnum, const string& errmsg){};
    virtual void OnIntegralCheck(long requestId, bool success, const string& errnum, const string& errmsg, const OtherIntegralCheckItem& item){};
    virtual void OnVersionCheck(long requestId, bool success, const string& errnum, const string& errmsg, const OtherVersionCheckItem& item){};
    virtual void OnSynConfig(long requestId, bool success, const string& errnum, const string& errmsg, const OtherSynConfigItem& item);
    virtual void OnOnlineCount(long requestId, bool success, const string& errnum, const string& errmsg, const OtherOnlineCountList& countList){};
    virtual void OnUploadCrashLog(long requestId, bool success, const string& errnum, const string& errmsg){};
    virtual void OnInstallLogs(long requestId, bool success, const string& errnum, const string& errmsg){};
};

static RequestOtherControllerCallback gRequestOtherControllerCallback;

#pragma mark - 获取实例
+ (instancetype)manager {
    if( gManager == nil ) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}

- (id)init {
    if( self = [super init] ) {
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.versionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        HttpClient::Init();
        
        mHttpRequestManager.SetHostManager(&mHttpRequestHostManager);
        mpRequestAuthorizationController = new RequestAuthorizationController(&mHttpRequestManager, gRequestAuthorizationControllerCallback);
        mpRequestLadyController = new RequestLadyController(&mHttpRequestManager, gRequestLadyControllerCallback);
        mpRequestOtherController = new RequestOtherController(&mHttpRequestManager, &gRequestOtherControllerCallback);
        mpRequestProfileController = new RequestProfileController(&mHttpRequestManager,gRequestProfileControllerCallback);
    }
    return self;
}

#pragma mark - 公共模块
- (void)setLogDirectory:(NSString *)directory {
    KLog::SetLogDirectory([directory UTF8String]);
    HttpClient::SetLogDirectory([directory UTF8String]);
    
}

//- (void)setVersionCode:(NSString *)version {
//    _versionCode = version;
//    mHttpRequestManager.SetVersionCode([version UTF8String]);
//    
//}

- (void)setWebSite:(NSString *)webSite appSite:(NSString *)appSite {
    mHttpRequestHostManager.SetWebSite([webSite UTF8String]);
    mHttpRequestHostManager.SetAppSite([appSite UTF8String]);
    
}


- (NSString *)getWebSite{
    return [NSString stringWithUTF8String:mHttpRequestHostManager.GetWebSite().c_str()];
    
}

- (NSString *)getAppSite{
    return [NSString stringWithUTF8String:mHttpRequestHostManager.GetAppSite().c_str()];
}


- (void)setVoiceSite:(NSString *)voiceSite {
    mHttpRequestHostManager.SetChatVoiceSite([voiceSite UTF8String]);
    
}

- (void)setAuthorization:(NSString *)user password:(NSString *)password {
    mHttpRequestManager.SetAuthorization([user UTF8String], [password UTF8String]);
    
}

- (void)cleanCookies {
    HttpClient::CleanCookies();
    
}

- (void)getCookies:(NSString *)site {
    HttpClient::GetCookies([site UTF8String]);
}

- (void)stopRequest:(NSInteger)requestId {
    mHttpRequestManager.StopRequest(requestId);
}

- (void)stopAllRequest {
    mHttpRequestManager.StopAllRequest();
}

- (NSString *)getDeviceId {
    return @"";
}

- (NSString *)getRefferer{
    return @"";
}

#pragma mark - 登陆认证模块
//注册
void onRegister(long requestId, bool success, RegisterItem item, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::onRegister( success : %s )", success?"true":"false");
    RequestManager *manager = [RequestManager manager];
    registerFinishHandler handler = nil;
    RegisterItemObject *obj = [[RegisterItemObject alloc] init];
    if (success) {
        obj.login = item.login;
        obj.email = [NSString stringWithUTF8String:item.email.c_str()];
        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
        obj.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
        obj.sid = [NSString stringWithUTF8String:item.sid.c_str()];
        obj.reg_step = [NSString stringWithUTF8String:item.reg_step.c_str()];
        obj.errnum = [NSString stringWithUTF8String:item.errnum.c_str()];
        obj.errtext = [NSString stringWithUTF8String:item.errtext.c_str()];
        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
        obj.sessionid = [NSString stringWithUTF8String:item.sessionid.c_str()];
        obj.ga_uid = [NSString stringWithUTF8String:item.ga_uid.c_str()];
        obj.photosend = item.photosend;
        obj.photoreceived = item.photoreceived;
        obj.videoreceived = item.videoreceived;
    }
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if (handler) {
        handler(success,obj,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
    
}

- (NSInteger)registerUser:(NSString *)user
                 password:(NSString *)password
                      sex:(BOOL)isMale
                firstname:(NSString *)firstname
                 lastname:(NSString *)lastname
                  country:(int)country
               birthday_y:(NSString *)birthday_y
               birthday_m:(NSString *)birthday_m
               birthday_d:(NSString *)birthday_d
               weeklymail:(BOOL)isWeeklymail
            finishHandler:(registerFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    @synchronized(self.delegateDictionary) {
        
        requestId = mpRequestAuthorizationController->Register([user UTF8String], [password UTF8String], isMale, [firstname UTF8String], [lastname UTF8String],country , [birthday_y UTF8String], [birthday_m UTF8String], [birthday_d UTF8String], isWeeklymail, [[[UIDevice currentDevice] model] UTF8String], [[self getDeviceId] UTF8String], "apple", [self.getRefferer UTF8String]);
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    
    
    return requestId;
}

//登录
void onLogin(long requestId, bool success, LoginItem item, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::onLogin( success : %s )", success?"true":"false");
    
    LoginItemObject* obj = [[LoginItemObject alloc] init];
    if( success ) {
        obj.manid = [NSString stringWithUTF8String:item.manid.c_str()];
        obj.email = [NSString stringWithUTF8String:item.email.c_str()];
        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
        obj.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
        obj.reg_step = [NSString stringWithUTF8String:item.reg_step.c_str()];
        obj.country = item.country;
        obj.telephone = [NSString stringWithUTF8String:item.telephone.c_str()];
        obj.telephone_verify = item.telephone_verify;
        obj.telephone_cc = item.telephone_cc;
        obj.sessionid = [NSString stringWithUTF8String:item.sessionid.c_str()];
        obj.ga_uid = [NSString stringWithUTF8String:item.ga_uid.c_str()];
        obj.ticketid = [NSString stringWithUTF8String:item.ticketid.c_str()];
        obj.photosend = item.photosend;
        obj.photoreceived = item.photoreceived;
        obj.premit = item.premit;
        obj.ladyprofile = item.ladyprofile;
        obj.livechat = item.livechat;
        obj.admirer = item.admirer;
        obj.bpemf = item.bpemf;
        obj.videoreceived = item.videoreceived;
    }
    
    LoginFinishHandler handler = nil;
    RequestManager *manager = [RequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if( handler ) {
        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

- (NSInteger)login:(NSString *)user password:(NSString *)password checkcode:(NSString *)checkcode finishHandler:(LoginFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    requestId = mpRequestAuthorizationController->Login([user UTF8String], [password UTF8String], [checkcode UTF8String], [[self getDeviceId] UTF8String], [self.versionCode UTF8String], [[[UIDevice currentDevice] model] UTF8String], "apple");
    
    @synchronized(self.delegateDictionary) {
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        
    }
    
    return requestId;
}

void onGetCheckCode(long requestId, bool success, const char* data, int len, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::onGetCheckCode( success : %s )", success?"true":"false");
    
    
    GetCheckCodeFinishHandler handler = nil;
    RequestManager *manager = [RequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if( handler ) {
        handler(success, data, len, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }

}

- (NSInteger)getCheckCode:(GetCheckCodeFinishHandler)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    @synchronized(self.delegateDictionary) {
        requestId = mpRequestAuthorizationController->GetCheckCode();
        
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        
    }
    
    return requestId;
}

void onFindPassword(long requestId, bool success, string tips, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::::onFindPassword( success : %s )", success?"true":"false");
    
}






#pragma mark - 个人信息模块回调
void onGetMyProfile(long requestId, bool success, ProfileItem item, string errnum, string errmsg);
void onUpdateMyProfile(long requestId, bool success, bool rsModified, string errnum, string errmsg);
void onStartEditResume(long requestId, bool success, string errnum, string errmsg);
void onSaveContact(long requestId, bool success, string errnum, string errmsg);
void onUploadHeaderPhoto(long requestId, bool success, string errnum, string errmsg);
RequestProfileControllerCallback gRequestProfileControllerCallback {
    onGetMyProfile,
    onUpdateMyProfile,
    onStartEditResume,
    NULL,
    onUploadHeaderPhoto
};






#pragma mark - 个人资料模块

void onGetMyProfile(long requestId, bool success, ProfileItem item, string errnum, string errmsg){
    FileLog("httprequest", "RequestManager::onGetMyProfile( success : %s )", success?"true":"false");
        PersonalProfile *profile = [[PersonalProfile alloc] init];;
    NSMutableArray *interestsArray = [NSMutableArray array];
    if (success) {
        profile.manId = [NSString stringWithUTF8String:item.manid.c_str()];
        profile.age = item.age;
        profile.birthday = [NSString stringWithUTF8String:item.birthday.c_str()];
        profile.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
        profile.lastname = [NSString stringWithUTF8String:item.lastname.c_str()];
        profile.email = [NSString stringWithUTF8String:item.email.c_str()];
        profile.gender = item.gender;
        profile.country = item.country;
        profile.marry = item.marry;
        profile.height = item.height;
        profile.weight = item.weight;
        profile.drink = item.drink;
        profile.language = item.language;
        profile.religion = item.religion;
        profile.education = item.education;
        profile.profession = item.profession;
        profile.ethnicity = item.ethnicity;
        profile.income = item.income;
        profile.children = item.children;
        profile.resume = [NSString stringWithUTF8String:item.resume.c_str()];
        profile.resumeCheck = [NSString stringWithUTF8String:item.resume_content.c_str()];
        profile.resumeCount = item.resume_status;
        profile.address1 = [NSString stringWithUTF8String:item.address1.c_str()];
        profile.address2 = [NSString stringWithUTF8String:item.address2.c_str()];
        profile.city = [NSString stringWithUTF8String:item.city.c_str()];
        profile.province = [NSString stringWithUTF8String:item.province.c_str()];
        profile.zipcode = [NSString stringWithUTF8String:item.zipcode.c_str()];
        profile.telephone = [NSString stringWithUTF8String:item.telephone.c_str()];
        profile.fax = [NSString stringWithUTF8String:item.fax.c_str()];
        profile.alternate_email = [NSString stringWithUTF8String:item.alternate_email.c_str()];
        profile.money = [NSString stringWithUTF8String:item.money.c_str()];
        profile.checkId = item.v_id;
        profile.photoStatus = item.photo;
        profile.photoUrl = [NSString stringWithUTF8String:item.photoURL.c_str()];
        profile.integral = item.integral;
        profile.mobile = [NSString stringWithUTF8String:item.mobile.c_str()];
        profile.mobileZoom = item.mobile_cc;
        profile.mobileStatus = item.mobile_status;
        profile.landline = [NSString stringWithUTF8String:item.landline.c_str()];
        profile.landlineZoom = item.landline_cc;
        profile.landlineLocation = [NSString stringWithUTF8String:item.landline_ac.c_str()];
        profile.landlineStatus = item.landline_status;
        
        for(list<string>::iterator itr = item.interests.begin(); itr != item.interests.end(); itr++){
            [interestsArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        profile.interests = interestsArray;
        
    }
    RequestManager *manger = [RequestManager manager];
    getMyProfileFinishHandler handler = nil;
  
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(requestId)];
        [manger.delegateDictionary removeObjectForKey:@(requestId)];
    }

    
    if (handler) {
        handler(success,profile,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

- (NSInteger)getMyProfileFinishHandler:(getMyProfileFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    @synchronized(self.delegateDictionary) {
        requestId = mpRequestProfileController->GetMyProfile();
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        return requestId;
    }
}





void onUpdateMyProfile(long requestId, bool success, bool rsModified, string errnum, string errmsg){
    FileLog("httprequest", "RequestManager::onUpdateMyProfile( success : %s )", success?"true":"false");
    RequestManager *manger = [RequestManager manager];
    updateMyProfileFinishHandler handler = nil;
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(requestId)];
        [manger.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    
    if (handler) {
        handler(success,rsModified,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
}


- (NSInteger)updateMyProfileWeight:(int)weight height:(int)height language:(int)language ethnicity:(int)ethnicity religion:(int)religion education:(int)education profession:(int)profession income:(int)income children:(int)children smoke:(int)smoke drink:(int)drink resume:(NSString *)resume interests:(NSMutableArray *)interests finish:(updateMyProfileFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    list<string> strList;
    for (NSString* str in interests){
        const char* pStr = [str UTF8String];
        strList.push_back(pStr);
    }

    @synchronized(self.delegateDictionary) {
        requestId = mpRequestProfileController->UpdateProfile(weight, height, language, ethnicity, religion, education, profession, income, children, smoke, drink, [resume UTF8String], strList);
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        return requestId;
    }
}


void onStartEditResume(long requestId, bool success, string errnum, string errmsg){
    FileLog("httprequest", "RequestManager::onStartEditResume( success : %s )", success?"true":"false");
    RequestManager *manger = [RequestManager manager];
    startEditResumeFinishHandler handler = nil;
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(requestId)];
        [manger.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    
    if (handler) {
        handler(success,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
}


- (NSInteger)startEditResumeFinishHandler:(startEditResumeFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    @synchronized(self.delegateDictionary) {
        requestId = mpRequestProfileController->StartEditResume();
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        return requestId;
    }
    
}


void onUploadHeaderPhoto(long reqeustId, bool success, string  errnum, string errmsg){
    FileLog("httprequest", "RequestManager::onUploadHeaderPhoto( success : %s )", success?"true":"false");
    RequestManager *manger = [RequestManager manager];
    uploadHeaderPhotoFinishHandler handler = nil;
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(reqeustId)];
        [manger.delegateDictionary removeObjectForKey:@(reqeustId)];
    }
    
    
    if (handler) {
          handler(success,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
  
}

- (NSInteger)uploadHeaderPhoto:(NSString *)fileName finishHandler:(uploadHeaderPhotoFinishHandler)finishHandler{
    
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    @synchronized(self.delegateDictionary) {
        requestId = mpRequestProfileController->UploadHeaderPhoto([fileName UTF8String]);
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        return requestId;
    }
    
}



#pragma mark - 女士模块
void onQueryLadyList(long requestId, bool success, list<Lady> ladyList, int totalCount, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::::onQueryLadyList( success : %s )", success?"true":"false");
    RequestManager *manager = [RequestManager manager];
    onlineListFinishHandler handler = nil;
    NSMutableArray *itemArray = [NSMutableArray array];
    if (success) {
        for(list<Lady>::iterator itr = ladyList.begin(); itr != ladyList.end(); itr++) {
            Lady item = *itr;
            QueryLadyListItemObject *obj = [[QueryLadyListItemObject alloc] init];
            obj.age = item.age;
            obj.womanid = [NSString stringWithUTF8String:item.womanid.c_str()];
            obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
            obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
            obj.height = [NSString stringWithUTF8String:item.height.c_str()];
            obj.country = [NSString stringWithUTF8String:item.country.c_str()];
            obj.province = [NSString stringWithUTF8String:item.province.c_str()];
            obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
            obj.onlineStatus = item.onlineStatus;
            [itemArray addObject:obj];
        }
    }
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
        
    }

    if (handler) {
        handler(success,itemArray,totalCount,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

/**
 *  获取联系人列表接口
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)getQueryLadyListPageIndex:(int)pageIndex
                             pageSize:(int)pageSize
                           searchType:(int)searchType
                              womanId:(NSString *)womanId
                             isOnline:(int)isOnline
                         ageRangeFrom:(int)ageRangeFrom
                           ageRangeTo:(int)ageRangeTo
                              country:(NSString *)country
                              orderBy:(int)orderBy
                        finishHandler:(onlineListFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
     requestId = mpRequestLadyController->QueryLadyList(pageIndex, pageSize, searchType, [womanId UTF8String], isOnline, ageRangeFrom, ageRangeTo, [country UTF8String], orderBy, [[[UIDevice currentDevice] model] UTF8String]);
    @synchronized(self.delegateDictionary) {
        if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
        
    }
    
    return requestId;
}


void onQueryLadyDetail(long requestId, bool success, LadyDetail item, string errnum, string errmsg) {
        FileLog("httprequest", "RequestManager::::onQueryLadyDetail( success : %s )", success?"true":"false");
    LadyDetailItemObject * obj = [[LadyDetailItemObject alloc] init];
    NSMutableArray *thumbArray = [NSMutableArray array];
    NSMutableArray *photoArray = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    if( success ) {
        obj.womanid = [NSString stringWithUTF8String:item.womanid.c_str()];
        obj.firstname = [NSString stringWithUTF8String:item.firstname.c_str()];
        obj.country = [NSString stringWithUTF8String:item.country.c_str()];
        obj.province = [NSString stringWithUTF8String:item.province.c_str()];
        obj.birthday = [NSString stringWithUTF8String:item.birthday.c_str()];
        obj.age = item.age;
        obj.zodiac = [NSString stringWithUTF8String:item.zodiac.c_str()];
        obj.weight = [NSString stringWithUTF8String:item.weight.c_str()];
        obj.height = [NSString stringWithUTF8String:item.height.c_str()];
        obj.smoke = [NSString stringWithUTF8String:item.smoke.c_str()];
        obj.drink = [NSString stringWithUTF8String:item.drink.c_str()];
        obj.english = [NSString stringWithUTF8String:item.english.c_str()];
        obj.religion = [NSString stringWithUTF8String:item.religion.c_str()];
        obj.education = [NSString stringWithUTF8String:item.education.c_str()];
        obj.profession = [NSString stringWithUTF8String:item.profession.c_str()];
        obj.children = [NSString stringWithUTF8String:item.children.c_str()];
        obj.marry = [NSString stringWithUTF8String:item.marry.c_str()];
        obj.resume = [NSString stringWithUTF8String:item.resume.c_str()];
        obj.age1 = item.age1;
        obj.age2 = item.age2;
        obj.isonline = item.isonline;
        obj.isFavorite = item.isfavorite;
        obj.last_update = [NSString stringWithUTF8String:item.last_update.c_str()];
        obj.show_lovecall = item.show_lovecall;
        obj.photoURL = [NSString stringWithUTF8String:item.photoURL.c_str()];
        obj.photoMinURL = [NSString stringWithUTF8String:item.photoMinURL.c_str()];
        
        for(list<string>::iterator itr = item.thumbList.begin(); itr != item.thumbList.end(); itr++){
            [thumbArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        obj.thumbList = thumbArray;
        
        for(list<string>::iterator itr = item.photoList.begin(); itr != item.photoList.end(); itr++){
            [photoArray addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        obj.photoList = photoArray;
        
        for(list<VideoItem>::iterator itr = item.videoList.begin(); itr != item.videoList.end(); itr++){
            VideoItem item = *itr;
            VideoItemObject *videoItem = [[VideoItemObject alloc] init];
            videoItem.id = [NSString stringWithUTF8String:item.id.c_str()];
            videoItem.thumb = [NSString stringWithUTF8String:item.thumb.c_str()];
            videoItem.time = [NSString stringWithUTF8String:item.time.c_str()];
            videoItem.photo = [NSString stringWithUTF8String:item.photo.c_str()];
            [videoArray addObject:videoItem];
        }
        obj.videoList = videoArray;
        
        obj.photoLockNum = item.photoLockNum;
//        obj.thumbList = item.thumbList;
    }
    
    LadyDetailFinishHandler handler = nil;
    RequestManager *manager = [RequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if( handler ) {
        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }
    
}



/**
 *  获取指定人物的详情
 *
 *  @param womanId       女士的id
 *
 *
 *  @return 成功:有效Id/失败:无效Id
 */
- (NSInteger)getLadyDetailWithWomanId:(NSString *)womanId finishHandler:(LadyDetailFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    requestId = mpRequestLadyController->QueryLadyDetail([womanId UTF8String]);
    
    if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    return requestId;
}



void onAddFavouritesLady(long requestId, bool success, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::onAddFavouritesLady( success : %s )", success?"true":"false");
    RequestManager *manger = [RequestManager manager];
    addFavouritesLadyFinishHandler handler = nil;
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(requestId)];
        [manger.delegateDictionary removeObjectForKey:@(requestId)];
    }
    handler(success,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
}

/**
 *  添加收藏女士
 *
 *  @param womanId       女士id
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)addFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(addFavouritesLadyFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    requestId = mpRequestLadyController->AddFavouritesLady([womanId UTF8String]);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    
    return requestId;
}


void onRemoveFavouritesLady(long requestId, bool success, string errnum, string errmsg) {
    RequestManager *manager = [RequestManager manager];
    removeFavouritesLadyFinishHandler handler = nil;
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    handler(success,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
}


/**
 *  移除收藏女士
 *
 *  @param womanId       女士id
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)removeFavouritesLadyWithWomanId:(NSString *)womanId finishHandler:(removeFavouritesLadyFinishHandler)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    requestId = mpRequestLadyController->RemoveFavouritesLady([womanId UTF8String]);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    return requestId;
}



void onRecentContact(long requestId, bool success, const string& errnum, const string& errmsg, const list<LadyRecentContact>& items) {
    FileLog("httprequest", "RequestManager::onRecentContact( success : %s )", success?"true":"false");
    
    NSMutableArray* array = [NSMutableArray array];
    for(list<LadyRecentContact>::const_iterator itr = items.begin(); itr != items.end(); itr++) {
        LadyRecentContactObject* obj = [[LadyRecentContactObject alloc] init];
        
        obj.womanId = [NSString stringWithUTF8String:itr->womanId.c_str()];
        obj.firstname = [NSString stringWithUTF8String:itr->firstname.c_str()];
        obj.age = itr->age;
        obj.photoURL = [NSString stringWithUTF8String:itr->photoURL.c_str()];
        obj.photoBigURL = [NSString stringWithUTF8String:itr->photoBigURL.c_str()];
        obj.isFavorite = itr->isFavorite;
        obj.videoCount = itr->videoCount;
        obj.lasttime = itr->lasttime;
        
        [array addObject:obj];
    }
    
    RecentContactListFinishHandler handler = nil;
    RequestManager *manager = [RequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if( handler ) {
        handler(success, array, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }
}

/**
 *  获取最近联系人接口
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)getRecentContactList:(RecentContactListFinishHandler _Nullable)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    requestId = mpRequestLadyController->RecentContactList();
    if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    
    return requestId;
}





void onRemoveContactList(long requestId, bool success, string errnum, string errmsg) {
    FileLog("httprequest", "RequestManager::onRemoveContactList( success : %s )", success?"true":"false");
    RequestManager *manger = [RequestManager manager];
    removeContactLishFinishHandler handler = nil;
    @synchronized(manger.delegateDictionary) {
        handler = [manger.delegateDictionary objectForKey:@(requestId)];
        [manger.delegateDictionary removeObjectForKey:@(requestId)];
    }
    handler(success,[NSString stringWithUTF8String:errnum.c_str()],[NSString stringWithUTF8String:errmsg.c_str()]);
    
}




/**
 *  移除联系人列表
 *
 *  @param womanIdArray  女士Id数组
 *
 *
 *  @return 成功:请求Id/失败:无效Id
 */
- (NSInteger)removeContactListWithWomanId:(NSArray *)womanIdArray finishHandler:(removeContactLishFinishHandler _Nullable)finishHandler{
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    list<string> womanIdList;
    for (NSString *womanId in womanIdArray) {
        womanIdList.push_back([womanId UTF8String]);
    }
    
    requestId = mpRequestLadyController->RemoveContactList(womanIdList);
    if (requestId != HTTPREQUEST_INVALIDREQUESTID) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    return requestId;
}



#pragma mark - 其他模块
void RequestOtherControllerCallback::OnSynConfig(long requestId, bool success, const string& errnum, const string& errmsg, const OtherSynConfigItem& item) {
    FileLog("httprequest", "RequestManager::OnSynConfig( success : %s )", success?"true":"false");
    
    SynConfigItemObject* obj = [[SynConfigItemObject alloc] init];
    if( success ) {
        // 公共配置
        PublicItemObject* pub = [[PublicItemObject alloc] init];
        pub.vgVer = item.pub.vgVer;
        pub.apkVerCode = item.pub.apkVerCode;
        pub.apkVerName = [NSString stringWithUTF8String:item.pub.apkVerName.c_str()];
        pub.apkForceUpdate = item.pub.apkForceUpdate;
        pub.facebook_enable = item.pub.facebook_enable;
        pub.apkFileVerify = [NSString stringWithUTF8String:item.pub.apkFileVerify.c_str()];
        pub.apkVerURL = [NSString stringWithUTF8String:item.pub.apkStoreURL.c_str()];
        pub.apkStoreURL = [NSString stringWithUTF8String:item.pub.apkStoreURL.c_str()];
        pub.chatVoiceHostUrl = [NSString stringWithUTF8String:item.pub.chatVoiceHostUrl.c_str()];
        pub.addCreditsUrl = [NSString stringWithUTF8String:item.pub.addCreditsUrl.c_str()];
        pub.addCredits2Url = [NSString stringWithUTF8String:item.pub.addCredits2Url.c_str()];
        pub.iOSVerCode = item.pub.iOSVerCode;
        pub.iOSVerName = [NSString stringWithUTF8String:item.pub.iOSVerName.c_str()];
        pub.iOSForceUpdate = item.pub.iOSForceUpdate;
        pub.iOSStoreUrl = [NSString stringWithUTF8String:item.pub.iOSStoreUrl.c_str()];
        obj.pub = pub;
        
        NSMutableArray* proxyHostList;
        NSMutableArray* countryList;
        
        // CL站点
        SiteItemObject* cl = [[SiteItemObject alloc] init];
        cl.host = [NSString stringWithUTF8String:item.cl.host.c_str()];
        proxyHostList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.cl.proxyHostList.begin(); itr != item.cl.proxyHostList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        cl.proxyHostList = proxyHostList;
        cl.port = item.cl.port;
        cl.minChat = item.cl.minChat;
        cl.minEmf = item.cl.minEmf;
        countryList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.cl.countryList.begin(); itr != item.cl.countryList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        cl.countryList = countryList;
        obj.cl = cl;
        
        // IDA站点
        SiteItemObject* ida = [[SiteItemObject alloc] init];
        ida.host = [NSString stringWithUTF8String:item.ida.host.c_str()];
        proxyHostList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ida.proxyHostList.begin(); itr != item.ida.proxyHostList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        ida.proxyHostList = proxyHostList;
        ida.port = item.ida.port;
        ida.minChat = item.ida.minChat;
        ida.minEmf = item.ida.minEmf;
        countryList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ida.countryList.begin(); itr != item.ida.countryList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        ida.countryList = countryList;
        obj.ida = ida;
        
        // CH站点
        SiteItemObject* ch = [[SiteItemObject alloc] init];
        ch.host = [NSString stringWithUTF8String:item.ch.host.c_str()];
        proxyHostList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ch.proxyHostList.begin(); itr != item.ch.proxyHostList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        ch.proxyHostList = proxyHostList;
        ch.port = item.ch.port;
        ch.minChat = item.ch.minChat;
        ch.minEmf = item.ch.minEmf;
        countryList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.ch.countryList.begin(); itr != item.ch.countryList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        ch.countryList = countryList;
        obj.ch = ch;
        
        // LA站点
        SiteItemObject* la = [[SiteItemObject alloc] init];
        la.host = [NSString stringWithUTF8String:item.la.host.c_str()];
        proxyHostList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.la.proxyHostList.begin(); itr != item.la.proxyHostList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        la.proxyHostList = proxyHostList;
        la.port = item.la.port;
        la.minChat = item.la.minChat;
        la.minEmf = item.la.minEmf;
        countryList = [NSMutableArray array];
        for(OtherSynConfigItem::ProxyHostList::const_iterator itr = item.la.countryList.begin(); itr != item.la.countryList.end(); itr++) {
            [proxyHostList addObject:[NSString stringWithUTF8String:itr->c_str()]];
        }
        la.countryList = countryList;
        obj.la = la;
    }

    SynConfigFinishHandler handler = nil;
    RequestManager *manager = [RequestManager manager];
    @synchronized(manager.delegateDictionary) {
        handler = [manager.delegateDictionary objectForKey:@(requestId)];
        [manager.delegateDictionary removeObjectForKey:@(requestId)];
    }
    
    if( handler ) {
        handler(success, obj, [NSString stringWithUTF8String:errnum.c_str()], [NSString stringWithUTF8String:errmsg.c_str()]);
    }

}

- (NSInteger)synConfig:(SynConfigFinishHandler _Nullable)finishHandler {
    NSInteger requestId = HTTPREQUEST_INVALIDREQUESTID;
    
    requestId = mpRequestOtherController->SynConfig();
    if( requestId != HTTPREQUEST_INVALIDREQUESTID ) {
        @synchronized(self.delegateDictionary) {
            [self.delegateDictionary setObject:finishHandler forKey:@(requestId)];
        }
    }
    
    return requestId;
}

@end