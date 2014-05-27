//
//  WCFindFriendsViewController.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCFindFriendsViewController.h"
#import "WCFriendCell.h"
@class WCUserProfileViewController;


@interface WCFindFriendsViewController ()

@end

@implementation WCFindFriendsViewController

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
    //self.navigationItem.prompt=@"上拉列表刷新/下拉列表翻页";
    // Do any additional setup after loading the view from its nib.
    _friendsArray =[[NSMutableArray alloc]init];
    self.navigationItem.title=@"最新注册用户";
    _pageIndex=1;
    searchKey=@"";
    [self findFriends];


    
    [_friendTable registerNib:[UINib nibWithNibName:@"WCFriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"WCFriendCell" bundle:nil] forCellReuseIdentifier:@"friendCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)findFriends
{
    
    /* 搜索好友接口 */
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"findFriend.do")];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY ] forKey:@"apiKey"];
    [request setPostValue:[NSNumber numberWithInt:_pageIndex] forKey:@"pageIndex"];
    [request setPostValue:[NSNumber numberWithInt:10] forKey:@"pageSize"];
    [request setPostValue:searchKey forKey:@"nickName"];
    [MMProgressHUD showWithTitle:@"查找好友" status:@"请求中..." ];
    [request setCompletionBlock:^{
        NSLog(@"response:%@",request.responseString);
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int resultCode=[[rootDic objectForKey:@"status"]intValue];
        if (resultCode==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"查找好友成功" afterDelay:0.75f];
            //保存账号信息
            NSArray *userArr=[rootDic objectForKey:@"userList"];
            
            for (NSDictionary *dic in userArr) {
                [_friendsArray addObject:dic];
                WCUserObject *user=[WCUserObject userFromDictionary:dic];
                if (![WCUserObject haveSaveUserById:user.userId]) {
                    [WCUserObject saveNewUser:user];
                }
            }
            [_friendTable reloadData];
            [self.searchDisplayController.searchResultsTableView reloadData];
            
            
            
        }else
        {
           [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"查找好友失败" afterDelay:0.75f];
        }

    }];
    
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"查找好友失败" afterDelay:0.75f];
    }];

    [request startAsynchronous];
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
   
    [cell.nickName setText:[_friendsArray[indexPath.row]objectForKey:@"nickName"]];
    [cell.description setText:[_friendsArray[indexPath.row]objectForKey:@"description"]];
    
    //网络头像
    [cell.userHead setTag:indexPath.row];
    [cell.userHead setWebImage:FILE_BASE_URL([_friendsArray[indexPath.row]objectForKey:@"userHead"]) placeHolder:[UIImage imageNamed:@"mb.png"] downloadFlag:indexPath.row];
    

    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<-50&&scrollView.contentOffset.y>-100)
    {
        [refreshView setHidden:NO];
        [refreshView setTransform:CGAffineTransformMakeRotation(scrollView.contentOffset.y/10)];
    }else
    {
        //[refreshView setHidden:YES];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    
    if (scrollView.contentOffset.y<-100) {
        
        [UIView animateWithDuration:2.0 animations:^{
            [refreshView.layer setTransform:CATransform3DMakeRotation(-100*M_PI, 0, 0, 1)];
        } completion:^(BOOL finished) {
            [refreshView setHidden:YES];
        }];
        _pageIndex=1;
        [_friendsArray removeAllObjects];
        [_friendTable reloadData];
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self findFriends];
    }
    if (scrollView.contentOffset.y>(scrollView.contentSize.height-scrollView.frame.size.height+100)) {
        _pageIndex++;
        [self findFriends];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}


-(void)requestError:(ASIFormDataRequest *)request
{
    NSLog(@"请求失败");
}

-(void)dealloc
{
    [_friendTable release];
    [findView release];
    [web release];

    [super dealloc];
    [_friendsArray release];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WCUserProfileViewController *profileView=[[[WCUserProfileViewController alloc]init]autorelease];
    WCUserObject *user=[[[WCUserObject alloc]init]autorelease];
    NSDictionary *dic=_friendsArray[indexPath.row];
    [user setUserId:[dic objectForKey:@"userId"]];
    [user setUserNickname:[dic objectForKey:@"nickName"]];
    [user setUserDescription:[dic objectForKey:@"description"]];
    [user setUserHead:[dic objectForKey:@"userHead"]];
    
    
    
    [profileView setThisUser:user];
    
    [profileView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:profileView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)searchUser:(id)sender {
    [findView setCenter:CGPointMake(160, self.view.frame.size.height/2)];
    [web loadRequest:[NSURLRequest requestWithURL:API_BASE_URL(@"user/addFriend.html")]];
    [self.view addSubview:findView];
    
}

- (IBAction)closeFind:(id)sender {
    [findView removeFromSuperview];
}

- (IBAction)webBack:(id)sender {
    [web goBack];
    
}




#pragma mark   搜索

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
{

    return NO;
}




- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    searchKey=@"";
    _pageIndex=1;
    [_friendsArray removeAllObjects];
    [self findFriends];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchKey=searchBar.text;
    _pageIndex=1;
    [_friendsArray removeAllObjects];
    [self findFriends];
}



@end
