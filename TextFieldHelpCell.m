//
//  TextFieldHelpCell.m
//  YouLess
//
//  Created by Wouter van der Post on 14-01-12.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "TextFieldHelpCell.h"

@implementation TextFieldHelpCell

@synthesize cellLabel;
@synthesize cellHelpLabel;
@synthesize cellValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
