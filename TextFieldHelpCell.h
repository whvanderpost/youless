//
//  TextFieldHelpCell.h
//  YouLess
//
//  Created by Wouter van der Post on 14-01-12.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldHelpCell : UITableViewCell {

}

@property (nonatomic, retain) IBOutlet     UILabel* cellLabel;
@property (nonatomic, retain) IBOutlet     UILabel* cellHelpLabel;
@property (nonatomic, retain) IBOutlet UITextField* cellValue;

@end
