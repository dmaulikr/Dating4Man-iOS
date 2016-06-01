//
//  ContactListTableView.h
//  DrPalm
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 KingsleyYau. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Contact.h"
#import "LadyRecentContactObject.h"
#import "LiveChatUserItemObject.h"
#import "LadyDetailItemObject.h"

@class ContactListTableView;
//@class Contact;
@class LadyRecentContactObject;
@protocol ContactListTableViewDelegate <NSObject>
@optional
- (void)needReloadData:(ContactListTableView *)tableView;
- (void)tableView:(ContactListTableView *)tableView didSelectContact:(LadyRecentContactObject *)item;
- (void)tableView:(ContactListTableView *)tableView willDeleteContact:(LadyRecentContactObject *)item;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface ContactListTableView : UITableView <UITableViewDataSource, UITableViewDelegate>{
    
}

@property (nonatomic, weak) IBOutlet id <ContactListTableViewDelegate> tableViewDelegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) BOOL canDeleteItem;

@end
