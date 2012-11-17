//
//  LedView.m
//
//  Created by Wouter van der Post on 06-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "LedView.h"

@interface LedView (Private)

- (void)timerTick:(NSTimer *) theTimer;

@end


@implementation LedView

@synthesize _ledImage, _timer;

- (void)flash
{
	[_ledImage setImage:[UIImage imageNamed: @"led_on.png"]];
	
	self._timer = [NSTimer scheduledTimerWithTimeInterval:0.2 
												  target:self 
												selector:@selector(timerTick:) 
												userInfo:nil 
												 repeats:NO];
}

- (void)dealloc 
{	
	[_timer release];
	[_ledImage release];
	
	[super dealloc];
}	

@end

@implementation LedView (Private)

- (void)timerTick:(NSTimer *) theTimer 
{
	[_ledImage setImage:[UIImage imageNamed: @"led_off.png"]];
	[self._timer invalidate];
	self._timer = nil;
}

@end