//
//  WCLoginViewController.h
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCUserProfileViewController.h"
@interface WCLoginViewController : UIViewController
{
    IBOutlet UIImageView *_userHead;
    IBOutlet UILabel *_userLoginName;
    IBOutlet UITextField *_userPassword;
    IBOutlet UIButton *_loginButton;
    IBOutlet UIButton *_registerButton;
    IBOutlet UINavigationController *mainTab;
    IBOutlet UITextField *modifiedLoginName;
    IBOutlet WCUserProfileViewController *myProfile;
    
}
- (IBAction)registerAccount:(id)sender;
- (IBAction)shiftAccount:(id)sender;
- (IBAction)startLogin:(id)sender;
@end
