//
//  WCContactsViewController.h
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCContactsViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_friendsArray;
    IBOutlet UITableView *_friendTable;
}
@end
