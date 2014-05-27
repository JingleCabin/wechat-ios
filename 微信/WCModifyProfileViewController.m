//
//  WCModifyProfileViewController.m
//  微信
//
//  Created by reese on 14-2-17.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WCModifyProfileViewController.h"

@interface WCModifyProfileViewController ()

@end

@implementation WCModifyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark ===tableview===
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}





-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"infoCell";
    
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    [cell.detailTextLabel setNumberOfLines:6];
    [cell.detailTextLabel setText:@""];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:10]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"头像"];
                    [cell.imageView setTag:indexPath.row];
                    [cell.imageView setWebImage:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]) placeHolder:[UIImage imageNamed:@"mb.png"] downloadFlag:indexPath.row];
                    [cell.detailTextLabel setText:@"小提示:模拟器中若无图片，先从文件夹中找一张图片，直接拖拽至模拟器中松开进入safari,点击下方的分享按钮，保存图片即可到相册中。"];
                    break;
                case 1:
                    [cell.textLabel setText:@"昵称"];
                    [cell.detailTextLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_NICKNAME]];
                    break;
                case 2:
                    [cell.textLabel setText:@"我的二维码"];
                    break;
                case 3:
                    [cell.textLabel setText:@"我的收货地址"];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setText:@"性别"];
                    //[cell.imageView setImage:[UIImage imageNamed:@"mb.png"]];
                    break;
                case 1:
                    [cell.textLabel setText:@"地区"];
                    //[cell.detailTextLabel setText:@"墨半成霜"];
                    break;
                case 2:
                    [cell.textLabel setText:@"个性签名"];
                    
                    [cell.detailTextLabel setText:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_DESC]];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            [cell.textLabel setText:@"腾讯微博"];
            break;
        default:
           // return 0;
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self changeUserHead];
                    break;
                case 1:
                {
                    WCModNicknameViewController *nickView=[[[WCModNicknameViewController alloc]init]autorelease];
                    
                    [self.navigationController pushViewController:nickView animated:YES];
                    break;
                }
                case 2:
                    
                    break;
                case 3:
              
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                   
                    break;
                case 1:
               
                    break;
                case 2:{
                    WCModDescViewController *descView=[[[WCModDescViewController alloc]init]autorelease];
                    
                    [self.navigationController pushViewController:descView animated:YES];
                    
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case 2:
            
            break;
        default:
            // return 0;
            break;
    }
    


}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row==0) {
        return 80;
    }else
        return 45;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"个人信息";
}

-(void)viewWillAppear:(BOOL)animated
{
    [infoTable reloadData];
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)changeUserHead {
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
    
    
    __block NSString *fileId=@"";
    //先上传头像
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"uploadFile.do")];
    [request setData:UIImageJPEGRepresentation(userHeadImage,0.1) withFileName:@"userhead.jpg" andContentType:@"image/jpeg" forKey:@"file"];
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
        [self changeUserHeadWithFile:fileId];
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [infoTable reloadData];
        }];
        
    }];
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"上传头像失败,请重试或者取消" afterDelay:1.0f];
       
    }];
    [request startAsynchronous];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


-(void)changeUserHeadWithFile:(NSString*)fileId
{
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"modUserInfo.do")];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY] forKey:@"apiKey"];
    [request setPostValue:fileId forKey:@"userHead"];
    [MMProgressHUD showWithTitle:@"修改头像" status:@"修改中..." ];
    [request setCompletionBlock:^{
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        NSLog(@"%@",request.responseString);
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        int status=[[rootDic objectForKey:@"status"]intValue];
        if (status==1) {
            [MMProgressHUD dismissWithSuccess:[rootDic objectForKey:@"msg"] title:@"修改成功" afterDelay:0.75f];
            NSDictionary *userDic=[rootDic objectForKey:@"userDetail"];
            [[NSUserDefaults standardUserDefaults]setObject:[userDic objectForKey:@"userHead"] forKey:kMY_USER_Head];
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
