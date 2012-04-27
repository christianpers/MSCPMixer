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
    if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)){
      //  [self activateLandscapeMode];
        
    }else if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
      //  [self activatePortraitMode];
    }
    
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
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        [self activateLandscapeMode];
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self activatePortraitMode];
      //   main.menuController.view.frame = CGRectMake(580, 30, size.width, size.height);
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
 
}

- (void)activateLandscapeMode{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"activate mixer mode !!!");
    // main.menuController.view.frame = CGRectMake(540, 30, size.width, size.height);
    [main.plbackViewController setmixerModeOn];
    
    
}
- (void)activatePortraitMode{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"activate one channel mode !!");
    [main.plbackViewController setonechannelmodeOn];
    
    
}

@end
