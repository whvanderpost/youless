//
//  CustomUrlConnection.h
//  YouLess
//
//  Created by Wouter van der Post on 08-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomUrlConnection : NSURLConnection 
{
	@private
    NSURLResponse* _response;
    NSMutableData* _data;
    BOOL _finished;
}

- (NSURLResponse*)response;
- (void)setResponse:(NSURLResponse*)value;

- (NSData*)data;
- (void)appendData:(NSData*)value;

- (BOOL)isFinished;
- (void)setFinished:(BOOL)value;

@end
