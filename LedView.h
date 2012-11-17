//
//  LedView.h
//
//  Created by Wouter van der Post on 06-06-11.
//  Copyright 2012 PostFossil B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LedView : UIView 
{
    IBOutlet UIImageView* _ledImage;
	NSTimer* _timer;
}

@property (nonatomic, retain) UIImageView* _ledImage;
@property (nonatomic, retain) NSTimer* _timer;

- (void)flash;

@end
