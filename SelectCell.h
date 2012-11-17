//
//  SelectCell.h
//  YouLess
//
//  Created by Wouter Wessels on 18-09-11.
//  Copyright 2012 Human Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectCell : UITableViewCell {
    
}

@property (nonatomic, retain) IBOutlet UILabel *selectLabel;
@property (nonatomic, retain) IBOutlet UILabel *selectValueLabel;
@property (nonatomic) int value;

@end
