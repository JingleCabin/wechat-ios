//
//  WCSendMessageController.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCSendMessageController.h"
#import "XMPPMessage.h"
#import "WCMessageCell.h"

@interface WCSendMessageController ()

@end

@implementation WCSendMessageController

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
    self.navigationItem.title=_chatPerson.userNickname;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:kXMPPNewMsgNotifaction object:nil];
     [self refresh];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        _myHeadImage=[[UIImage imageWithData:[NSData dataWithContentsOfURL:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]])]retain];
//        _userHeadImage=[[UIImage imageWithData:[NSData dataWithContentsOfURL:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:_chatPerson.userHead]])]retain];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [msgRecordTable reloadData];
        });
    });
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    [msgRecordTable addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [msgRecordTable setBackgroundView:nil];
    [msgRecordTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    
    
    _shareMoreView =[[WCChatSelectionView alloc]init];
    [_shareMoreView setFrame:CGRectMake(0, 0, 320, 170)];
    [_shareMoreView setDelegate:self];
}

-(void)refresh
{
    [messageText setInputView:nil];
    [messageText resignFirstResponder];
    msgRecords =[WCMessageObject fetchMessageListWithUser:_chatPerson.userId byPage:1];
    if (msgRecords.count!=0) {
        [msgRecordTable reloadData];
        
        [msgRecordTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:msgRecords.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [msgRecordTable release];
    [messageText release];
    [inputBar release];
    [_shareMoreView release];
    _shareMoreView=nil;
    [super dealloc];
}


#pragma mark ---触摸关闭键盘----
-(void)handleTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


#pragma mark ----键盘高度变化------
-(void)changeKeyBoard:(NSNotification *)aNotifacation
{
    //获取到键盘frame 变化之前的frame
    NSValue *keyboardBeginBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect beginRect=[keyboardBeginBounds CGRectValue];
    
    //获取到键盘frame变化之后的frame
    NSValue *keyboardEndBounds=[[aNotifacation userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect endRect=[keyboardEndBounds CGRectValue];
    
    CGFloat deltaY=endRect.origin.y-beginRect.origin.y;
    //拿frame变化之后的origin.y-变化之前的origin.y，其差值(带正负号)就是我们self.view的y方向上的增量
    
    NSLog(@"deltaY:%f",deltaY);
    [CATransaction begin];
    [UIView animateWithDuration:0.4f animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+deltaY, self.view.frame.size.width, self.view.frame.size.height)];
        [msgRecordTable setContentInset:UIEdgeInsetsMake(msgRecordTable.contentInset.top-deltaY, 0, 0, 0)];
        
    } completion:^(BOOL finished) {
        
    }];
    [CATransaction commit];
    
}
- (IBAction)sendIt:(id)sender {
    
   // NSLog(@"消息发送成功");
     NSString *message = messageText.text;
    
  

        
    NSDictionary *messageDic=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"file",[NSNumber numberWithInt:kWCMessageTypePlain],@"messageType", message,@"text", nil];
    NSString *msgJson=[messageDic JSONRepresentation];
    NSLog(@"发送json:%@",msgJson);
        //生成消息对象
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"108.186.161.251" resource:@"ios"]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:msgJson]];

        //发送消息
        [[WCXMPPManager sharedInstance] sendMessage:mes];
        
        [messageText setText:nil];
   

    
    
    
    
}


-(void)sendImage:(UIImage *)aImage
{
    NSLog(@"准备发送图片");
    //先上传头像
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"uploadFile.do")];
    [request setData:UIImageJPEGRepresentation(aImage, 0.1) withFileName:@"chatFile.jpg" andContentType:@"image/jpeg" forKey:@"file"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_API_KEY] forKey:@"apiKey"];
    [request setTimeOutSeconds:1000];
    
    [MMProgressHUD showWithTitle:@"发送文件ing..." status:@"发送文件ing...，请耐心等待"];
    [request setCompletionBlock:^{
        NSDictionary *fileDic=[NSDictionary dictionary];
        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
        
        NSDictionary *rootDic=[paser objectWithString:request.responseString];
        NSArray *files=[rootDic objectForKey:@"files"];
        if ([files count]>0) {
            fileDic=[files objectAtIndex:0];
        }
        [MMProgressHUD dismissWithSuccess:@"发送成功，干吧得" title:nil afterDelay:1.0f];
        
        NSDictionary *messageDic=[NSDictionary dictionaryWithObjectsAndKeys:fileDic,@"file",[NSNumber numberWithInt:kWCMessageTypeImage],@"messageType",@"",@"text", nil];
        NSString *msgJson=[messageDic JSONRepresentation];
       // NSLog(@"准备发送JSON:%@",msgJson);
        //生成消息对象
        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"108.186.161.251" resource:@"ios"]];
        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:msgJson]];
        
        //发送消息
        [[WCXMPPManager sharedInstance] sendMessage:mes];
        
        
    }];
    [request setFailedBlock:^{
        [MMProgressHUD dismissWithError:@"发送失败" afterDelay:1.0f];
        //[self continueRegister:fileId];
    }];
    [request startAsynchronous];

    
    
//    UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"请稍后" message:@"文件正在传送中..." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [av show];
//    [av release];
    //服务器中转方式
//    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"servlet/XMPPFileTransServlet")];
//    [request setData:UIImageJPEGRepresentation(aImage, 0.1) withFileName:@"temp.jpg" andContentType:@"image/jpg" forKey:@"transFile"];
//    [request setCompletionBlock:^{
//        //
//        //生成消息对象
//        NSString *message=request.responseString;
//        SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
//        NSError *err;
//        NSDictionary *dic= [paser objectWithString:message error:&err];
//        message =[dic objectForKey:@"filePath"];
//        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];
//        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"[1]%@",message]]];
//        
//                //发送消息
//        [[WCXMPPManager sharedInstance] sendMessage:mes];
//        
//        
//    }];
//    [request setTimeOutSeconds:10000];
//    [request startAsynchronous];
    
//    NSString *message = [Photo image2String:aImage];
//    
//    if (message.length > 0) {
//        
//        
//        
//        //生成消息对象
//        XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];
//        [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:[NSString stringWithFormat:@"[1]%@",message]]];
//        
//        //发送消息
//        [[WCXMPPManager sharedInstance] sendMessage:mes];
//        
//        
//        
//    }
    
   // [[WCXMPPManager sharedInstance]sendFile:nil toJID:[XMPPJID jidWithUser:[NSString stringWithFormat:@"%@",_chatPerson.userId] domain:@"hcios.com" resource:@"ios"]];

}



- (IBAction)shareMore:(id)sender {
    
    [messageText setInputView:messageText.inputView?nil: _shareMoreView];
    
    [messageText reloadInputViews];
    [messageText becomeFirstResponder];
}



#pragma mark   ---------tableView协议----------------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return msgRecords.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier=@"friendCell";
    WCMessageCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[[WCMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier]autorelease];
    }
    WCMessageObject *msg=[msgRecords objectAtIndex:indexPath.row];
    [cell setMessageObject:msg];
    enum kWCMessageCellStyle style=[msg.messageFrom isEqualToString:[[NSUserDefaults standardUserDefaults]stringForKey:kXMPPmyJID]]?kWCMessageCellStyleMe:kWCMessageCellStyleOther;
   
    switch (style) {
        case kWCMessageCellStyleMe:
            [cell setHeadImage:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]) tag:indexPath.row];
            
            break;
        case kWCMessageCellStyleOther:
             [cell setHeadImage:FILE_BASE_URL(_chatPerson.userHead) tag:indexPath.row];
            break;
        case kWCMessageCellStyleMeWithImage:
        {
             [cell setHeadImage:FILE_BASE_URL([[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_Head]) tag:indexPath.row];
            
        }
            break;
        case kWCMessageCellStyleOtherWithImage:{
            [cell setHeadImage:FILE_BASE_URL(_chatPerson.userHead) tag:indexPath.row];
        }
            break;
        default:
            break;
    }
   
    if ([msg.messageType intValue]==kWCMessageTypeImage) {
        style=style==kWCMessageCellStyleMe?kWCMessageCellStyleMeWithImage:kWCMessageCellStyleOtherWithImage;
        [cell setChatImage:FILE_BASE_URL(msg.messageContent) tag:indexPath.row*2];
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:msg.messageContent]]];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [cell setChatImage:image];
//            });
//            
//      
//        });
        
        
        //UIImage *img=[Photo string2Image:msg.messageContent];
        //[cell setChatImage:[Photo string2Image:msg.messageContent ]];
      //  [msg setMessageContent:@""];
    }
    
    
     [cell setMsgStyle:style];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if( [[msgRecords[indexPath.row] messageType]intValue]==kWCMessageTypeImage)
       return 55+100;
   else{
    
    NSString *orgin=[msgRecords[indexPath.row]messageContent];
    CGSize textSize=[orgin sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
       return 55+textSize.height;}
}

#pragma mark  接受新消息广播
-(void)newMsgCome:(NSNotification *)notifacation
{
    [self.tabBarController.tabBarItem setBadgeValue:@"1"];
    
    //[WCMessageObject save:notifacation.object];
    
    [self refresh];
    
}


#pragma mark sharemore按钮组协议

-(void)pickPhoto
{
    
    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imgPicker setDelegate:self];
    [imgPicker setAllowsEditing:YES];
    [self.navigationController presentViewController:imgPicker animated:YES completion:^{
    }];
    
}


#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * chosedImage=[[info objectForKey:@"UIImagePickerControllerEditedImage"]retain];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
        
        [self sendImage:chosedImage];
        

    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}



@end
