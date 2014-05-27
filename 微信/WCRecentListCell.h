//
//  WCRecentListCell.h
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCRecentListCell : UITableViewCell
{
    UIImageView *_userHead;
    UIImageView *_bageView;
    UILabel *_bageNumber;
    UILabel *_userNickname;
    UILabel *_messageConent;
    UILabel *_timeLable;
    UIImageView *_cellBkg;
}

-(void)setUnionObject:(WCMessageUserUnionObject*)aUnionObj;
//-(void)setHeadImage:(NSString*)imageURL;
@property (nonatomic,retain) UIImageView *userHead;
@end
