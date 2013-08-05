//
//  Constants.m
//  YouLess
//
//  Created by Wouter van der Post on 10-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "Constants.h"

NSString* const DEFAULT_IP_ADDRESS = @"192.168.0.14";	// fallback IP address
NSString* const DEFAULT_IP_SUFFIX = @"14";
int const DEFAULT_PORT_NUMBER = 80;                     // port number
int const DEFAULT_UPDATE_INTERVAL = 500;				// milliseconds
int const DEFAULT_DELTA_THRESHOLD = 5;					// watt
int const DEFAULT_AUTO_LOCK = 1;						// 1 = Prevent Standby of iDevice, 0 = Allow Standby
float const ANIMATION_DURATION = 0.6;					// seconds
int const NUMBER_OF_DELTA_LABELS = 3;
int const NUMBER_OF_DELTA_LABELS_568h = 4;
int const SIMULATOR_MODE = 0;							// 0 = NO, 1 = YES
int const MAX_GAUGE = 24000;                            // Watt