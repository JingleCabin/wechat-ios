//
//  WCXMPPManager.m
//  WeChat
//
//  Created by Reese on 13-8-10.
//  Copyright (c) 2013年 Reese. All rights reserved.
//
// Log levels: off, error, warn, info, verbose

#import "WCXMPPManager.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilities.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPRoster.h"
#import "XMPPMessage.h"
#import "TURNSocket.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif




#define DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define CACHES_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]

@implementation WCXMPPManager





static WCXMPPManager *sharedManager;

+(WCXMPPManager*)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager=[[WCXMPPManager alloc]init];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        
        
        [[NSUserDefaults standardUserDefaults]setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID] forKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults]setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_PASSWORD] forKey:kXMPPmyPassword];
        [[NSUserDefaults standardUserDefaults]synchronize];
       [sharedManager setupStream];
        
        
        
        

        
    });
    
    // Setup the XMPP stream
    
    
    
    return sharedManager;
}


- (void)dealloc
{
    [super dealloc];
	[self teardownStream];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma  mark ------收发消息-------
- (void)sendMessage:(XMPPMessage *)aMessage
{
    [xmppStream sendElement:aMessage];
    NSString *body = [[aMessage elementForName:@"body"] stringValue];
   // NSString *meesageStyle=[[aMessage attributeForName:@"type"] stringValue];
    NSString *meesageTo = [[aMessage to]bare];
     NSArray *strs=[meesageTo componentsSeparatedByString:@"@"];
    
    //创建message对象
    WCMessageObject *msg=[[WCMessageObject alloc]init];
    [msg setMessageDate:[NSDate date]];
    [msg setMessageFrom:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
    
    [msg setMessageTo:strs[0]];
    //判断多媒体消息
    
    NSDictionary *messageDic=[body JSONValue];
    NSLog(@"发送消息中:%@",[messageDic objectForKey:@"text"]);

    [msg setMessageType:[messageDic objectForKey:@"messageType"]];
    
    if (msg.messageType.intValue==kWCMessageTypePlain) {
        [msg setMessageContent:[messageDic objectForKey:@"text"]];
    }else
        [msg setMessageContent:[[messageDic objectForKey:@"file"]objectForKey:@"shortPath"]];

    
    //[msg setMessageContent:body];
    [WCMessageObject save:msg];
    //发送全局通知
//    [[NSNotificationCenter defaultCenter]postNotificationName:kXMPPNewMsgNotifaction object:msg ];
//    [msg release];
}



#pragma mark --------配置XML流---------
- (void)setupStream
{
	NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	    
	xmppStream = [[XMPPStream alloc] init];
	
#if !TARGET_IPHONE_SIMULATOR
	{
        xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
		// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	// Activate xmpp modules
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
	[xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
	    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
	[xmppStream setHostName:kXMPPHost];
	[xmppStream setHostPort:5222];
	
    
   
    
	// You may need to alter these settings depending on the server you're connecting to
	allowSelfSignedCertificates = NO;
	allowSSLHostNameMismatch = NO;
    
    
    if (![self connect]) {
        [[[UIAlertView alloc]initWithTitle:@"服务器连接失败" message:@"ps:本demo服务器非24小时开启，若急需请QQ 109327402" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    };
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	
	[xmppReconnect         deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// http://code.google.com/p/xmppframework/wiki/WorkingWithElements

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[xmppStream sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
	if (![xmppStream isDisconnected]) {
		return YES;
	}
    
	NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
	NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
	//
	// If you don't want to use the Settings view to set the JID,
	// uncomment the section below to hard code a JID and password.
	//
	// myJID = @"user@gmail.com/xmppframework";
	// myPassword = @"";
	
	if (myJID == nil || myPassword == nil) {
		return NO;
	}
    
	// ===这句注释掉 改成下面这句   [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    [xmppStream setMyJID:[XMPPJID jidWithUser:myJID domain:@"108.186.161.251" resource:@"ios"]];
    password=myPassword;
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
		                                                    message:@"See console for error details."
		                                                   delegate:nil
		                                          cancelButtonTitle:@"Ok"
		                                          otherButtonTitles:nil];
		[alertView show];
        
		DDLogError(@"Error connecting: %@", error);
        
		return NO;
	}
    
	return YES;
}

- (void)disconnect
{
	[self goOffline];
	[xmppStream disconnect];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UIApplicationDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store
	// enough application state information to restore your application to its current state in case
	// it is terminated later.
	//
	// If your application supports background execution,
	// called instead of applicationWillTerminate: when the user quits.
	
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
	DDLogError(@"The iPhone simulator does not process background network traffic. "
			   @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
	{
		[application setKeepAliveTimeout:600 handler:^{
			
			DDLogVerbose(@"KeepAliveHandler");
			
			// Do other keep alive stuff here.
		}];
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [xmppRosterStorage mainThreadManagedObjectContext];
}
// Returns the URL to the application's Documents directory.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (allowSelfSignedCertificates)
	{
		[settings setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamSSLAllowsAnyRoot];
	}
	
	if (allowSSLHostNameMismatch)
	{
		[settings setObject:[NSNull null] forKey:(NSString *)kCFStreamSSLPeerName];
	}
	else
	{
		// Google does things incorrectly (does not conform to RFC).
		// Because so many people ask questions about this (assume xmpp framework is broken),
		// I've explicitly added code that shows how other xmpp clients "do the right thing"
		// when connecting to a google server (gmail, or google apps for domains).
		
		NSString *expectedCertName = nil;
		
		NSString *serverDomain = xmppStream.hostName;
		NSString *virtualDomain = [xmppStream.myJID domain];
		
		if ([serverDomain isEqualToString:@"talk.google.com"])
		{
			if ([virtualDomain isEqualToString:@"gmail.com"])
			{
				expectedCertName = virtualDomain;
			}
			else
			{
				expectedCertName = serverDomain;
			}
		}
		else if (serverDomain == nil)
		{
			expectedCertName = virtualDomain;
		}
		else
		{
			expectedCertName = serverDomain;
		}
		
		if (expectedCertName)
		{
			[settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
		}
	}
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	isXmppConnected = YES;
	
	NSError *error = nil;
	
	if (![xmppStream authenticateWithPassword:password error:&error])
	{
		DDLogError(@"Error authenticating: %@", error);
	}
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	[self goOnline];
    [xmppRoster fetchRoster];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	
    NSLog(@"收到iq:%@",iq);
    
    
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [[message from]bare];
        
        
        [[[[UIAlertView alloc]initWithTitle:@"收到新消息" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil]autorelease] show];
        
    
        //创建message对象
        WCMessageObject *msg=[WCMessageObject messageWithType:kWCMessageTypePlain];
        NSArray *strs=[displayName componentsSeparatedByString:@"@"];
        [msg setMessageDate:[NSDate date]];
        [msg setMessageFrom:strs[0]];
        [msg setMessageContent:body];
        [msg setMessageTo:[[NSUserDefaults standardUserDefaults]objectForKey:kMY_USER_ID]];
        [msg setMessageType:[NSNumber numberWithInt:kWCMessageTypePlain]];
    
    if (![WCUserObject haveSaveUserById:strs[0]]) {
        [self fetchUser:strs[0]];
    }
    
    
       
    NSDictionary *messageDic=[body JSONValue];
    
    [msg setMessageType:[messageDic objectForKey:@"messageType"]];
    if (msg.messageType.intValue==kWCMessageTypePlain) {
        [msg setMessageContent:[messageDic objectForKey:@"text"]];
    }else
        [msg setMessageContent:[[messageDic objectForKey:@"file"]objectForKey:@"shortPath"]];
    [WCMessageObject save:msg];
    
    
    
            
           
		if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
		{
			// We are not active, so use a local notification instead
			UILocalNotification *localNotification = [[UILocalNotification alloc] init];
			localNotification.alertAction = @"Ok";
			localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",@"微信消息:",@"123"];
            
			[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
		}
	
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    XMPPJID *jid=[XMPPJID jidWithString:[presence stringValue]];
    [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
}

- (void)addSomeBody:(NSString *)userId
{
    [xmppRoster subscribePresenceToUser:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@108.186.161.251",userId]]];
}

-(void)fetchUser:(NSString*)userId
{
    UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"加载中" message:@"刷新好友列表中，请稍候" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [av show];
    [av release];
    
    //此API使用方式请查看www.hcios.com:8080/user/findUser.html
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:API_BASE_URL(@"servlet/GetUserDetailServlet")];
    
    [request setPostValue:userId forKey:@"userId"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestSuccess:)];
    [request setDidFailSelector:@selector(requestError:)];
    [request startAsynchronous];
}
-(void)requestSuccess:(ASIFormDataRequest*)request
{
    NSLog(@"response:%@",request.responseString);
    SBJsonParser *paser=[[[SBJsonParser alloc]init]autorelease];
    NSDictionary *rootDic=[paser objectWithString:request.responseString];
    int resultCode=[[rootDic objectForKey:@"result_code"]intValue];
    if (resultCode==1) {
        NSDictionary *dic=[rootDic objectForKey:@"data"];
        WCUserObject *user=[WCUserObject userFromDictionary:dic];
        [WCUserObject saveNewUser:user];
    }
    
}
-(void)requestError:(ASIFormDataRequest*)request
{
    
}




@end
