//
//  AboutViewController.h
//  YouLess
//
//  Created by Wouter van der Post on 25-03-12.
//  Copyright (c) 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController
{
    IBOutlet UIBarButtonItem* _doneButton;
    IBOutlet UILabel* _versionLabel;
}

- (IBAction)done:(id)sender;

@end
