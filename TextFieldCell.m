//
//  TextFieldCell.m
//  YouLess
//
//  Created by Wouter Wessels on 18-09-11.
//  Copyright 2012 Human Software. All rights reserved.
//

#import "TextFieldCell.h"

@interface TextFieldCell (Private)

- (void)shiftCenterWithPixels:(int)pixels;

@end

@implementation TextFieldCell

@synthesize cellLabel;
@synthesize cellValue;

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
		//self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
	}
	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)shiftCenterWithPixels:(int)pixels
{
    if(shifted)
    {
        return;
    }
    
    // Resize the label width
    cellLabel.frame = CGRectMake(cellLabel.frame.origin.x, cellLabel.frame.origin.y, cellLabel.frame.size.width + pixels, cellLabel.frame.size.height);
    
    // Resize the textfield width and x position
    cellValue.frame = CGRectMake(cellValue.frame.origin.x + pixels, cellValue.frame.origin.y, cellValue.frame.size.width - pixels, cellValue.frame.size.height);
    
    shifted = YES;
}

- (void)dealloc
{
    [super dealloc];
}

@end
