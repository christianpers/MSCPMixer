//
//  mixerViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mixerViewController.h"


@implementation mixerViewController

@synthesize timepitchController, lopassController, hipassController, channelOneVolController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    
    UIView *mixerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    self.view = mixerView;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    [mixerView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
      
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationLandscapeRight;
}

@end
