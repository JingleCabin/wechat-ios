//
//  WCUserProfileViewController.m
//  微信
//
//  Created by Reese on 13-8-14.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCUserProfileViewController.h"
#import "ASIFormDataRequest.h"
#import "WCSendMessageController.h"
#import "WCModifyProfileViewController.h"

@interface WCUserProfileViewController ()

@end

@implementation WCUserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self getUserDetail:_thisUser.userId];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [nickName.layer setCornerRadius:25];
    [nickName.layer setMasksToBounds:YES];
    
    
    
    //如果是我的资料，显示修改资料按钮
    if ([_thisUser.userId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]]) {
        UIBarButtonItem *modBtn=[[UIBarButtonItem alloc]initWithTitle:@"修改资料" style:UIBarButtonItemStylePlain target:self action:@selector(modify:)];
        [modBtn autorelease];
        
        [self.navigationItem setRightBarButtonItem:modBtn animated:YES];
        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}

-(void)dealloc
{
    [super dealloc];
    [_thisUser release];
}

- (IBAction)deleteFriend:(id)sender {
    /* 添加好友接口 */
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"deleteFriend.do")];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY ] forKey:@"apiKey"];
    [request setPostValue:_thisUser.userId forKey:@"userId"];
    [MMProgressHUD showWithTitle:@"删除好友" status:@"请求中..." ];
    [request setCompletionBlock:^{
        NSLog(@"response:%@",request.responseString);
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int resultCode=[[rootDic objectForKey:@"status"]intValue];
        if (resultCode==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"删除好友成功" afterDelay:0.75f];
            [_thisUser setFriendFlag:[NSNumber numberWithInt:0]];
            [WCUserObject updateUser:_thisUser];
            
            
        }else
        {
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"删除好友失败" afterDelay:0.75f];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"删除好友失败" afterDelay:0.75f];
    }];
    
    [request startAsynchronous];
}
- (IBAction)addFirend:(id)sender {
    
    /* 添加好友接口 */
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"addFriend.do")];
    
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY ] forKey:@"apiKey"];
    [request setPostValue:_thisUser.userId forKey:@"userId"];
    [MMProgressHUD showWithTitle:@"添加好友" status:@"请求中..." ];
    [request setCompletionBlock:^{
        NSLog(@"response:%@",request.responseString);
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int resultCode=[[rootDic objectForKey:@"status"]intValue];
        if (resultCode==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"添加好友成功" afterDelay:0.75f];
           [_thisUser setFriendFlag:[NSNumber numberWithInt:1]];
            [WCUserObject updateUser:_thisUser];
            
            
        }else
        {
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"添加好友失败" afterDelay:0.75f];
        }
        
    }];
    
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"添加好友失败" afterDelay:0.75f];
    }];
    
    [request startAsynchronous];
    
    
    [[WCXMPPManager sharedInstance]addSomeBody:_thisUser.userId];
    
}

-(IBAction)chatFirned:(id)sender
{
    WCSendMessageController *sendView=[[[WCSendMessageController alloc]init]autorelease];
    WCUserObject *user=_thisUser;
    
    
    
    [sendView setChatPerson:user];
    [sendView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:sendView animated:YES];
}


/*修改我的资料*/
-(void)modify:(id)sender
{
    WCModifyProfileViewController *modView=[[[WCModifyProfileViewController alloc]init]autorelease];
    [self.navigationController pushViewController:modView animated:YES];
}


-(void)getUserDetail:(NSString *)userId
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"getUserDetail.do")];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY] forKey:@"apiKey"];
    [request setPostValue:userId forKey:@"userId"];
    [MMProgressHUD showWithTitle:@"读取好友资料" status:@"读取中..." ];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSLog(@"%@",request.responseString);
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int status=[[rootDic objectForKey:@"status"]intValue];
        if (status==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"读取成功" afterDelay:0.75f];
            NSDictionary *userDic=[rootDic objectForKey:@"userDetail"];
            //如果是我自己的资料
            if ([userId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]]) {
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userHead"] forKey:kMY_USER_Head];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"nickName"] forKey:kMY_USER_NICKNAME];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"description"] forKey:kMY_USER_DESC];
                //立刻保存信息
                [[NSUserDefaults standardUserDefaults]synchronize];

            }
            
            [userHead setWebImage:FILE_BASE_URL([userDic objectForKey:@"userHead"]) placeHolder:[UIImage imageNamed:@"mb.png"] downloadFlag:10000];
            [nickName setText:[userDic objectForKey:@"nickName"]];
            [descLabel setText:[userDic objectForKey:@"description"]];
            int sex=[[userDic objectForKey:@"sex"] class]==[NSNull class]?-1:[[userDic objectForKey:@"sex"]intValue];

            NSString *sexStr=nil;
            switch (sex) {
                case 1:
                    sexStr=@"男";
                    break;
                case 0:
                    sexStr=@"女";
                    break;
                default:
                    sexStr=@"暂无资料";
                    break;
            }
            [sexLabel setText:sexStr];
            NSString *qqStr=[[userDic objectForKey:@"qq"] class]==[NSNull class]?@"暂无资料":[userDic objectForKey:@"qq"];
            [tencentWeibo setText:qqStr];
            NSString *areaStr=[[userDic objectForKey:@"province"] class]==[NSNull class]?@"暂无资料":[userDic objectForKey:@"province"];
            [areaLabel setText:areaStr];
            [regDate setText:[userDic objectForKey:@"registerDate"]];

        }
        else{
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"登陆失败" afterDelay:0.75f];
        }
        
    }];
    
    
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"登陆失败" afterDelay:0.75f];
    }];
    [request startAsynchronous];

}



@end
