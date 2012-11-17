//
//  Authentication.h
//  YouLess
//
//  Created by Wouter van der Post on 10-08-12.
//
//

#import <Foundation/Foundation.h>

@interface Authentication : NSObject
{
}

@property (nonatomic, retain) NSTimer* _timeoutTimer;

- (void)authenticate:(id)callbackTarget;

@end
