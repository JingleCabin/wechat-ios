//
//  WCFindFriendsViewController.h
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"

@interface WCFindFriendsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,UISearchBarDelegate,UIScrollViewDelegate>
{
    NSMutableArray *_friendsArray;
    NSString *searchKey;
    IBOutlet UITableView *_friendTable;
    
    IBOutlet UIWebView *web;
    IBOutlet UIView *findView;
    int _pageIndex;
    int _pageSize;
    
    IBOutlet UIImageView *refreshView;
    

}
- (IBAction)searchUser:(id)sender;
- (IBAction)closeFind:(id)sender;
- (IBAction)webBack:(id)sender;

///最后加载的SEL
- (void)refrenshDataWithLastSEL;

@end
