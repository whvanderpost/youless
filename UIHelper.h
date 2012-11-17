//
//  UIHelper.h
//  YouLess
//
//  Created by Wouter van der Post on 07-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIHelper : NSObject 
{
}

// Use to show an alert with the given text and title
+ (void)showAlertWithText:(NSString *)text withTitle:(NSString *) title;

@end
