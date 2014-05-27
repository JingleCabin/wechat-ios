//
//  WCRegisterViewController.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCRegisterViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UIView *loginNumber;
    IBOutlet UIView *loginPass;
    IBOutlet UITextField *userLoginName;
    IBOutlet UITextField *userPassword;
    IBOutlet UITextField *userNickName;
    IBOutlet UITextField *userDesc;
    IBOutlet UIButton *userHead;
    
}
- (IBAction)changeUserHead:(id)sender;

@end
