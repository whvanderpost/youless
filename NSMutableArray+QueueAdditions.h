//
//  NSMutableArray+QueueAdditions.h
//  YouLess
//
//  Created by Wouter van der Post on 15-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end
