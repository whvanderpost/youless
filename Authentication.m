//
//  Authentication.m
//  YouLess
//
//  Created by Wouter van der Post on 10-08-12.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "Authentication.h"
#import "PreferencesHelper.h"
#import "MainViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@implementation Authentication

- (void)authenticate:(id)callbackTarget
{
    DLog(@"[Authentication] Authenticate, place an http call to the device.");
        
	@try
	{
		NSString* ipSetting = [[PreferencesHelper getInstance] getPreferenceForKey:@"ipAddress"];
        NSString* portNumber = [[PreferencesHelper getInstance] getPreferenceForKey:@"portNumber"];
        NSString* password = [[PreferencesHelper getInstance] getPassword];
        
        NSURLResponse *response;
        NSError *error;
        
		if (![ipSetting hasPrefix:@"http://"]) {
			ipSetting = [NSString stringWithFormat:@"http://%@", ipSetting];
		}
		NSString* queryString = [NSString stringWithFormat: @"%@:%@/l?w=%@", ipSetting, portNumber, password];
        
		NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
        
        // TODO: Find a perminent solution for this awful workaround. If this sleep isn't here, the reply will be a 403 again...
        // Could be the response/processing time of the webserver.
        [NSThread sleepForTimeInterval:0.5];
        
        [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        int responseStatusCode = [httpResponse statusCode];
        
        switch (responseStatusCode) {
            case 403:
                DLog(@"(403) Authentication failed, wrong password?");
                [callbackTarget handleUnauthenticated];
                break;
            case 200:
                DLog(@"(200) Authentication OK");
                [callbackTarget startMonitoring];
                break;
            default:
                break;
        }
	}
	@catch (NSException* ex)
	{
		ALog(@"[Authentication] Error: %@", ex);
	}
}

@end
