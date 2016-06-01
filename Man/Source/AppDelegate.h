//
//  AppDelegate.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AppDelegate() ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSUncaughtExceptionHandler *_handler;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) BOOL demo;
@end

