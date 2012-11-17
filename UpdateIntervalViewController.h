//
//  SelectViewController.h
//  YouLess
//
//  Created by Wouter van der Post on 25-09-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateIntervalViewControllerDelegate<NSObject> @optional 
  - (void)itemSelected:(int)value;
@end 

@interface UpdateIntervalViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{    
    id <UpdateIntervalViewControllerDelegate> delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil updateInterval:(int)value;

@property (nonatomic, assign) id delegate; 
@property (nonatomic) int updateInterval;

@end
