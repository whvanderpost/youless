//
//  Common.m
//  YouLess
//
//  Created by Wouter van der Post on 27-06-13.
//
//

#import "Common.h"

@implementation Common

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
