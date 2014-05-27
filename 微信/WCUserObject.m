//
//  WCUserObject.m
//  微信
//
//  Created by Reese on 13-8-11.
//  Copyright (c) 2013年 Reese. All rights reserved.
//

#import "WCUserObject.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@implementation WCUserObject
@synthesize userDescription,userHead,userId,userNickname,friendFlag;


+(BOOL)saveNewUser:(WCUserObject*)aUser
{
   
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    
    [WCUserObject checkTableCreatedInDb:db];

    
        
    NSString *insertStr=@"INSERT INTO 'wcUser' ('userId','nickName','description','userHead','friendFlag') VALUES (?,?,?,?,?)";
    BOOL worked = [db executeUpdate:insertStr,aUser.userId,aUser.userNickname,aUser.userDescription,aUser.userHead,aUser.friendFlag];
   // FMDBQuickCheck(worked);

    
    
    [db close];

    
    return worked;
}

+(BOOL)haveSaveUserById:(NSString*)userId
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return YES;
    };
    [WCUserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select count(*) from wcUser where userId=?",userId];
    while ([rs next]) {
        int count= [rs intForColumnIndex:0];
        
        if (count!=0){
            [rs close];
            return YES;
        }else
        {
            [rs close];
            return NO;
        }
        
    };
    [rs close];
    return YES;
    
}
+(BOOL)deleteUserById:(NSNumber*)userId
{
    return NO;

}
+(BOOL)updateUser:(WCUserObject*)newUser
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return NO;
    };
    [WCUserObject checkTableCreatedInDb:db];
    BOOL worked=[db executeUpdate:@"update wcUser set friendFlag=?, userHead=? ,nickName=? ,description=? where userId=?",newUser.friendFlag,newUser.userHead,newUser.userNickname,newUser.userDescription,newUser.userId];
    [db close];
    return worked;

}

+(NSMutableArray*)fetchAllFriendsFromLocal
{
    NSMutableArray *resultArr=[[NSMutableArray alloc]init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:DATABASE_PATH];
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return resultArr;
    };
    [WCUserObject checkTableCreatedInDb:db];
    
    FMResultSet *rs=[db executeQuery:@"select * from wcUser where friendFlag=?",[NSNumber numberWithInt:1]];
    while ([rs next]) {
        WCUserObject *user=[[WCUserObject alloc]init];
        user.userId=[rs stringForColumn:kUSER_ID];
        user.userNickname=[rs stringForColumn:kUSER_NICKNAME];
        user.userHead=[rs stringForColumn:kUSER_USERHEAD];
        user.userDescription=[rs stringForColumn:kUSER_DESCRIPTION];
        user.friendFlag=[NSNumber numberWithInt:1];
        [resultArr addObject:user];
    }
    [rs close];
    [db close];
    return resultArr;
    
}

+(WCUserObject*)userFromDictionary:(NSDictionary*)aDic
{
    WCUserObject *user=[[[WCUserObject alloc]init]autorelease];
    [user setUserId:[aDic objectForKey:kUSER_ID]];
    [user setUserHead:[aDic objectForKey:kUSER_USERHEAD]];
    [user setUserDescription:[aDic objectForKey:kUSER_DESCRIPTION]];
    [user setUserNickname:[aDic objectForKey:kUSER_NICKNAME]];
    return user;
}

-(NSDictionary*)toDictionary
{
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:userId,kUSER_ID,userNickname,kUSER_NICKNAME,userDescription,kUSER_DESCRIPTION,userHead,kUSER_USERHEAD,friendFlag,kUSER_FRIEND_FLAG, nil];
    return dic;
}


+(BOOL)checkTableCreatedInDb:(FMDatabase *)db
{
    NSString *createStr=@"CREATE  TABLE  IF NOT EXISTS 'wcUser' ('userId' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE , 'nickName' VARCHAR, 'description' VARCHAR, 'userHead' VARCHAR,'friendFlag' INT)";
    
    BOOL worked = [db executeUpdate:createStr];
    FMDBQuickCheck(worked);
    return worked;

}

@end
