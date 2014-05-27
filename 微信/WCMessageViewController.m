//
//  WCMessageViewController.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCMessageViewController.h"
#import "WCSendMessageController.h"
#import "WCRecentListCell.h"

@interface WCMessageViewController ()

@end

@implementation WCMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"微信"];
    [self refresh];
    [_messageTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    WCXMPPManager *manager= [WCXMPPManager sharedInstance];
    [manager goOnline];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _msgArr.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"messageCell";
    WCRecentListCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[[WCRecentListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]autorelease];
    }
    
    WCMessageUserUnionObject *unionObject=[_msgArr objectAtIndex:indexPath.row];
    [cell.userHead setTag:indexPath.row];
    [cell setUnionObject:unionObject];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(void)dealloc
{
    
    
    [_messageTable release];
    [super dealloc];
    [_msgArr release];
}


#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    [self.tabBarController.tabBarItem setBadgeValue:@"1"];
    
    //[WCMessageObject save:notifacation.object];
    
   [self refresh];
    
}
-(void)refresh
{
    _msgArr=[WCMessageObject fetchRecentChatByPage:1];
    [_messageTable reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCSendMessageController *sendView=[[[WCSendMessageController alloc]init]autorelease];
    
    WCMessageUserUnionObject *unionObj=[_msgArr objectAtIndex:indexPath.row];
    
    [sendView setChatPerson:unionObj.user];
    [sendView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:sendView animated:YES];
}



@end
