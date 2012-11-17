//
//  YouLessAppDelegate.h
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface YouLessAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

