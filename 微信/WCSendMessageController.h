//
//  WCSendMessageController.h
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCChatSelectionView.h"

@interface WCSendMessageController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WCShareMoreDelegate>
{
    IBOutlet UITableView *msgRecordTable;
    NSMutableArray *msgRecords;
    IBOutlet UITextField *messageText;
    IBOutlet UIView *inputBar;
    //UIImage *_myHeadImage,*_userHeadImage;
    WCChatSelectionView *_shareMoreView;
}
- (IBAction)sendIt:(id)sender;
- (IBAction)shareMore:(id)sender;
@property (nonatomic,retain) WCUserObject *chatPerson;
@end
