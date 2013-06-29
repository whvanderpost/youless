//
//  UIHelper.h
//  YouLess
//
//  Created by Wouter van der Post on 07-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIHelper : NSObject 

+ (NSString*)nibNameForDevice:(NSString*)nibNameOrNil;
+ (BOOL)is4InchRetina;
+ (void)showAlertWithText:(NSString *)text withTitle:(NSString *) title;

@end
