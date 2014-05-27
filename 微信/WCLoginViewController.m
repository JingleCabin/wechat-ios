//
//  WCLoginViewController.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCLoginViewController.h"
#import "WCRegisterViewController.h"
@interface WCLoginViewController ()

@end

@implementation WCLoginViewController

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
    [self configViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]) {
        [_userLoginName setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]) {
        [_userPassword setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]) {
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img=[UIImage imageWithData:[NSData dataWithContentsOfURL:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]])
];
            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *trans=[CATransition animation];
                [trans setDuration:0.25f];
                [trans setType:@"flip"];
                [trans setSubtype:kCATransitionFromLeft];
                
                [_userHead.layer addAnimation:trans forKey:nil];
                [_userHead setImage:img];

            });
        });
    }
//        [_userLoginName setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_LoginName]];
//    }
}

#pragma mark  ----初始化页面------
- (void)configViews
{
    //用户头像
//    [_userHead.layer setShadowColor:[UIColor blackColor].CGColor];
//    [_userHead.layer setShadowOffset:CGSizeMake(-1, -1)];
//    [_userHead.layer setShadowOpacity:0.5f];
    
    //登陆按钮
    [_loginButton setBackgroundImage:[[UIImage imageNamed:@"LoginGreenBigBtn_Hl"]stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateDisabled];
     [_loginButton setBackgroundImage:[[UIImage imageNamed:@"LoginGreenBigBtn"]stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateNormal];
    
    //注册按钮
    [_registerButton setBackgroundImage:[[UIImage imageNamed:@"RegistrationHighlight"]stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateDisabled];
    [_registerButton setBackgroundImage:[[UIImage imageNamed:@"RegistrationNormal"]stretchableImageWithLeftCapWidth:10 topCapHeight:15] forState:UIControlStateNormal];
}


#pragma mark   ----触摸取消输入----
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (modifiedLoginName.text.length!=0) {
        [_userLoginName setText:modifiedLoginName.text];
    }
    [modifiedLoginName setHidden:YES];
    
    [self.view endEditing:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_userHead release];
    [_userLoginName release];
    [_userPassword release];
    [_loginButton release];
    [_registerButton release];
    [mainTab release];
    [modifiedLoginName release];
    [myProfile release];
    [super dealloc];
}

#pragma mark   ----按钮事件----
- (IBAction)registerAccount:(id)sender {
    WCRegisterViewController *registerView=[[[WCRegisterViewController alloc]init]autorelease];
    UINavigationController *regNav=[[[UINavigationController alloc]initWithRootViewController:registerView]autorelease];
    [regNav.navigationBar setTintColor:[UIColor blackColor]];
    [registerView.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelRegister:)]autorelease]];
    [registerView.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStyleDone target:registerView action:@selector(nextStep:)]autorelease]];
    
    [self.navigationController presentViewController:regNav animated:YES completion:^{
        //
    }];
}

- (IBAction)shiftAccount:(id)sender {
    [modifiedLoginName setHidden:NO];
    
}


#pragma mark ------登陆--------


- (IBAction)startLogin:(id)sender {
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"login.do")];
        [request setPostValue:_userLoginName.text forKey:@"mobile"];
        [request setPostValue:_userPassword.text forKey:@"uPass"];
        [request setPostValue:[NSString stringWithFormat:@"WeChat-V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forKey:@"versionInfo"];
        [request setPostValue:[[[UIDevice currentDevice]systemName]stringByAppendingString:[[UIDevice currentDevice]systemVersion]] forKey:@"deviceInfo"];
        [MMProgressHUD showWithTitle:@"开始登陆" status:@"登陆中..." ];
        [request setCompletionBlock:^{
            SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
            NSLog(@"%@",request.responseString);
            NSDictionary *rootDic=[paser objectWithString:request.responseString];
            int status=[[rootDic objectForKey:@"status"]intValue];
            if (status==1) {
                [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"登陆成功" afterDelay:0.75f];
                NSDictionary *userDic=[rootDic objectForKey:@"userInfo"];
                [[NSUserDefaults standardUserDefaults]setObject:[rootDic objectForKey:@"apiKey"] forKey:kMY_API_KEY];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userId"] forKey:kMY_USER_ID];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userHead"] forKey:kMY_USER_Head];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"nickName"] forKey:kMY_USER_NICKNAME];
                [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"description"] forKey:kMY_USER_DESC];
                [[NSUserDefaults standardUserDefaults]setObject:_userLoginName.text forKey:kMY_USER_LoginName];
                [[NSUserDefaults standardUserDefaults]setObject:_userPassword.text forKey:kMY_USER_PASSWORD];
                //立刻保存信息
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                //更新我的信息
                
                WCUserObject *user=[[[WCUserObject alloc]init]autorelease];
                [user setUserId:[userDic objectForKey:@"userId"]];
                [user setUserNickname:[userDic objectForKey:@"nickName"]];
                [user setUserDescription:[userDic objectForKey:@"description"]];
                [user setUserHead:[userDic objectForKey:@"userHead"]];
                
                [myProfile setTitle:@"我"];
                
                [myProfile setThisUser:user];
                
               // [myProfile setHidesBottomBarWhenPushed:YES];
                
                //进入主菜单
                [self.navigationController presentViewController:mainTab animated:YES completion:Nil];
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






-(void)cancelRegister:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

                        
@end
