//
//  WCModNicknameViewController.m
//  微信
//
//  Created by reese on 14-2-17.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WCModNicknameViewController.h"

@interface WCModNicknameViewController ()

@end

@implementation WCModNicknameViewController

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
    self.title=@"修改昵称";
    [nickName setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_NICKNAME]];
    [nickName becomeFirstResponder];
    
    UIBarButtonItem *modBtn=[[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    [modBtn autorelease];
    
    [self.navigationItem setRightBarButtonItem:modBtn animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)save:(id)sender
{
    NSString *nick=[nickName.text stringByReplacingOccurrencesOfString:@"/n" withString:@" "];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"modUserInfo.do")];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY] forKey:@"apiKey"];
    [request setPostValue:nick forKey:@"nickName"];
    [MMProgressHUD showWithTitle:@"修改昵称" status:@"修改中..." ];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSLog(@"%@",request.responseString);
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int status=[[rootDic objectForKey:@"status"]intValue];
        if (status==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"修改成功" afterDelay:0.75f];
            NSDictionary *userDic=[rootDic objectForKey:@"userDetail"];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"nickName"] forKey:kMY_USER_NICKNAME];
            //立刻保存信息
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }
        else
        {
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"修改失败" afterDelay:0.75f];
        }
        
        
        
    }];
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"修改失败" afterDelay:0.75f];
    }];
    
    
    
    [request startAsynchronous];
    
    
}

@end
