//
//  WCContactsViewController.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCContactsViewController.h"
#import "WCUserProfileViewController.h"
#import "WCFriendCell.h"

@interface WCContactsViewController ()

@end

@implementation WCContactsViewController

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
    self.navigationItem.title=@"通讯录";
    _friendsArray=[[NSMutableArray alloc]init];
    [self getFriends];
    UIBarButtonItem *barBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    [self.navigationItem setRightBarButtonItem:barBtn];
    [barBtn release];
     [_friendTable registerNib:[UINib nibWithNibName:@"WCFriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_friendsArray release];
    _friendsArray=[WCUserObject fetchAllFriendsFromLocal];
    [_friendTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getFriends
{
    /* 搜索好友接口 */
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"getMyFriends.do")];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY ] forKey:@"apiKey"];

    [MMProgressHUD showWithTitle:@"获取我的好友" status:@"请求中..." ];
    [request setCompletionBlock:^{
        NSLog(@"response:%@",request.responseString);
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int resultCode=[[rootDic objectForKey:@"status"]intValue];
        if (resultCode==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"获取成功" afterDelay:0.75f];
            //保存账号信息
            NSArray *userArr=[rootDic objectForKey:@"userList"];
            
            for (NSDictionary *dic in userArr) {
                
                WCUserObject *user=[WCUserObject userFromDictionary:dic];
                [user setFriendFlag:[NSNumber numberWithInt:1]];
                
                if (![WCUserObject haveSaveUserById:user.userId]) {
                    [WCUserObject saveNewUser:user];
                    [_friendsArray addObject:user];
                }
                else [WCUserObject updateUser:user];
            }
            [_friendTable reloadData];
            
            
            
        }else
        {
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"获取失败" afterDelay:0.75f];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"获取失败" afterDelay:0.75f];
    }];
    
    [request startAsynchronous];
    
//    //此API使用方式请查看www.hcios.com:8080/user/findUser.html
//    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"servlet/GetFriendListServlet")];
//    
//    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID ] forKey:@"userId"];
//    [request setDelegate:self];
//    [request setDidFinishSelector:@selector(requestSuccess:)];
//    [request setDidFailSelector:@selector(requestError:)];
//    [request startAsynchronous];
}



#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friendsArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"friendCell";
    
    
    WCFriendCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];

    
    WCUserObject *user=_friendsArray[indexPath.row];
    [cell.nickName setText:user.userNickname];
    [cell.description setText:user.userDescription?user.userDescription:@"这个家伙很懒什么都没留下"];
    
    
    
    //加载网络头像
    [cell.userHead setTag:indexPath.row];
    [cell.userHead setWebImage:FILE_BASE_URL(user.userHead) placeHolder:[UIImage imageNamed:@"mb.png"] downloadFlag:indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark   -------网络请求回调---------

-(void)requestSuccess:(ASIFormDataRequest*)request
{
    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"result_code"]intValue];
    if (resultCode==1) {
        NSLog(@"查找成功");
        //保存账号信息
        //改返回的JSON数据格式请到 www.hcios.com:8080/user下查看
        NSArray *userArr=[rootDic objectForKey:@"friends"];
        
        for (NSDictionary *dic in userArr) {
            
            WCUserObject *user=[WCUserObject userFromDictionary:dic];
            [user setFriendFlag:[NSNumber numberWithInt:1]];
            
            if (![WCUserObject haveSaveUserById:user.userId]) {
                [WCUserObject saveNewUser:user];
                [_friendsArray addObject:user];
            }
            else [WCUserObject updateUser:user];
        }
        [_friendTable reloadData];
        
        
        
    }else
    {
        NSLog(@"查找好友失败,原因:%@",[rootDic objectForKey:@"msg"]);
    }
    
}


-(void)requestError:(ASIFormDataRequest *)request
{
    NSLog(@"请求失败");
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCUserProfileViewController *profileView=[[[WCUserProfileViewController alloc]init]autorelease];
//    WCUserObject *user=[[[WCUserObject alloc]init]autorelease];
//    NSDictionary *dic=_friendsArray[indexPath.row];
//    [user setUserId:[dic objectForKey:@"userId"]];
//    [user setUserNickname:[dic objectForKey:@"nickName"]];
//    [user setUserDescription:[dic objectForKey:@"description"]];
//    [user setUserHead:[dic objectForKey:@"userHead"]];
    
    
    
    [profileView setThisUser:_friendsArray[indexPath.row]];
    
    [profileView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:profileView animated:YES];

    
//    WCSendMessageController *sendView=[[[WCSendMessageController alloc]init]autorelease];
//    WCUserObject *user=_friendsArray[indexPath.row];
//
//    
//    
//    [sendView setChatPerson:user];
//    [sendView setHidesBottomBarWhenPushed:YES];
//    [self.navigationController pushViewController:sendView animated:YES];
}

- (void)dealloc {
    [_friendTable release];
    [_friendsArray release];
    [super dealloc];
}


-(void)refresh:(id)sender
{
    [self getFriends];
}
@end
