//
//  WCMessageViewController.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCMessageViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_msgArr;
    IBOutlet UITableView *_messageTable;
}

@end
