//
//  WCModifyProfileViewController.h
//  微信
//
//  Created by reese on 14-2-17.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCModDescViewController.h"
#import "WCModNicknameViewController.h"

@interface WCModifyProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    IBOutlet UITableView *infoTable;
}
@end
