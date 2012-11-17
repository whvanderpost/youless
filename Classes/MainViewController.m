//
//  MainViewController.m
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

/*
 The images used for the gauge (4 colors) and the needle are based on the 
 images supplied by Apple in the Dashcode template "The Gauge Template". 
 The included Apple disclaimer below applies to these images.
 
 --- ORIGINAL APPLE DISCLAIMER ---
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 */


#include <stdlib.h>

#import "MainViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "PreferencesHelper.h"
#import "Constants.h"
#import "CustomUrlConnection.h"
#import <QuartzCore/QuartzCore.h>
#import "NSMutableArray+QueueAdditions.h"
#import "Reachability.h"
#import "UIHelper.h"
#import "Authentication.h"


@interface MainViewController (Private)

- (void)stopMonitoring;
- (void)startMonitoring;
- (void)timerTick:(NSTimer* ) theTimer;
- (BOOL)initializeApp;
- (void)simulateData;
- (void)refreshData;
- (void)updateInterfaceWithReachability:(Reachability *)curReach forceRefresh:(BOOL)appStartup;
- (void)reachabilityChanged: (NSNotification* )note;

- (void)connection:(CustomUrlConnection *)connection didFailLoadWithError:(NSError *)error;
- (void)connection:(CustomUrlConnection *)connection didReceiveResponse:(NSURLResponse *) response;
- (void)connection:(CustomUrlConnection *)connection didReceiveData:(NSData *) data;
- (void)connectionDidFinishLoading:(CustomUrlConnection *)connection;

- (void)setGaugeImage:(NSString *)imageName hiddenGauge:(UIImageView *)hiddenGauge visibleGauge:(UIImageView*)visibleGauge duration:(double)duration;
- (void)setGaugeValue:(int)wattValue duration:(double)duration;
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;

- (void)reset :(BOOL)resetDeltaLabels :(BOOL)resetWattValue;
- (void)updateDeltaLabels: (NSNumber *)newValue;
- (UIView *)getNewDeltaLabelWithValue:(NSNumber *)value;

@end




@implementation MainViewController (Private)

#pragma mark Monitoring

- (void)stopMonitoring
{
    DLog(@"Stop monitoring, cleaning everything up.");
    
	[self._timer invalidate];
    self._timer = nil;
	[self._timeoutTimer invalidate];
    self._timeoutTimer = nil;
	[self reset :YES :YES];
    if(_conn)
    {
        [_conn cancel];
        [_conn release];
        _conn = nil;
    }
}

- (void)startMonitoring
{
    DLog(@"Start monitoring, setting up timer.");
    
    [_spinner startAnimating];
    if(!self._timer)
    {
        // Set the interval of the timer to the animation duration + 10% to allow the 
        // startup animation (set gauge to 0) to finish properly.
        self._timer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration * 1.1
                                                      target:self 
                                                    selector:@selector(firstTimerTick:) 
                                                    userInfo:nil 
                                                     repeats:NO];
    }
}

- (void)firstTimerTick:(NSTimer *) theTimer
{
    [self timerTick:theTimer];
    
    [self._timer invalidate];
    self._timer = nil;
    
    self._timer = [NSTimer scheduledTimerWithTimeInterval:_updateInterval 
                                                  target:self 
                                                selector:@selector(timerTick:) 
                                                userInfo:nil 
                                                 repeats:YES];
}

- (void)handleTimeout:(NSTimer *) theTimer 
{
    DLog(@"Timeout occured, stopping all engines.");
    
	[self stopMonitoring];
	[_spinner stopAnimating];
    [self setErrorState:YES];
    
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"IpTimeout", nil),
						 [[PreferencesHelper getInstance] getPreferenceForKey:@"ipAddress"],
                         [[PreferencesHelper getInstance] getPreferenceForKey:@"portNumber"]];
	[UIHelper showAlertWithText:message withTitle:NSLocalizedString(@"ErrorTitle", nil)];
	
    [self._timeoutTimer invalidate];
}

- (void)timerTick:(NSTimer *) theTimer 
{
    DLog(@"Timer tick, either simulate or request data from the device.");
    
    BOOL simulate = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
    
    if(_isInError && !simulate)
    {
        return;
    }
    
	if(simulate)
		[self simulateData];
	else
		[self refreshData];
}

- (BOOL)initializeApp
{
	PreferencesHelper *preferencesHelper = [PreferencesHelper getInstance];
	NSNumber *firstTime = [preferencesHelper getPreferenceForKey:@"firstTime1_1"];
		
	// Set the Auto-lock setting to allow/prevent the iDevice to go to sleep.
	BOOL autoLock = [[[PreferencesHelper getInstance] getPreferenceForKey:@"autoLock"] boolValue];
	[UIApplication sharedApplication].idleTimerDisabled = autoLock;
	
	// Get the update interval from the user preferences.
    _updateInterval = [[preferencesHelper getPreferenceForKey:@"updateInterval"] doubleValue] / 1000;
	
	// Check if the update interval is less than the default animation duration.
	// The animations won't have time to finish properly if the interval is shorter.
	_animationDuration = ANIMATION_DURATION;
	if(_updateInterval < ANIMATION_DURATION)
	{
		_animationDuration = _updateInterval - 0.1;
	}
	
	if([firstTime intValue] == 1)
	{
		[self reset:YES :YES];
		[UIHelper showAlertWithText:NSLocalizedString(@"FirstTime", nil) withTitle:NSLocalizedString(@"InfoTitle", nil)];
		return NO;
	}
	
	BOOL simulate = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
	
	// If the simulator was enabled, reset to make sure old values are cleared and the gauge is at 0.
	if(_simulatorMode != simulate)
		[self reset:YES :YES];
	else
		[self reset:NO :NO];
	
	// Set the App title based on the simulator setting.
	if(simulate)
	{
		_navigationBar.title = NSLocalizedString(@"AppTitleSim", nil);
		return YES;
	}
	else
	{
		_navigationBar.title = NSLocalizedString(@"AppTitle", nil);
	}
	
	return YES;
}

- (void)simulateData
{
	[_spinner stopAnimating];
	
	if(_previousWattValue <= 0)
	{
		_simulateUp = YES;
	}
	else if(_previousWattValue >= MAX_GAUGE)
	{
		_simulateUp = NO;
	}
	
	// Get a random number between -25 and 75 or -75 and 25 if the max has been reached.
	int nextValue = _previousWattValue;
	if(_simulateUp)
	{
		nextValue += -25 + random() % 100;
	}
	else 
	{
		nextValue += -75 + random() % 100;
	}
	
	if(nextValue != _previousWattValue || _forceGaugeUpdate)
	{
		_forceGaugeUpdate = NO;
		int threshold = [((NSNumber *)[[PreferencesHelper getInstance] getPreferenceForKey:@"deltaThreshold"]) intValue];
		
		// Only add a delta label if the delta is greater than the threshold.
		if(fabs(nextValue - _previousWattValue) > threshold)
		{
			[self performSelectorOnMainThread: @selector(updateDeltaLabels:) 
								   withObject:[NSNumber numberWithInt:(nextValue - _previousWattValue)] waitUntilDone:NO];
		}
		_previousWattValue = nextValue;
        [self setGaugeValue:nextValue duration:_animationDuration];
	}
}

- (void)refreshData
{
    DLog(@"Refresh data, place a new http call to the device.");
    
    // If a connection/call is active, don't place another call.
    if(_conn)
    {
        DLog(@"Call pending, not creating a new one.");
        return;
    }
    
	@try 
	{
		NSString* ipSetting = [[PreferencesHelper getInstance] getPreferenceForKey:@"ipAddress"];
        NSString* portNumber = [[PreferencesHelper getInstance] getPreferenceForKey:@"portNumber"];
        
		if (![ipSetting hasPrefix:@"http://"]) {
			ipSetting = [NSString stringWithFormat:@"http://%@", ipSetting];
		}
        NSString *queryString = [NSString stringWithFormat: @"%@:%@/a?f=j", ipSetting, portNumber];
		
		NSURL *url = [NSURL URLWithString:queryString];
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
		[req setHTTPMethod:@"GET"];
        _conn = [[CustomUrlConnection alloc] initWithRequest:req delegate:self];
        
		if(!self._timeoutTimer)
		{
			self._timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:18
																 target:self
															   selector:@selector(handleTimeout:) 
															   userInfo:nil 
																repeats:NO];
		}
	}
	@catch (NSException * ex) 
	{
		ALog(@"Error: %@", ex);
	}
}

- (void)setErrorState:(BOOL)inError
{
    if(inError)
    {
        _errorLabel.hidden = NO;	
        _isInError = YES;   
        _navigationBar.leftBarButtonItem = _refreshButton;
    }
    else 
    {
        _errorLabel.hidden = YES;
        _isInError = NO;
        _navigationBar.leftBarButtonItem = nil;
        _refreshButton.enabled = YES;
    }
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach forceRefresh:(BOOL)refresh
{
	if(curReach == _internetReach)
	{
        BOOL simulating = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
        
        if(refresh || simulating)
        {
            [self setErrorState:NO];
            
            if([self initializeApp])
            {
                [self startMonitoring];
            }
            
            return;
        }
        
		NetworkStatus netStatus = [curReach currentReachabilityStatus];
		
        if (netStatus == NotReachable)
        {
            [self setErrorState:YES];
            [self stopMonitoring];
            return;    
        }
        else
        {
            [self setErrorState:NO];
            if([self initializeApp])
            {
                _forceGaugeUpdate = YES;
                [self startMonitoring];
            }
        }
	}	
}

//Called by Reachability whenever status changes.
- (void)reachabilityChanged: (NSNotification* )note
{
    DLog(@"Reachability changed, call an update function to process this change.");
    
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability:curReach forceRefresh:NO];
}

#pragma mark -
#pragma mark URLConnectionDelegate

- (void)connection:(CustomUrlConnection *)connection didFailLoadWithError:(NSError *)error 
{
    DLog(@"Connection error occured.");
    
	[self._timeoutTimer invalidate];
	[_spinner stopAnimating];
	
	NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ConnectionError", nil), [error description]];
	[UIHelper showAlertWithText:message withTitle:NSLocalizedString(@"ErrorTitle", nil)];
    
    [_conn release];
    _conn = nil;
}

- (void)connection:(CustomUrlConnection *) connection didReceiveResponse:(NSURLResponse *) response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse *)response;
    int responseStatusCode = [httpResponse statusCode];

    if(responseStatusCode == 403)
    {
        [self stopMonitoring];
        
        _authentication = [Authentication alloc];
        [_authentication authenticate:self];
    }
    
	[connection setResponse:response];
}

- (void)connection:(CustomUrlConnection *) connection didReceiveData:(NSData *) data
{
	[connection appendData:data];
}

- (void)connectionDidFinishLoading:(CustomUrlConnection *) connection
{
	[self._timeoutTimer invalidate];
	self._timeoutTimer = nil;
	
    if([connection isFinished])
    {
        return;
    }
    
	[connection setFinished:YES];
	[_spinner stopAnimating];
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[connection data] options:kNilOptions error:&error];
    
    // Bail out if the result is not what we expect.
    if(!json || ![json isKindOfClass:[NSDictionary class]] || error != nil ||
       [json objectForKey:@"pwr"] == nil || [json objectForKey:@"cnt"] == nil)
    {
        [self stopMonitoring];
        
        // Only show the error message if we're not in error state yet.
        if(!_isInError)
        {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"InvalidResult", nil),
                                 [[PreferencesHelper getInstance] getPreferenceForKey:@"ipAddress"]];
            [UIHelper showAlertWithText:message withTitle:NSLocalizedString(@"ErrorTitle", nil)];
        }
        
        [self setErrorState:YES];
		return;
    }
    
    // Get the watt and kWh values from the JSON result data.
    int wattInt = [[json objectForKey:@"pwr"] intValue];
    NSString *kWhValue = [json objectForKey:@"cnt"];
    
    [self setErrorState:NO];
	
	// Make the LED flash if the kWh value has changed, this confirms a powermeter reading to the user.
	if(![kWhValue isEqualToString:self._previousKWhValue])
	{
		[_ledView flash];
		self._previousKWhValue = [NSString stringWithString:kWhValue];
	}
	
	// Only act if the value has actually changed.
	if(wattInt != _previousWattValue || _forceGaugeUpdate)
	{
		_forceGaugeUpdate = NO;
		int threshold = [((NSNumber *)[[PreferencesHelper getInstance] getPreferenceForKey:@"deltaThreshold"]) intValue];
		
		// Only add a delta label after the initial startup value change and if the delta is greater than the threshold.
		if(_previousWattValue != 0 && fabs(wattInt - _previousWattValue) > threshold)
		{
			[self performSelectorOnMainThread: @selector(updateDeltaLabels:)
								   withObject:[NSNumber numberWithInt:(wattInt - _previousWattValue)] waitUntilDone:NO];
		}
		_previousWattValue = wattInt;
        [self setGaugeValue:wattInt duration:_animationDuration];
	}
    
    [_conn release];
    _conn = nil;
}

#pragma mark -
#pragma mark Gauge

- (void)setGaugeImage:(NSString *)imageName hiddenGauge:(UIImageView *)hiddenGauge visibleGauge:(UIImageView*)visibleGauge duration:(double)duration
{
    // Only change the gauge background if needed
    if([visibleGauge image] != [UIImage imageNamed: imageName])
    {
        [hiddenGauge setImage:[UIImage imageNamed: imageName]];
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             hiddenGauge.alpha = 1.0;
                         }
                         completion:^(BOOL finished) { }];
         [UIView animateWithDuration:duration
                               delay:duration / 2
                             options:UIViewAnimationCurveEaseInOut
                          animations:^{
                              visibleGauge.alpha = 0.0;
                          }
                          completion:^(BOOL finished) { }];
        
        [UIView commitAnimations];
    }
}

- (void)setGaugeValue:(int)wattValue duration:(double)duration
{
    UIImageView *hiddenGauge;
    UIImageView *visibleGauge;
    int max = 0;
    
    if(_gauge.alpha == 0)
    {
        hiddenGauge = _gauge;
        visibleGauge = _gauge2;
    }
    else
    {
        hiddenGauge = _gauge2;
        visibleGauge = _gauge;
    }	
	
	// Set the background image to the right color.
	if(wattValue <= 0)
	{
		max = 100;
		wattValue = 0;
        [self setGaugeImage:@"gauge_off.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
		//if([visibleGauge image] != [UIImage imageNamed: @"gauge_off.png"])
		//	[_gauge setImage:[UIImage imageNamed: @"gauge_off.png"]];
	}
	else if(wattValue <= 600)
	{
		max = 600;
        [self setGaugeImage:@"gauge_green.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([visibleGauge image] != [UIImage imageNamed: @"gauge_green.png"])
//        {
//            [hiddenGauge setImage:[UIImage imageNamed: @"gauge_green.png"]];
//            [UIView beginAnimations:@"Fade" context:nil];
//            [UIView setAnimationDuration:duration];
//            [UIView setAnimationDelay:0.0];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//            
//            hiddenGauge.alpha = 1.0;
//            visibleGauge.alpha = 0.0;
//            
//            [UIView commitAnimations];
//            
//			//[_gauge setImage:[UIImage imageNamed: @"gauge_green.png"]];
//        }
	}
	else if(wattValue > 600 && wattValue <= 1500)
	{
		max = 1500;
        [self setGaugeImage:@"gauge_yellow.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([_gauge image] != [UIImage imageNamed: @"gauge_yellow.png"])
//			[_gauge setImage:[UIImage imageNamed: @"gauge_yellow.png"]];
	}
	else if(wattValue > 1500 && wattValue <= 3000)
	{
		max = 3000;
        [self setGaugeImage:@"gauge_orange.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([_gauge image] != [UIImage imageNamed: @"gauge_orange.png"])
//			[_gauge setImage:[UIImage imageNamed: @"gauge_orange.png"]];
	}
	else if(wattValue > 3000 && wattValue <= 6000)
	{
		max = 6000;
        [self setGaugeImage:@"gauge_red.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([_gauge image] != [UIImage imageNamed: @"gauge_red.png"])
//			[_gauge setImage:[UIImage imageNamed: @"gauge_red.png"]];
	}
    else if(wattValue > 6000 && wattValue <= MAX_GAUGE)
	{
		max = MAX_GAUGE;
        [self setGaugeImage:@"gauge_tilt.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([_gauge image] != [UIImage imageNamed: @"gauge_tilt.png"])
//			[_gauge setImage:[UIImage imageNamed: @"gauge_tilt.png"]];
	}
	else
	{
		max = MAX_GAUGE;
		wattValue = MAX_GAUGE;
        [self setGaugeImage:@"gauge_tilt.png" hiddenGauge:hiddenGauge visibleGauge:visibleGauge duration:duration];
//		if([_gauge image] != [UIImage imageNamed: @"gauge_tilt.png"])
//			[_gauge setImage:[UIImage imageNamed: @"gauge_tilt.png"]];
	}
	
	// Set the text of the label that indicates the current Watt value.
	_wattValue.text = [NSString stringWithFormat:@"%d", wattValue];
    
	// Set the text of the labels that indicate the max and middle value.
	_maxValue.text = [NSString stringWithFormat:@"%d", max];
	_middleValue.text = [NSString stringWithFormat:@"%d", max / 2];
	
	// Calculate the position of the needle in degrees.
	float degrees = degreesToRadians(((wattValue * 270) / max) - 135.0);
	
	// Animate the needle to the new position, using the previous position as the starting point.
	CALayer *layer = _gaugeNeedle.layer;
	CAKeyframeAnimation *animation;
	
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.delegate = self;
	
	animation.duration = duration;
	animation.cumulative = YES;
	animation.repeatCount = 1;
	animation.values = [NSArray arrayWithObjects:           // i.e., Rotation values for the 3 keyframes, in RADIANS
						[NSNumber numberWithFloat:_previousDegreesValue], 
						[NSNumber numberWithFloat:(_previousDegreesValue - ((_previousDegreesValue - degrees) / 2.0))], 
						[NSNumber numberWithFloat:degrees],
						nil]; 
	animation.keyTimes = [NSArray arrayWithObjects:     // Relative timing values for the 3 keyframes
						  [NSNumber numberWithFloat:0], 
						  [NSNumber numberWithFloat:.5], 
						  [NSNumber numberWithFloat:1.0],
						  nil]; 
	animation.timingFunctions = [NSArray arrayWithObjects:
								 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],						// from keyframe 1 to keyframe 2
								 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
								 nil]; // from keyframe 2 to keyframe 3
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	
	[layer addAnimation:animation forKey:nil];
	
	// Save the new position for future use.
	_previousDegreesValue = degrees;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag 
{
	// Get the keyframes that where used to animate (this animation uses 3 keyframes)
	NSArray *animationValues = ((CAKeyframeAnimation *)theAnimation).values;
	// The last keyframe contains the end position
	NSNumber *endDegrees = [animationValues objectAtIndex:2];
	
	// Rotate the gaugeNeedle to the same value as the animations endpoint
	_gaugeNeedle.transform = CGAffineTransformMakeRotation([endDegrees floatValue]);
	
	// Remove all animations from the layer, this will release the array's/numbers used for the keyframes
	[[_gaugeNeedle layer] removeAllAnimations];
}

#pragma mark -
#pragma mark DeltaLabels

- (void)reset :(BOOL)resetDeltaLabels :(BOOL)resetWattValue
{
	if(resetDeltaLabels && [_deltaLabels count] > 0)
	{
        [UIView animateWithDuration:0.5
                              delay:1.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
                             for (int i = [_deltaLabels count] - 1; i >= 0; i--)
                             {
                                 UIView *current = [_deltaLabels objectAtIndex:i];
                                 current.alpha = 0.0;
                             }
                         }
                         completion:^(BOOL finished) { }
         ];
        
//		[UIView beginAnimations:@"Fade" context:nil];
//		[UIView setAnimationDuration:0.5];
//		[UIView setAnimationDelay:1.0];
//		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//		
//		for (int i = [_deltaLabels count] - 1; i >= 0; i--) 
//		{
//			UIView *current = [_deltaLabels objectAtIndex:i];
//			current.alpha = 0.0;
//		}
		
		[UIView commitAnimations];
	}
	
	// Set the needle to the 0-position.
	[self setGaugeValue:0 duration:_animationDuration];
	
	if(resetWattValue)
		_previousWattValue = 0;
}

- (void)updateDeltaLabels: (NSNumber *)newValue 
{
	// Do nothing if we don't want delta labels.
	if(NUMBER_OF_DELTA_LABELS == 0)
		return;
	
	double deltaAnimationDuration = _animationDuration;
	if(deltaAnimationDuration > 1.0)
		deltaAnimationDuration = 1.0;
	
	// Take out the garbage.
	if(_garbageDeltaLabel)
	{
		[_garbageDeltaLabel removeFromSuperview];
	}
	
    [UIView animateWithDuration:deltaAnimationDuration
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         float alphaKey = (1.0 / NUMBER_OF_DELTA_LABELS);
                         
                         // Move all labels one position upwards.
                         for (int i = [_deltaLabels count] - 1; i >= 0; i--)
                         {
                             UIView *current = [_deltaLabels objectAtIndex:i];
                             
                             CGPoint newPoint = CGPointMake(current.layer.position.x, current.layer.position.y - current.bounds.size.height);
                             current.layer.position = newPoint;
                             
                             // Make sure the item that gets faded out to 0 (after this block) is left alone.
                             if(i > 0 || [_deltaLabels count] < NUMBER_OF_DELTA_LABELS)
                             {
                                 current.alpha = (current.alpha - alphaKey);
                             }
                         }
                         
                         // Add the new label to the queue.
                         UIView *newDeltaLabel = [self getNewDeltaLabelWithValue :newValue];
                         newDeltaLabel.alpha = 1.0;
                         newDeltaLabel.layer.zPosition = 99;
                         [_deltaLabels enqueue:newDeltaLabel];
                         [_deltaLabelsView addSubview:newDeltaLabel];
                         
                         // Pop a label if the queue contains the maximum number of labels.
                         // In the next cycle the dequeue'd label will be disposed.
                         if([_deltaLabels count] == NUMBER_OF_DELTA_LABELS + 1)
                         {
                             _garbageDeltaLabel = [_deltaLabels dequeue];
                             _garbageDeltaLabel.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) { }
     ];
    
//	[UIView beginAnimations:@"FadeAndMove" context:nil];
//	[UIView setAnimationDuration:deltaAnimationDuration];
//	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//  [UIView setAnimationDidStopSelector:@selector(release)];
	
	[UIView commitAnimations];
}

- (UIView *)getNewDeltaLabelWithValue:(NSNumber *)value 
{
	float viewWidth = 200.0;
	float viewHeight = 35.0;
	float arrowWidth = 21.0;
	float arrowHeight = 26.0;
	float arrowMargin = 40.0;
	float labelHeight = 35.0;
	float labelWidth = 80.0;
	CGRect viewRect = [_deltaLabelsView bounds];
	
	UIView *newView = [[[UIView alloc] 
						initWithFrame:CGRectMake((viewRect.size.width / 2) - (viewWidth / 2),
												 viewRect.size.height - (viewHeight), 
												 viewWidth, 
												 viewHeight)] autorelease];
	newView.alpha = 0.0; // Start invisible, so we can fade in.
	newView.backgroundColor = [UIColor clearColor];
	
	UIImageView *arrow = [[[UIImageView alloc] 
						   initWithFrame:CGRectMake((viewWidth / 2) - (arrowWidth / 2) - arrowMargin,
													(viewHeight / 2) - (arrowHeight / 2), 
													arrowWidth, 
													arrowHeight)] autorelease];
	arrow.contentMode = UIViewContentModeScaleAspectFit;
	
	// Calculate the x and y position based on the viewsize.
	UILabel *valueLabel = [[[UILabel alloc] 
							initWithFrame:CGRectMake((viewWidth / 2) - (labelWidth / 2), 
													 (viewHeight / 2) - (labelHeight / 2), 
													 labelWidth, 
													 labelHeight)] autorelease];
	int absoluteValue = fabs([value doubleValue]);
	valueLabel.text = [NSString stringWithFormat:@"%d", absoluteValue];
	valueLabel.textAlignment = UITextAlignmentRight;
	valueLabel.backgroundColor = [UIColor clearColor];
	valueLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25.0];
	
	if([value intValue] < 0)
	{
		valueLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
		arrow.image = [UIImage imageNamed:@"DownArrow.png"];
	}
	else
	{
		valueLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
		arrow.image = [UIImage imageNamed:@"UpArrow.png"];
	}
	
	[newView addSubview:valueLabel];
	[newView addSubview:arrow];
	return newView;
}

#pragma mark -

@end

@implementation MainViewController

@synthesize _refreshButton;
@synthesize _settingsButton;
@synthesize _wattValue;
@synthesize _wattLabel;
@synthesize _maxValue;
@synthesize _middleValue;
@synthesize _gauge;
@synthesize _gauge2;
@synthesize _gaugeNeedle;
@synthesize _deltaLabelsView;
@synthesize _navigationBar;
@synthesize _errorLabel;
@synthesize _spinner;
@synthesize _ledView;
@synthesize _previousKWhValue;
@synthesize _timer;
@synthesize _timeoutTimer;


#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"View disappeared, kill all timers and the connection.");
    
    // Store the current simulating mode (used to determine if the delta labels should be cleared)
	_simulatorMode = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
	
	[self reset:NO :NO];
	
	// Invalidate the timer to stop updating the view that is no longer visible.
	[self._timer invalidate];
	self._timer = nil;
	
	// Also invalidate the timeout timer, all the timers will be restarted after the settings/about screen has been closed.
	[self._timeoutTimer invalidate];
	self._timeoutTimer = nil;
    
    // Make sure any pending call is cancelled and released.
    if(_conn)
    {
        [_conn cancel];
        [_conn release];
        _conn = nil;
    }
    
	[_spinner stopAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"View appeared, starting again if not in error or simulating.");
    
    [super viewDidAppear:animated];
    
    BOOL simulate = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
    
    if(!_isInError || simulate)
    {
        _forceGaugeUpdate = YES;
        
        [self updateInterfaceWithReachability:_internetReach forceRefresh:YES];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    DLog(@"View loaded, initialize UI and notifications.");
    
	[super viewDidLoad];
	
	_deltaLabels = [[NSMutableArray alloc] init];
	
	// Offset the center of the needle to make the rotation work.
	// The rotation point in the image is located at 83.9% of the image height.
	//_gaugeNeedle.layer.anchorPoint = CGPointMake(0.5, 0.839);
    _gaugeNeedle.layer.anchorPoint = CGPointMake(0.5, 1.0);
	
	// Moving the anchorPoint also changes the position, the center is moved to compensate for that.
	//CGFloat centerY = _gaugeNeedle.center.y + ((_gaugeNeedle.bounds.size.height * 0.839) - (_gaugeNeedle.bounds.size.height / 2));
    CGFloat centerY = _gaugeNeedle.center.y + (_gaugeNeedle.bounds.size.height - (_gaugeNeedle.bounds.size.height / 2));
	_gaugeNeedle.center = CGPointMake(_gaugeNeedle.center.x, centerY);
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
	// method "reachabilityChanged" will be called.
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
	
    _wattLabel.text = NSLocalizedString(@"WattLabel", nil);
    _errorLabel.text = NSLocalizedString(@"ErrorLabel", nil);
    _settingsButton.title = NSLocalizedString(@"SettingsTitle", nil);
    
    _internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[_internetReach startNotifier];
    
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefreshButtonPressed)];
}

- (void)viewDidUnload
{
    DLog(@"View unloaded, clean up variables.");
    
	// Release any retained subviews of the main view.
    self._wattValue = nil;
    self._wattLabel = nil;
	self._maxValue = nil;
	self._middleValue = nil;
	self._gauge = nil;
    self._gauge2 = nil;
	self._gaugeNeedle = nil;
	self._deltaLabelsView = nil;
	self._spinner = nil;
	self._ledView = nil;
    self._errorLabel = nil;
    self._navigationBar = nil;
    
	self._timer = nil;
	self._timeoutTimer = nil;
	self._previousKWhValue = nil;
    self._refreshButton = nil;
    self._settingsButton = nil;
    
    _conn = nil;
    
    [super viewDidUnload];
}

- (void)dealloc
{
    DLog(@"Dealloc called, release variables.");
    
    // outlets
    [_wattValue release];
    [_wattLabel release];
	[_maxValue release];
	[_middleValue release];
	[_gauge release];
    [_gauge2 release];
	[_gaugeNeedle release];
	[_deltaLabelsView release];
	[_spinner release];
	[_ledView release];
    [_errorLabel release];
    [_navigationBar release];
    
    [_internetReach release];
    
    [_refreshButton release];
    [_settingsButton release];
    [_previousKWhValue release];
	[_timeoutTimer release];
   	[_timer release];
	
	[_deltaLabels release];
	
    [_conn release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)onRefreshButtonPressed
{
    DLog(@"Refresh requested.");
    
    _refreshButton.enabled = NO;
    [self updateInterfaceWithReachability:_internetReach forceRefresh:YES];
}

#pragma mark -
#pragma mark Settings View Lifecycle

- (IBAction)showSettings:(id)sender
{
    _isInError = NO;
    
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
    controller.navigationItem.title = NSLocalizedString(@"SettingsTitle", nil);
    
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
    
    [navController release];
	[controller release];
}

#pragma mark Flipside View Lifecycle

- (IBAction)showInfo:(id)sender
{
    AboutViewController *controller = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
	
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

#pragma mark -

- (void)handleUnauthenticated
{
    DLog(@"Authentication error, stopping all engines.");
    
	[self stopMonitoring];
	[_spinner stopAnimating];
    [self setErrorState:YES];
    
	[UIHelper showAlertWithText:NSLocalizedString(@"AuthenticationError", nil) withTitle:NSLocalizedString(@"ErrorTitle", nil)];
    
    [self._timeoutTimer invalidate];
}

@end