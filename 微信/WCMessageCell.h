//
//  WCMessageCell.h
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>
//头像大小
#define HEAD_SIZE 50.0f
#define TEXT_MAX_HEIGHT 500.0f
//间距
#define INSETS 8.0f



@interface WCMessageCell : UITableViewCell
{
    UIImageView *_userHead;
    UIImageView *_bubbleBg;
    UIImageView *_headMask;
    UIImageView *_chatImage;
    UILabel *_messageConent;
}
@property (nonatomic) enum kWCMessageCellStyle msgStyle;
@property (nonatomic) int height;
-(void)setMessageObject:(WCMessageObject*)aMessage;
-(void)setHeadImage:(NSURL*)headImage tag:(int)aTag;
-(void)setChatImage:(NSURL *)chatImage tag:(int)aTag;
@end
