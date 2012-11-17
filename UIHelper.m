//
//  UIHelper.m
//  YouLess
//
//  Created by Wouter van der Post on 07-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "UIHelper.h"


@implementation UIHelper

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

@end
