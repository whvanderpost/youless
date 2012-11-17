//
//  AboutViewController.m
//  YouLess
//
//  Created by Wouter van der Post on 25-03-12.
//  Copyright (c) 2012 PostFossil B.V. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_doneButton release];
    [_versionLabel release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _versionLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"AboutVersion", nil), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _doneButton = nil;
    _versionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UI Control Handlers

- (IBAction)done:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)webLinkTouchUp:(UIButton *)sender
{
	NSURL* target = [[[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@", sender.currentTitle]] autorelease];
	[[UIApplication sharedApplication] openURL:target];
}

#pragma mark -

@end
