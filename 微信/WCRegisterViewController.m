//
//  WCRegisterViewController.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCRegisterViewController.h"


@interface WCRegisterViewController ()

@end

@implementation WCRegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title=@"填写手机号";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addSubview:loginNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------注册新用户--------
- (void)startRegister
{
    if (userLoginName.text.length!=11) {
        UIAlertView *av= [[[UIAlertView alloc]initWithTitle:@"请求被阻止" message:@"请填写11位手机号码" delegate:nil cancelButtonTitle:@"哦。" otherButtonTitles: nil]autorelease];
        [av show];
        return;
    }
    if (userNickName.text.length==0) {
        UIAlertView *av= [[[UIAlertView alloc]initWithTitle:@"请求被阻止" message:@"请填写昵称" delegate:nil cancelButtonTitle:@"哦。" otherButtonTitles: nil]autorelease];
        [av show];
        return;
    }
    if (userDesc.text.length==0) {
        UIAlertView *av= [[[UIAlertView alloc]initWithTitle:@"请求被阻止" message:@"请填写个性签名" delegate:nil cancelButtonTitle:@"哦。" otherButtonTitles: nil]autorelease];
        [av show];
        return;
    }
    if (userPassword.text.length<6) {
        UIAlertView *av= [[[UIAlertView alloc]initWithTitle:@"请求被阻止" message:@"请设置6位以上的用户密码" delegate:nil cancelButtonTitle:@"哦。" otherButtonTitles: nil]autorelease];
        [av show];
        return;
    }
    
    
    __block NSString *fileId=@"";
    //先上传头像
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"uploadFile.do")];
   [request setData:UIImageJPEGRepresentation(userHead.imageView.image,0.01) withFileName:[userLoginName.text stringByAppendingString:@"-head.jpg"] andContentType:@"image/jpeg" forKey:@"file"];
    [request setTimeOutSeconds:1000];
 
    [MMProgressHUD showWithTitle:@"上传头像" status:@"头像上传中，请耐心等待"];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        NSArray *files=[rootDic objectForKey:@"files"];
        if ([files count]>0) {
            fileId=[[files objectAtIndex:0] objectForKey:@"fileId"];
        }
        [MMProgressHUD dismissWithSuccess:@"上传头像成功" title:fileId afterDelay:1.0f];
        [self continueRegister:fileId];
        
    }];
    [request setFailedBlock:^{
         [MMProgressHUD dismissWithError:@"上传头像失败" afterDelay:1.0f];
        [self continueRegister:fileId];
    }];
    [request startAsynchronous];
    
    
}


-(void)continueRegister:(NSString*)fileId
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"register.do")];
    [request setPostValue:userLoginName.text forKey:@"mobile"];
    [request setPostValue:userPassword.text forKey:@"uPass"];
    [request setPostValue:userNickName.text forKey:@"nickName"];
    [request setPostValue:userDesc.text forKey:@"description"];
    [request setPostValue:fileId forKey:@"userHead"];
    [MMProgressHUD showWithTitle:@"开始注册" status:@"注册中..." ];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSLog(@"%@",request.responseString);
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
       int status=[[rootDic objectForKey:@"status"]intValue];
        if (status==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"注册成功" afterDelay:0.75f];
            NSDictionary *userDic=[rootDic objectForKey:@"userInfo"];
            [[NSUserDefaults standardUserDefaults]setObject:[rootDic objectForKey:@"apiKey"] forKey:kMY_API_KEY];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userId"] forKey:kMY_USER_ID];
            [[NSUserDefaults standardUserDefaults]setObject:userLoginName.text forKey:kMY_USER_LoginName];
            [[NSUserDefaults standardUserDefaults]setObject:userPassword.text forKey:kMY_USER_PASSWORD];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userHead"] forKey:kMY_USER_Head];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userNickname"] forKey:kMY_USER_NICKNAME];
            //立刻保存信息
            [[NSUserDefaults standardUserDefaults]synchronize];
            [self.navigationController dismissViewControllerAnimated:YES completion:Nil];
            
            
        }
        else
        {
            [MMProgressHUD dismissWithError:[rootDic objectForKey:@"msg"] title:@"注册失败" afterDelay:0.75f];
        }

        
        
    }];
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"链接服务器失败！" title:@"注册失败" afterDelay:0.75f];
    }];

    
    
    [request startAsynchronous];

}




#pragma mark   ----触摸取消输入----
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)nextStep:(id)sender{
    if (loginNumber.superview==self.view) {
        [loginNumber removeFromSuperview];
        [self.view addSubview:loginPass];
    }else
    {
        [self startRegister];
    }
    
}


- (void)dealloc {
    [loginNumber release];
    [loginPass release];
    [userLoginName release];
    [userPassword release];
    [userNickName release];
    [userDesc release];
    [userHead release];
    [super dealloc];
}
- (IBAction)changeUserHead:(id)sender {
    UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"马上照一张" otherButtonTitles:@"从相册中搞一张", nil ];
    [as showInView:self.view];

}



#pragma mark ----------ActionSheet 按钮点击-------------
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"用户点击的是第%d个按钮",buttonIndex);
    switch (buttonIndex) {
        case 0:
            //照一张
        {
            UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [imgPicker setDelegate:self];
            [imgPicker setAllowsEditing:YES];
            [self.navigationController presentViewController:imgPicker animated:YES completion:^{
            }];
            
            
            
        }
            break;
        case 1:
            //搞一张
        {
            UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
            [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imgPicker setDelegate:self];
            [imgPicker setAllowsEditing:YES];
            [self.navigationController presentViewController:imgPicker animated:YES completion:^{
            }];
            
            
            
            break;
        }
        default:
            break;
    }
    
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * userHeadImage=[[info objectForKey:@"UIImagePickerControllerEditedImage"]retain];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
        CATransition *trans=[CATransition animation];
        [trans setDuration:0.25f];
        [trans setType:@"flip"];
        [trans setSubtype:kCATransitionFromLeft];
        [userHead.imageView.layer addAnimation:trans forKey:nil];
        
        [userHead.imageView setImage:userHeadImage];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

@end
