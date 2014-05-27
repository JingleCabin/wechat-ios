//
//  LLKeyBoardManager.h
//  KeyboardManager
//
//  Created by NewNumber on 13-11-7.
//  Copyright (c) 2013年 WangLiLong. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WINDOW_HIGHT [UIApplication sharedApplication].keyWindow.frame.size.height
#define KEYBOARD_HIGHT  [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height

@interface MSKeyBoardManager : NSObject{
    //键盘判断需要的变量
    int first;//判断是不是键盘弹出
    int originY;//记录最开始的view的y坐标
}
+(void)installKeyboardManager:(UIView*)view;
+(void)enableKeyboardManger;
+(void)disableKeyboardManager;
@end
