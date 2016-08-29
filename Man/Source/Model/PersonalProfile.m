//
//  PersonalProfile.m
//  dating
//
//  Created by test on 16/5/30.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "PersonalProfile.h"

@implementation PersonalProfile

- (BOOL)canUpdatePhoto {
    BOOL bFlag = NO;
    VType vType = (VType)self.v_id;
    
    PhotoStatus photoStatus = (PhotoStatus)self.photoStatus;
    if( vType == VType_Verifing && photoStatus == Yes ) {
    } else if( vType == VType_Yes && photoStatus == Yes ) {
    } else if( photoStatus == Verifing ) {
    } else {
        bFlag = YES;
    }
    return bFlag;
}

- (BOOL)canUpdateResume {
    BOOL bFlag = NO;
    ResumeStatus resume_status = (ResumeStatus)self.resume_status;
    switch (resume_status) {
        case UnVerify:{
        }break;
        case Verified:
        case NotVerified:{
            bFlag = YES;
        }break;
        default:
            break;
    }
    return bFlag;
}
@end
