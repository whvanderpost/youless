//
//  SelectCell.m
//  YouLess
//
//  Created by Wouter Wessels on 18-09-11.
//  Copyright 2012 Human Software. All rights reserved.
//

#import "SelectCell.h"


@implementation SelectCell

@synthesize selectLabel;
@synthesize selectValueLabel;
@synthesize value;

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

- (void)dealloc
{
    [super dealloc];
}

@end
