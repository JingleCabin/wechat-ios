//
//  WCFriendCell.m
//  微信
//
//  Created by reese on 14-2-15.
//  Copyright (c) 2014年 Reese. All rights reserved.
//

#import "WCFriendCell.h"

@implementation WCFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_userHead release];
    [_nickName release];
    [_description release];
    [super dealloc];
}
@end
