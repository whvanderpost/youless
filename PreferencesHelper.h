//
//  PreferencesHelper.h
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "KeychainItemWrapper.h"

typedef enum { ios_cellular, ios_wifi } InterfaceType;

@interface PreferencesHelper : NSObject 
{
	NSMutableDictionary* _preferences;
    KeychainItemWrapper* _keychainItem;
}

@property (nonatomic, retain) NSMutableDictionary* _preferences;
@property (nonatomic, retain) KeychainItemWrapper* _keychainItem;


// Use to get a reference to the PreferenceHelper singleton class.
+ (PreferencesHelper *)getInstance;

// Use to get the saved password from the keychain.
- (NSString*)getPassword;

// Use to store the given password in the keychain.
- (void)savePassword:(NSString *)password;

// Use to get the saved preference for the given key.
- (id)getPreferenceForKey:(NSString *)key;

// Use to store the given value in the preferences using the given key.
- (void) setPreferenceValue:(NSString *)value forKey:(NSString *)key;

// Use to save all preferences.
- (void)savePreferences;

// Try to get the IP from the preferences and set it to a default address if it could not be found.
+ (NSString *)getDefaultIpAddress;

// Use to check if the given value is a numeric value.
+ (BOOL)isStringNumeric:(NSString *)value;

// Use to get the IPv6 or v4 address if found, nil otherwise
+ (NSString *)getIpFromNetworkInterface:(InterfaceType)interface ipVersion:(int)ipVersion;

@end
