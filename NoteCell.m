//
//  NoteCell.m
//  YouLess
//
//  Created by Wouter Wessels on 18-09-11.
//  Copyright 2012 Human Software. All rights reserved.
//

#import "NoteCell.h"


@implementation NoteCell

@synthesize noteLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	
	if (self) {
		self.selectionStyle = UITableViewCellEditingStyleNone;
		//self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
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
