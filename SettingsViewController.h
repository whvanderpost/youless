//
//  SettingsViewController.h
//  YouLess
//
//  Created by Wouter van der Post on 18-09-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldCell.h"
#import "SelectCell.h"
#import "SwitchCell.h"
#import "UpdateIntervalViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UpdateIntervalViewControllerDelegate> {
    
    IBOutlet UITableView* _tableViewOL;
    TextFieldCell* _ipCell;
    TextFieldCell* _portCell;
    TextFieldCell* _passwordCell;
    TextFieldCell* _deltaThresholdCell;
    SelectCell* _updateIntervalCell;
    SwitchCell* _autoLockCell;
    SwitchCell* _simulatorCell;
}

@property(nonatomic) CGFloat _originalHeight;

@end;
