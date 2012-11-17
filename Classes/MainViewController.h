//
//  MainViewController.h
//  YouLess
//
//  Created by Wouter van der Post on 02-01-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "Reachability.h"
#import "LedView.h"
#import "CustomUrlConnection.h"
#import "Authentication.h"

@interface MainViewController : UIViewController 
{    
	//---outlets---
	IBOutlet UILabel* _wattValue;
    IBOutlet UILabel* _wattLabel;
	IBOutlet UILabel* _maxValue;
	IBOutlet UILabel* _middleValue;
	IBOutlet UILabel* _errorLabel;
	IBOutlet UIImageView* _gauge;
  	IBOutlet UIImageView* _gauge2;
	IBOutlet UIImageView* _gaugeNeedle;
	IBOutlet UIView* _deltaLabelsView;
	IBOutlet UINavigationItem* _navigationBar;
	IBOutlet UIActivityIndicatorView* _spinner;
	IBOutlet LedView* _ledView;
    IBOutlet UIBarButtonItem* _refreshButton;
    IBOutlet UIBarButtonItem* _settingsButton;
	
    Reachability* _internetReach;
    CustomUrlConnection* _conn;
    Authentication* _authentication;
    
	int _previousWattValue;
   	double _updateInterval;
	float _previousDegreesValue;
	double _animationDuration;
	NSMutableArray* _deltaLabels;
	UIView* _garbageDeltaLabel;
	BOOL _simulateUp;
	BOOL _simulatorMode;
	BOOL _forceGaugeUpdate;
    BOOL _isInError;
}

@property (nonatomic, retain) UIBarButtonItem* _refreshButton;
@property (nonatomic, retain) UIBarButtonItem* _settingsButton;
@property (nonatomic, retain) UILabel* _wattValue;
@property (nonatomic, retain) UILabel* _wattLabel;
@property (nonatomic, retain) UILabel* _maxValue;
@property (nonatomic, retain) UILabel* _middleValue;
@property (nonatomic, retain) UILabel* _errorLabel;
@property (nonatomic, retain) UIImageView* _gauge;
@property (nonatomic, retain) UIImageView* _gauge2;
@property (nonatomic, retain) UIImageView* _gaugeNeedle;
@property (nonatomic, retain) UIView* _deltaLabelsView;
@property (nonatomic, retain) UINavigationItem* _navigationBar;
@property (nonatomic, retain) UIActivityIndicatorView* _spinner;
@property (nonatomic, retain) LedView* _ledView;
@property (nonatomic, retain) NSString* _previousKWhValue;
@property (nonatomic, retain) NSTimer* _timeoutTimer;
@property (nonatomic, retain) NSTimer* _timer;

- (IBAction)showInfo:(id)sender;
- (IBAction)showSettings:(id)sender;
- (void)handleUnauthenticated;

@end
