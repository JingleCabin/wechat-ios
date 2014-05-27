//
//  WCMessageObject.h
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMESSAGE_TYPE @"messageType"
#define kMESSAGE_FROM @"messageFrom"
#define kMESSAGE_TO @"messageTo"
#define kMESSAGE_CONTENT @"messageContent"
#define kMESSAGE_DATE @"messageDate"
#define kMESSAGE_ID @"messageId"

enum kWCMessageType {
    kWCMessageTypePlain = 0,
    kWCMessageTypeImage = 1,
    kWCMessageTypeVoice =2,
    kWCMessageTypeLocation=3
};

enum kWCMessageCellStyle {
    kWCMessageCellStyleMe = 0,
    kWCMessageCellStyleOther = 1,
    kWCMessageCellStyleMeWithImage=2,
    kWCMessageCellStyleOtherWithImage=3
};




@interface WCMessageObject : NSObject
@property (nonatomic,retain) NSString *messageFrom;
@property (nonatomic,retain) NSString *messageTo;
@property (nonatomic,retain) NSString *messageContent;
@property (nonatomic,retain) NSDate *messageDate;
@property (nonatomic,retain) NSNumber *messageType;
@property (nonatomic,retain) NSNumber *messageId;

+(WCMessageObject *)messageWithType:(int)aType;

//将对象转换为字典
-(NSDictionary*)toDictionary;
+(WCMessageObject*)messageFromDictionary:(NSDictionary*)aDic;

//数据库增删改查
+(BOOL)save:(WCMessageObject*)aMessage;
+(BOOL)deleteMessageById:(NSNumber*)aMessageId;
+(BOOL)merge:(WCMessageObject*)aMessage;

//获取某联系人聊天记录
+(NSMutableArray *)fetchMessageListWithUser:(NSString *)userId byPage:(int)pageIndex;

//获取最近联系人
+(NSMutableArray *)fetchRecentChatByPage:(int)pageIndex;


@end
