//
//  WCMessageUserUnionObject.h
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCMessageUserUnionObject : NSObject
@property (nonatomic,retain) WCMessageObject* message;
@property (nonatomic,retain) WCUserObject* user;

+(WCMessageUserUnionObject *)unionWithMessage:(WCMessageObject *)aMessage andUser:(WCUserObject *)aUser;
@end
