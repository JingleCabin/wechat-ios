//
//  WCMessageObject.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCMessageObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
@implementation WCMessageObject
@synthesize messageContent,messageDate,messageFrom,messageTo,messageType,messageId;

+(WCMessageObject *)messageWithType:(int)aType{
    WCMessageObject *msg=[[WCMessageObject alloc]init];
    [msg setMessageType:[NSNumber numberWithInt:aType]];
    return  msg;
}
+(WCMessageObject*)messageFromDictionary:(NSDictionary*)aDic
{
    WCMessageObject *msg=[[WCMessageObject alloc]init];
    [msg setMessageFrom:[aDic objectForKey:kMESSAGE_FROM]];
    [msg setMessageTo:[aDic objectForKey:kMESSAGE_TO]];
    [msg setMessageContent:[aDic objectForKey:kMESSAGE_CONTENT]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_DATE]];
    [msg setMessageDate:[aDic objectForKey:kMESSAGE_TYPE]];
    return  msg;
}


//将对象转换为字典
-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:messageId,kMESSAGE_ID,messageFrom,kMESSAGE_FROM,messageTo,kMESSAGE_TO,messageContent,kMESSAGE_TYPE,messageDate,kMESSAGE_DATE,messageType,kMESSAGE_TYPE, nil];
    return dic;
    
}

//增删改查

+(BOOL)save:(WCMessageObject*)aMessage
{
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'wcMessage' ('messageId' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL  UNIQUE , 'messageFrom' VARCHAR, 'messageTo' VARCHAR, 'messageContent' VARCHAR, 'messageDate' DATETIME,'messageType' INTEGER )";
    
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    
    
    
    NSString *insertStr=@"INSERT INTO 'wcMessage' ('messageFrom','messageTo','messageContent','messageDate','messageType') VALUES (?,?,?,?,?)";
    worked = [db executeUpdate:insertStr,aMessage.messageFrom,aMessage.messageTo,aMessage.messageContent,aMessage.messageDate,aMessage.messageType];
    FMDBQuickCheck(worked);
    
    
    
    [db close];
    //发送全局通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:aMessage ];
    [aMessage release];

    
    return worked;
}




//获取某联系人聊天记录
+(NSMutableArray*)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageInde
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from wcMessage where messageFrom=? or messageTo=? order by messageDate";
    
    FMResultSet *rs=[db executeQuery:queryString,userId,userId];
    while ([rs next]) {
        WCMessageObject *message=[[[WCMessageObject alloc]init]autorelease];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        [ messageList addObject:message];
        
    }
    return  messageList;
    
}

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex
{
    NSMutableArray *messageList=[[NSMutableArray alloc]init];
    
    FMDatabase *db=[FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据打开失败");
        return messageList;
    }
    
    NSString *queryString=@"select * from wcMessage as m ,wcUser as u where u.userId<>? and ( u.userId=m.messageFrom or u.userId=m.messageTo ) group by u.userId  order by m.messageDate desc limit ?,10";
    FMResultSet *rs=[db executeQuery:queryString,[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID],[NSNumber numberWithInt:pageIndex-1]];
    while ([rs next]) {
        WCMessageObject *message=[[[WCMessageObject alloc]init]autorelease];
        [message setMessageId:[rs objectForColumnName:kMESSAGE_ID]];
        [message setMessageContent:[rs stringForColumn:kMESSAGE_CONTENT]];
        [message setMessageDate:[rs dateForColumn:kMESSAGE_DATE]];
        [message setMessageFrom:[rs stringForColumn:kMESSAGE_FROM]];
        [message setMessageTo:[rs stringForColumn:kMESSAGE_TO]];
        [message setMessageType:[rs objectForColumnName:kMESSAGE_TYPE]];
        
        WCUserObject *user=[[[WCUserObject alloc]init]autorelease];
        [user setUserId:[rs stringForColumn:kUSER_ID]];
        [user setUserNickname:[rs stringForColumn:kUSER_NICKNAME]];
        [user setUserHead:[rs stringForColumn:kUSER_USERHEAD]];
        [user setUserDescription:[rs stringForColumn:kUSER_DESCRIPTION]];
        [user setFriendFlag:[rs objectForColumnName:kUSER_FRIEND_FLAG]];
        
        WCMessageUserUnionObject *unionObject=[WCMessageUserUnionObject unionWithMessage:message andUser:user ];
        
        [ messageList addObject:unionObject];
        
    }
    return  messageList;

}



@end
