//
//  CustomUrlConnection.m
//  YouLess
//
//  Created by Wouter van der Post on 08-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "CustomUrlConnection.h"


@implementation CustomUrlConnection

- (void)dealloc 
{
    [_response release];
    [_data release];
    [super dealloc];
}

- (NSURLResponse *)response 
{
    return _response;
}

- (void)setResponse:(NSURLResponse *)value 
{
    if (_response != value) 
	{
        [_response release];
        _response = [value retain];
    }
}

- (NSData *)data 
{
    return _data;
}

- (void)appendData:(NSData *)value 
{
    if (!_data) 
	{
        _data = [[NSMutableData alloc] init];
    }
    [_data appendData:value];
}

- (BOOL)isFinished 
{
    return _finished;
}

- (void)setFinished:(BOOL)value 
{
    _finished = value;
}

@end
