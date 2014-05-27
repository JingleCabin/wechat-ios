//
//  LLKeyBoardManager.m
//  KeyboardManager
//
//  Created by NewNumber on 13-11-7.
//  Copyright (c) 2013年 WangLiLong. All rights reserved.
//

#import "MSKeyBoardManager.h"
static MSKeyBoardManager *kbManager;
static UIView * views;

@implementation MSKeyBoardManager
+(void)installKeyboardManager:(UIView *)view
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kbManager = [[MSKeyBoardManager alloc] init];
    });
    [MSKeyBoardManager enableKeyboardManger];
    views=view;
}
+(void)enableKeyboardManger
{
    [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:kbManager selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
+(void)disableKeyboardManager
{
    [[NSNotificationCenter defaultCenter] removeObserver:kbManager];
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    for (UIView *textViews in views.subviews) {
        if (textViews.isFirstResponder) {
            if (first==0) {
                //view最开始的位置
                originY=views.frame.origin.y;
                first=1;
            }
            int height = textViews.frame.origin.y+ textViews.frame.size.height;
            if (height>(views.frame.size.height-KEYBOARD_HIGHT)) {
                [UIView animateWithDuration:0.25 animations:^{
                    CGFloat viewY = height-(views.frame.size.height-KEYBOARD_HIGHT)+10;
                    [views setFrame:CGRectMake(views.frame.origin.x,originY - viewY, views.frame.size.width, views.frame.size.height)];
                } completion:^(BOOL finished) {
                }];
                [UIView commitAnimations];
            }
        }
    }
}
-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        //将view放回原本位置
        [views setFrame:CGRectMake(views.frame.origin.x,originY, views.frame.size.width, views.frame.size.height)];
        first=0;
    } completion:^(BOOL finished) {
    }];
    [UIView commitAnimations];
}

@end
