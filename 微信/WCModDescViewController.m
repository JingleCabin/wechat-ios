//
//  WCModDescViewController.m
//  微信
//
//  Created by reese on 14-2-17.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WCModDescViewController.h"

@interface WCModDescViewController ()

@end

@implementation WCModDescViewController

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
    self.title=@"个性签名";
    [_descTextView setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_DESC]];
    [_descTextView becomeFirstResponder];
    
    UIBarButtonItem *modBtn=[[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    [modBtn autorelease];
    
    [self.navigationItem setRightBarButtonItem:modBtn animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [_descTextView release];
    [super dealloc];
}

-(void)save:(id)sender
{
    NSString *desc=[_descTextView.text stringByReplacingOccurrencesOfString:@"/n" withString:@" "];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"modUserInfo.do")];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY] forKey:@"apiKey"];
    [request setPostValue:desc forKey:@"description"];
    [MMProgressHUD showWithTitle:@"修改个性签名" status:@"修改中..." ];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSLog(@"%@",request.responseString);
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int status=[[rootDic objectForKey:@"status"]intValue];
        if (status==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"修改成功" afterDelay:0.75f];
            NSDictionary *userDic=[rootDic objectForKey:@"userDetail"];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"description"] forKey:kMY_USER_DESC];
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
