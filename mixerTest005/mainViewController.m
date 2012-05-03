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

@synthesize loadingView;
@synthesize plbackViewController, plViewController, searchController, tabController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor redColor];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
      
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!appStarted){
        int width, height;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            width = 1024;
            height = 768;
            //    NSLog(@"landscape");
        }else {
            width = 768;
            height = 1024;
            //     NSLog(@"portrait");
        }
        
        self.plbackViewController = [[playbackViewController alloc]init];
        self.plViewController = [[playlistViewController alloc]init];
      ///  [self.plViewController initLoadProcess];
        self.searchController = [[searchViewController alloc]init];
        
        self.tabController = [[tabbarController alloc] init];
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
            tabController.view.frame = CGRectMake(0, 0, 768, 1072);
            //  [self.mainViewController activatePortraitMode];
        }else {
            tabController.view.frame = CGRectMake(0, 0, 1042, 798);
            //  [self.mainViewController activateLandscapeMode];
        }
        
        tabController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [tabController setViewControllers:[NSArray arrayWithObjects:self.plbackViewController, self.plViewController,self.searchController, nil]];
        
        [self.view addSubview:tabController.view];
        
        //  CGSize winSize = self.window.frame.size;
        //  self.loadviewController = [[UIViewController alloc]init];
        UIView *newloadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        
        newloadingView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.9];
        [self.view addSubview:newloadingView];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 580, width, 60)];
        // lbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
        lbl.text = [NSString stringWithFormat:@"LOADING UR PLAYLISTS"];
        lbl.textAlignment = UITextAlignmentCenter;
        [newloadingView addSubview:lbl];
        [lbl release];
        
        UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        av.frame=CGRectMake((width/2)-(85/2), ((height/2)-(85/2))-40, 85, 85);
        av.tag  = 1;
        [newloadingView addSubview:av];
        [av startAnimating];
        
        self.loadingView = newloadingView;
        
        [newloadingView release];
        
        appStarted = YES;

        
    }
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self.loadingView removeFromSuperview];
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
        NSLog(@"mainviewcontroller landscape action");
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self activatePortraitMode];
        
        NSLog(@"mainviewcontroller portrait action");
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
 
}

- (void)activateLandscapeMode{
    
    NSLog(@"activate mixer mode !!!");
    self.tabController.menuBg.frame = CGRectMake(310, 30, 200, 185);
    [self.plbackViewController setmixerModeOn];
    [self.searchController setlandscapemode];
    
    
}
- (void)activatePortraitMode{
    
    NSLog(@"activate one channel mode !!");
    self.tabController.menuBg.frame = CGRectMake(570, 30, 200, 185);
    [self.plbackViewController setonechannelmodeOn];
    [self.searchController setportraitmode];
    
}

-(void)dealloc{
    
    [self.loadingView release];
    [super dealloc];
}

@end
