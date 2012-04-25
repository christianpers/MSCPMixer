//
//  mainViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mainViewController.h"
#import "AppDelegate.h"

@implementation mainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        NSLog(@"activate mixer mode !!!");
        CGSize size = main.menuController.view.frame.size;
        main.menuController.view.center = CGPointMake(450, 100);
       // main.menuController.view.frame = CGRectMake(540, 30, size.width, size.height);
        [main.plbackViewController setmixerModeOn];
        
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        NSLog(@"activate one channel mode !!");
        CGSize size = main.menuController.view.frame.size;
        [main.plbackViewController setonechannelmodeOn];
        main.menuController.view.center = CGPointMake(670, 100);
        
      //   main.menuController.view.frame = CGRectMake(580, 30, size.width, size.height);
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
 
}

@end
