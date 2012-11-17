//
//  SettingsViewController.m
//  YouLess
//
//  Created by Wouter van der Post on 18-09-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "SettingsViewController.h"
#import "UpdateIntervalViewController.h"
#import "PreferencesHelper.h"
#import "TextFieldCell.h"
#import "TextFieldHelpCell.h"
#import "SwitchCell.h"
#import "NoteCell.h"
#import "SelectCell.h"
#import "Constants.h"

@implementation SettingsViewController

@synthesize _originalHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableViewOL release];

    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                        target:self 
                                                        action:@selector(saveButtonPressed)];
 
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                          target:self 
                                                          action:@selector(cancelButtonPressed)];
                                   
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    _originalHeight = _tableViewOL.frame.size.height;
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    _tableViewOL = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancelButtonPressed 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)saveButtonPressed 
{
    PreferencesHelper *preferencesHelper = [PreferencesHelper getInstance];
    
    if([PreferencesHelper isStringNumeric:_deltaThresholdCell.cellValue.text])
		[preferencesHelper setPreferenceValue:_deltaThresholdCell.cellValue.text forKey:@"deltaThreshold"];
	else
		[preferencesHelper setPreferenceValue:[NSString stringWithFormat:@"%d", DEFAULT_DELTA_THRESHOLD] forKey:@"deltaThreshold"];
	
	[preferencesHelper setPreferenceValue:[NSString stringWithFormat:@"%i", _updateIntervalCell.value] forKey:@"updateInterval"];
	
	[preferencesHelper setPreferenceValue:[NSString stringWithFormat:@"%d", (NSInteger)_simulatorCell.cellSwitch.on] forKey:@"simulator"];
	
	[preferencesHelper setPreferenceValue:[NSString stringWithFormat:@"%d", (NSInteger)_autoLockCell.cellSwitch.on] forKey:@"autoLock"];
	
	[preferencesHelper setPreferenceValue:[NSString stringWithFormat:@"%d", 0] forKey:@"firstTime1_1"];
	
	if(_ipCell.cellValue.text.length == 0)
	{
		_ipCell.cellValue.text = [PreferencesHelper getDefaultIpAddress];
	}
	
	[preferencesHelper setPreferenceValue:_ipCell.cellValue.text forKey:@"ipAddress"];
    
    if(_portCell.cellValue.text.length == 0)
	{
		_portCell.cellValue.text = [NSString stringWithFormat:@"%d", DEFAULT_PORT_NUMBER];
	}

    [preferencesHelper setPreferenceValue:_portCell.cellValue.text forKey:@"portNumber"];
	
    [preferencesHelper savePreferences];
    
    // Clean up existing cookies if the password has been changed.
    if([[PreferencesHelper getInstance] getPassword] != _passwordCell.cellValue.text)
    {
        // Cookies are not shared among applications in iOS. So we can remove them all.
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        
        [preferencesHelper savePassword:_passwordCell.cellValue.text];
    }
    
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)cellFromNibWithName:(NSString *)nibName forTableView:(UITableView *)tableView 
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:nibName];
	
	if (cell == nil) 
    {
		NSArray *topLevelObjs = nil;
		topLevelObjs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
		UITableViewCell* newCell = [topLevelObjs objectAtIndex:0];
        newCell.tag = YES;
        
		return newCell;
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 5;
    }
    
    return 0;
}

- (IBAction)portCellDoneClicked:(id)sender
{
    [_portCell.cellValue resignFirstResponder];
}

- (IBAction)deltaThresholdCellDoneClicked:(id)sender
{
    [_deltaThresholdCell.cellValue resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    switch (indexPath.section) {
        case 0:
            // Network section
            switch (indexPath.row) 
            {
            case 0:
                // IP address
                _ipCell = (TextFieldCell *)[self cellFromNibWithName:@"TextFieldCell" forTableView:tableView];
                if(_ipCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                {
                    _ipCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    _ipCell.cellLabel.text = NSLocalizedString(@"SettingsHostnameLabel", nil);
                    _ipCell.cellValue.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    _ipCell.cellValue.returnKeyType = UIReturnKeyDone;
                        _ipCell.cellValue.text = [[PreferencesHelper getInstance] getPreferenceForKey:@"ipAddress"];
                    _ipCell.cellValue.delegate = self;
                    [_ipCell shiftCenterWithPixels:-50];
                    
                    _ipCell.tag = NO;
                }
                return _ipCell;
            case 1: 
                // Port number (Text, numbers only)
                _portCell = (TextFieldCell *)[self cellFromNibWithName:@"TextFieldCell" forTableView:tableView];
                if(_portCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                {
                    _portCell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    _portCell.cellLabel.text = NSLocalizedString(@"SettingsPortLabel", nil);
                    _portCell.cellValue.keyboardType = UIKeyboardTypeNumberPad;
                    _portCell.cellValue.returnKeyType = UIReturnKeyDone;
                    NSNumber *storedPortNumber = [[PreferencesHelper getInstance] getPreferenceForKey:@"portNumber"];
                    _portCell.cellValue.text = [NSString stringWithFormat:@"%d", [storedPortNumber intValue]];
                    [_portCell shiftCenterWithPixels:-50];
                    
                    // create a done view + done button, attach to it an action, and place it in a toolbar as an accessory input view...
                    // Prepare done button
                    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
                    keyboardDoneButtonView.barStyle = UIBarStyleBlackOpaque;
                    keyboardDoneButtonView.translucent = YES;
                    keyboardDoneButtonView.tintColor = nil;
                    [keyboardDoneButtonView sizeToFit];
                    
                    UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                                target:self 
                                                                                                action:nil] autorelease];
                    
                    UIBarButtonItem *pickerDoneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                                       target:self 
                                                                                                       action:@selector(portCellDoneClicked:)] autorelease];
                    
                    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, pickerDoneButton, nil]];
                    
                    // Plug the keyboardDoneButtonView into the text field...
                    _portCell.cellValue.inputAccessoryView = keyboardDoneButtonView;  

                    [keyboardDoneButtonView release];
                
                    _portCell.tag = NO;
                }
                return _portCell;
            case 2:
                // Password cell
                _passwordCell = (TextFieldCell *)[self cellFromNibWithName:@"TextFieldCell" forTableView:tableView];
                if(_passwordCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                {
                    _passwordCell.selectionStyle = UITableViewCellSelectionStyleNone;

                    _passwordCell.cellLabel.text = NSLocalizedString(@"SettingsPasswordLabel", nil);
                    _passwordCell.cellValue.returnKeyType = UIReturnKeyDone;
                    _passwordCell.cellValue.secureTextEntry = YES;
                    _passwordCell.cellValue.autocorrectionType = UITextAutocorrectionTypeNo;
                    _passwordCell.cellValue.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    _passwordCell.cellValue.clearButtonMode = UITextFieldViewModeWhileEditing;
                    _passwordCell.cellValue.text = [[PreferencesHelper getInstance] getPassword];
                    _passwordCell.cellValue.delegate = self;
                    [_passwordCell shiftCenterWithPixels:-50];
                    
                    _passwordCell.tag = NO;
                }
                return _passwordCell;
            }
        case 1:
            // Display options section
            switch (indexPath.row) 
            {
                case 0:
                    // Delta threshold (Text, numbers only)
                    _deltaThresholdCell = (TextFieldCell *)[self cellFromNibWithName:@"TextFieldCell" forTableView:tableView];
                    if(_deltaThresholdCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                    {
                        _deltaThresholdCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        _deltaThresholdCell.cellLabel.text = NSLocalizedString(@"SettingsThresholdLabel", nil);
                        _deltaThresholdCell.cellValue.keyboardType = UIKeyboardTypeNumberPad;
                        _deltaThresholdCell.cellValue.returnKeyType = UIReturnKeyDone;
                        NSNumber *storedDeltaThreshold = [[PreferencesHelper getInstance] getPreferenceForKey:@"deltaThreshold"];
                        _deltaThresholdCell.cellValue.text = [NSString stringWithFormat:@"%d", [storedDeltaThreshold intValue]];
                        _deltaThresholdCell.cellValue.delegate = self;
                        _deltaThresholdCell.cellValue.tag = YES;
                        [_deltaThresholdCell shiftCenterWithPixels:30];
                        
                        // create a done view + done button, attach to it an action, and place it in a toolbar as an accessory input view...
                        // Prepare done button
                        UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
                        keyboardDoneButtonView.barStyle = UIBarStyleBlackOpaque;
                        keyboardDoneButtonView.translucent = YES;
                        keyboardDoneButtonView.tintColor = nil;
                        [keyboardDoneButtonView sizeToFit];
                        
                        UIBarButtonItem *flexSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                                                    target:self 
                                                                                                    action:nil] autorelease];
                        
                        UIBarButtonItem *pickerDoneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                                           target:self 
                                                                                                           action:@selector(deltaThresholdCellDoneClicked:)] autorelease];
                        
                        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexSpace, pickerDoneButton, nil]];
                        
                        // Plug the keyboardDoneButtonView into the text field...
                        _deltaThresholdCell.cellValue.inputAccessoryView = keyboardDoneButtonView;  
                        
                        [keyboardDoneButtonView release];
                        
                        _deltaThresholdCell.tag = NO;
                    }
                    return _deltaThresholdCell;
                case 1:
                    // Update interval (Select)
                    _updateIntervalCell = (SelectCell *)[self cellFromNibWithName:@"SelectCell" forTableView:tableView];
                    if(_updateIntervalCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                    {
                        _updateIntervalCell.selectLabel.text = NSLocalizedString(@"SettingsUpdateLabel", nil);
                        _updateIntervalCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                        int updateInterval = [[[PreferencesHelper getInstance] getPreferenceForKey:@"updateInterval"] intValue];                    
                        NSString* lookupString = [NSString stringWithFormat:@"SettingsUpdate%i", updateInterval];
                        _updateIntervalCell.selectValueLabel.text = NSLocalizedString(lookupString, nil);   
                        _updateIntervalCell.value = updateInterval;
                        
                        _updateIntervalCell.tag = NO;
                    }
                    return _updateIntervalCell;
                case 2:
                    // Prevent system lock (Switch)
                    _autoLockCell = (SwitchCell *)[self cellFromNibWithName:@"SwitchCell" forTableView:tableView];
                    if(_autoLockCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                    {
                        _autoLockCell.cellLabel.text = NSLocalizedString(@"SettingsLockLabel", nil);
                        _autoLockCell.cellSwitch.on = [[[PreferencesHelper getInstance] getPreferenceForKey:@"autoLock"] boolValue];
                        
                        _autoLockCell.tag = NO;
                    }
                    return _autoLockCell;
                case 3:
                    // Simulator (Switch)
                    _simulatorCell = (SwitchCell *)[self cellFromNibWithName:@"SwitchCell" forTableView:tableView];
                    if(_simulatorCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                    {
                        _simulatorCell.cellLabel.text = NSLocalizedString(@"SettingsSimulatorLabel", nil);
                        _simulatorCell.cellSwitch.on = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
                        
                        _simulatorCell.tag = NO;
                    }
                    return _simulatorCell;
                case 4:
                    // Show kWh (Switch)
                    _simulatorCell = (SwitchCell *)[self cellFromNibWithName:@"SwitchCell" forTableView:tableView];
                    if(_simulatorCell.tag) // Indicates if the cell came from cache, in which case it doesn't need to be re-initialized.
                    {
                        _simulatorCell.cellLabel.text = NSLocalizedString(@"SettingsSimulatorLabel", nil);
                        _simulatorCell.cellSwitch.on = [[[PreferencesHelper getInstance] getPreferenceForKey:@"simulator"] boolValue];
                        
                        _simulatorCell.tag = NO;
                    }
                    return _simulatorCell;
            }
        default:
            return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	switch (section) {
        case 0:
            return NSLocalizedString(@"SettingsNetworkHeader", nil);
        case 1:
            return NSLocalizedString(@"SettingsViewHeader", nil);
        default:
            return @"";
    }
}

#pragma mark - SelectViewControllerDelegate

- (void)itemSelected:(int)value;
{
    _updateIntervalCell.value = value;
    NSString* lookupString = [NSString stringWithFormat:@"SettingsUpdate%i", value];
    _updateIntervalCell.selectValueLabel.text = NSLocalizedString(lookupString, nil);   
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1 && indexPath.row == 1)
    {
        SelectCell *cell = (SelectCell *)[tableView cellForRowAtIndexPath:indexPath];
        UpdateIntervalViewController* controller = [[[UpdateIntervalViewController alloc] 
                                                     initWithNibName:@"SelectView" 
                                                     bundle:nil 
                                                     updateInterval:cell.value] autorelease];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField 
{
    if (textField.tag)
    {            
        // adjust the contentInset
        _tableViewOL.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
        
        // Scroll to the current text field
        [_tableViewOL scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField 
{
    if (textField.tag)
    {
        // Undo the contentInset
        _tableViewOL.contentInset = UIEdgeInsetsZero;
        
        // Close the keyboard
        [_deltaThresholdCell.cellValue resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	[textField resignFirstResponder];
	
	return YES;
}

#pragma mark -

@end
