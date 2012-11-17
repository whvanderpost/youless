//
//  SelectViewController.m
//  YouLess
//
//  Created by Wouter van der Post on 25-09-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import "UpdateIntervalViewController.h"
#import "SelectCell.h"
#import "PreferencesHelper.h"

@implementation UpdateIntervalViewController

@synthesize delegate;
@synthesize updateInterval;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil updateInterval:(int)value
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        updateInterval = value;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *) cellFromNibWithName:(NSString *)nibName forTableView:(UITableView *)tableView 
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:nibName];
	
    if (cell == nil) 
    {
		NSArray *topLevelObjs = nil;
		topLevelObjs = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
		
		return [topLevelObjs objectAtIndex:0];
	}
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell* cell = nil;
	
    cell = [self cellFromNibWithName:@"SelectCell" forTableView:tableView];
    
    SelectCell* selectCell = (SelectCell *)cell;
    selectCell.selectValueLabel.hidden = YES;
    
	switch (indexPath.row) 
    {
		case 0: 
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate100", nil);
            selectCell.value = 100;
            if(updateInterval == 100)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		case 1:
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate200", nil);
            selectCell.value = 200;
            if(updateInterval == 200)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
        case 2:
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate500", nil);
            selectCell.value = 500;
            if(updateInterval == 500)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
        case 3:
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate1000", nil);
            selectCell.value = 1000;
            if(updateInterval == 1000)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;    
        case 4:
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate2000", nil);
            selectCell.value = 2000;
            if(updateInterval == 2000)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
        case 5:
			selectCell.selectLabel.text = NSLocalizedString(@"SettingsUpdate5000", nil);
            selectCell.value = 5000;
            if(updateInterval == 5000)
                selectCell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
	}
	
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return @"";
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectCell* selectCell = (SelectCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    //Is anyone listening
    if([delegate respondsToSelector:@selector(itemSelected:)])
    {
        //send the delegate function with the amount entered by the user
        [delegate itemSelected:selectCell.value];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
