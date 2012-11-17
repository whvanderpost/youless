//
//  PreferencesHelper.m
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "PreferencesHelper.h"
#import "Constants.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface PreferencesHelper (Private)

- (void)loadPreferences;
- (NSString *)retrieveFromUserDefaults:(NSString *)key;
- (void) saveValueToUserDefaults:(NSString *)value forKey:(NSString *)key;

@end


@implementation PreferencesHelper

@synthesize _preferences;
@synthesize _keychainItem;

#pragma mark -

+ (PreferencesHelper *)getInstance
{
	static PreferencesHelper *instance;
	
	@synchronized(self)
	{
		if (!instance)
		{
			instance = [[PreferencesHelper alloc] init];
			[instance loadPreferences];
		}
		
		return instance;
	}
}

- (NSString*)getPassword
{
    if(!_keychainItem)
    {
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YouLess" accessGroup:nil];
    }
    
    return [_keychainItem objectForKey:kSecValueData];
}

- (void)savePassword:(NSString *)password
{
    [_keychainItem setObject:password forKey:kSecValueData];
}

- (void)savePreferences
{
	for (NSString *key in [_preferences allKeys]) 
	{
		[self saveValueToUserDefaults:[_preferences objectForKey:key] forKey:key];
	}
}

- (void)loadPreferences
{
	_preferences = [[NSMutableDictionary alloc] init];
	    
	// Try to get the IP from the preferences and set it to a default address if it could not be found.
	NSString *ipAddress = [self retrieveFromUserDefaults:@"ipAddress"];
	if(!ipAddress)
	{
		ipAddress = [PreferencesHelper getDefaultIpAddress];
	}

	[_preferences setObject:ipAddress forKey:@"ipAddress"];
	
    
	// Try to get the update interval from the preferences and set it to a default value if it could not be found.
	NSString *updateInterval = [self retrieveFromUserDefaults:@"updateInterval"];
	NSNumber *updateIntervalNumber;
	if(updateInterval)
		updateIntervalNumber = [NSNumber numberWithInt:[updateInterval intValue]];
	else
		updateIntervalNumber = [NSNumber numberWithInt:DEFAULT_UPDATE_INTERVAL];

	[_preferences setObject:updateIntervalNumber forKey:@"updateInterval"];	
    
    
    // Try to get the port number from the preferences and set it to a default value if it could not be found.
	NSString *portNumber = [self retrieveFromUserDefaults:@"portNumber"];
	NSNumber *portNumberNumber;
	if(portNumber)
		portNumberNumber = [NSNumber numberWithInt:[portNumber intValue]];
	else
		portNumberNumber = [NSNumber numberWithInt:DEFAULT_PORT_NUMBER];
	
	[_preferences setObject:portNumberNumber forKey:@"portNumber"];

	
	// Try to get the delta threshold from the preferences and set it to a default value if it could not be found.
	NSString *deltaThreshold = [self retrieveFromUserDefaults:@"deltaThreshold"];
	NSNumber *deltaThresholdNumber;
	if(deltaThreshold)
		deltaThresholdNumber = [NSNumber numberWithInt:[deltaThreshold intValue]];
	else
		deltaThresholdNumber = [NSNumber numberWithInt:DEFAULT_DELTA_THRESHOLD];
	
	[_preferences setObject:deltaThresholdNumber forKey:@"deltaThreshold"];
	
    
	// Try to get the simulator mode from the preferences and set it to a default value (NO) if it could not be found.
	NSNumber *simulator = [NSNumber numberWithInt:[[self retrieveFromUserDefaults:@"simulator"] intValue]];
	if(!simulator)
		simulator = [NSNumber numberWithInt:SIMULATOR_MODE];
	
	[_preferences setObject:simulator forKey:@"simulator"];

    
	// Try to get the Auto-lock setting from the preferences and set it to a default value (YES) if it could not be found.
	NSString *autoLockPref = [self retrieveFromUserDefaults:@"autoLock"];
	NSNumber *autoLockNumber = [NSNumber numberWithInt:[autoLockPref intValue]];
	if(!autoLockPref)
		autoLockNumber = [NSNumber numberWithInt:DEFAULT_AUTO_LOCK];
	
	[_preferences setObject:autoLockNumber forKey:@"autoLock"];
	
    
	// Try to get the first time flag from the preferences and set it to 1 (YES) if it could not be found.
    if([self retrieveFromUserDefaults:@"firstTime1_1"])
    {
		[_preferences setObject:[NSNumber numberWithInt:0] forKey:@"firstTime1_1"];
    }
	else // If the value is not present, we're running version 1.1 for the first time...
    {
		[_preferences setObject:[NSNumber numberWithInt:1] forKey:@"firstTime1_1"];
        // remove the old firstTime marker...
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"firstTime"];
        // ...and we have to remove the current setting for the update interval.
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"updateInterval"];
        [_preferences setObject:[NSNumber numberWithInt:DEFAULT_UPDATE_INTERVAL] forKey:@"updateInterval"];
    }
}

- (id)getPreferenceForKey:(NSString *)key
{
	if([[_preferences allKeys] containsObject:key])
		return [_preferences objectForKey:key];

	return nil;
}

- (void)setPreferenceValue:(NSString *)value forKey:(NSString *)key 
{
	[_preferences setObject:value forKey:key];
}

- (void)saveValueToUserDefaults:(NSString *)value forKey:(NSString *)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	
	if (standardUserDefaults) 
	{
		[standardUserDefaults setObject:value forKey:key];
		[standardUserDefaults synchronize];
	}
}

- (NSString *)retrieveFromUserDefaults:(NSString *)key
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString *val = nil;
	
	if (standardUserDefaults) 
		val = [standardUserDefaults objectForKey:key];
	
	return val;
}

- (void)dealloc
{
	[_preferences release];
    [_keychainItem release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Helpers

// Try to get the IP from the preferences and set it to a default fallback address if it could not be found.
+ (NSString *)getDefaultIpAddress
{
	NSString *ipAddress = [PreferencesHelper getIpFromNetworkInterface:ios_wifi ipVersion:4];
	if(ipAddress)
	{
		NSMutableArray *ipSegmented = [NSMutableArray arrayWithArray:[ipAddress componentsSeparatedByString:@"."]];
		[ipSegmented replaceObjectAtIndex:[ipSegmented count] - 1 withObject:DEFAULT_IP_SUFFIX];
		ipAddress = [ipSegmented componentsJoinedByString:@"."];
	}
	else
	{
		ipAddress = DEFAULT_IP_ADDRESS;
	}
	
	return ipAddress;
}

+ (BOOL)isStringNumeric:(NSString *)value
{
	NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithRange:NSMakeRange('0',10)] invertedSet];
	NSString *trimmed = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	BOOL isNumeric = trimmed.length > 0 && [trimmed rangeOfCharacterFromSet:nonNumberSet].location == NSNotFound;

	return isNumeric;
}

// Use to get the IPv6 or v4 address if found, nil otherwise
+ (NSString *)getIpFromNetworkInterface:(InterfaceType)interface ipVersion:(int)ipVersion
{
 	if(ipVersion != 4 && ipVersion != 6)
	{
 		ALog(@"getIpFromNetworkInterface unknown version of IP: %i", ipVersion);
 		return nil;
	}
	
 	NSString *networkInterfaceRef = nil;
	
	if(interface == ios_cellular)
	{
		networkInterfaceRef = @"pdp_ip0";
	}
	else if(interface == ios_wifi)
	{
		networkInterfaceRef = @"en0"; //en1 on simulator if mac on wifi
	}
	
 	NSString *address = nil;
 	struct ifaddrs *interfaces = NULL;
 	struct ifaddrs *temp_addr = NULL;
 	struct sockaddr_in *s4;
 	struct sockaddr_in6 *s6;
 	char buf[64];
 	int success = 0;
	
	// retrieve the current interfaces - returns 0 on success
 	success = getifaddrs(&interfaces);
	
 	if(success == 0)
	{
		// Loop through linked list of interfaces
 		temp_addr = interfaces;
		
 		while(temp_addr != NULL)
		{
 			if((ipVersion == 4 && temp_addr->ifa_addr->sa_family == AF_INET) ||
 			   (ipVersion == 6 && temp_addr->ifa_addr->sa_family == AF_INET6))
			{
 				DLog(@"Network Interface: %@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
				
				// Check if interface is en0 which is the wifi connection on the iPhone
 				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:networkInterfaceRef])
				{
 					if(ipVersion == 4)
					{
 						s4 = (struct sockaddr_in *)temp_addr->ifa_addr;
						
 						if(inet_ntop(temp_addr->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL)
						{
 							DLog(@"%s: inet_ntop failed for v4!\n",temp_addr->ifa_name);
						}
 						else
						{
 							address = [NSString stringWithUTF8String:buf];
							// The address is found, so no need to loop through the other interfaces.
							break;
 						}
					}
 					if(ipVersion == 6)
					{
 						s6 = (struct sockaddr_in6 *)(temp_addr->ifa_addr);
						
 						if(inet_ntop(temp_addr->ifa_addr->sa_family, (void *)&(s6->sin6_addr), buf, sizeof(buf)) == NULL)
						{
 							ALog(@"%s: inet_ntop failed for v6!\n",temp_addr->ifa_name);
						}
 						else
						{
 							address = [NSString stringWithUTF8String:buf];
							// The address is found, so no need to loop through the other interfaces.
							break;
 						}
					}
				}
			}
			
 			temp_addr = temp_addr->ifa_next;
		}
	}
	
	// Free memory
 	freeifaddrs(interfaces);
 	return address;
}

#pragma mark -

@end
