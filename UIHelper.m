//
//  UIHelper.m
//  YouLess
//
//  Created by Wouter van der Post on 07-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "UIHelper.h"


@implementation UIHelper

// Use to show an alert with the given text and title
+ (void)showAlertWithText:(NSString *)text withTitle:(NSString *) title
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:text
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

+ (NSString*)nibNameForDevice:(NSString*)nibNameOrNil
{
    if([self is4InchRetina])
    {
        return [NSString stringWithFormat:@"%@-568h", nibNameOrNil];
    }
    
    return nibNameOrNil;
}

+ (BOOL)is4InchRetina
{
    if ((![UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 548) ||
        ([UIApplication sharedApplication].statusBarHidden && (int)[[UIScreen mainScreen] applicationFrame].size.height == 568))
    {
        return YES;
    }
    
    return NO;
}

@end
