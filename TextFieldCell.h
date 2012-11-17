//
//  TextFieldCell.h
//  YouLess
//
//  Created by Wouter Wessels on 18-09-11.
//  Copyright 2012 Human Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextFieldCell : UITableViewCell {
    bool shifted;
}

@property (nonatomic, retain) IBOutlet     UILabel* cellLabel;
@property (nonatomic, retain) IBOutlet UITextField* cellValue;

- (void)shiftCenterWithPixels:(int)pixels;

@end
