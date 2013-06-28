//
//  main.m
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouLessAppDelegate.h"

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    // OLD
    //int retVal = UIApplicationMain(argc, argv, nil, nil);
    
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([YouLessAppDelegate class]));
    
    [pool release];
    
    return retVal;
}
