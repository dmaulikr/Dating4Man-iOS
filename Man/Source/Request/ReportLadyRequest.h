//
//  ReportLadyRequest.h
//  dating
//
//  Created by  Samson on 7/5/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionRequest.h"

@interface ReportLadyRequest : SessionRequest
@property (nonatomic, strong) NSString* _Nullable womanId;
@property (nonatomic, strong) reportLadyFinishHandler _Nullable finishHandler;
@end
