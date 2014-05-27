//
//  WCMessageUserUnionObject.m
//  微信
//
//  Created by Reese on 13-8-15.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCMessageUserUnionObject.h"

@implementation WCMessageUserUnionObject
@synthesize message,user;


+(WCMessageUserUnionObject *)unionWithMessage:(WCMessageObject *)aMessage andUser:(WCUserObject *)aUser
{
    WCMessageUserUnionObject *unionObject=[[WCMessageUserUnionObject alloc]init];
    [unionObject setUser:aUser];
    [unionObject setMessage:aMessage];
    return unionObject;
}



@end
