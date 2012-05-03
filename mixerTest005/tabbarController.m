//
//  tabbarController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "tabbarController.h"
#import "AppDelegate.h"


@implementation tabbarController

@synthesize cueController;
@synthesize menuBg;
@synthesize loadplaylistView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
	[self hideTabBar];
    if (!appStarted)
        [self addCustomElements];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    appStarted = NO;
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
      //  NSLog(@"fuck landscape");
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
      //  NSLog(@"fuck portrait");
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        NSLog(@"tabbarcontroller switch orientation landscape");
        //  menuBg.frame = CGRectMake(530, 30, 200, 185);
        
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
         //  menuBg.frame = CGRectMake(570, 30, 200, 185);
         NSLog(@"tabbarcontroller switch orientation portrait");
        
    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    NSLog(@"selected view tabbar");
}

- (void)addCustomElements{
   
    int menuX;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        NSLog(@"tabcontroller landscape playback");
        menuX = 310;
        
    }else {
        menuX = 570;
    }
    
    // Now we repeat the process for the other buttons
	playlistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playlistBtn.frame = CGRectMake(29, 10, 170, 40);
    [playlistBtn setBackgroundColor:[UIColor clearColor]];
	[playlistBtn setTag:1];
    [playlistBtn setTitle:[NSString stringWithFormat:@"My playlists"] forState:UIControlStateNormal];
    playlistBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    [playlistBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    playlistBtn.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    playlistBtn.titleLabel.text = @"My playlists";
    
    playbackBtn = [UIButton buttonWithType:UIButtonTypeCustom]; //Setup the button
    playbackBtn.frame = CGRectMake(12, 70, 170, 40); // Set the frame (size and position) of the button)
    [playbackBtn setBackgroundColor:[UIColor clearColor]];
	[playbackBtn setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
    playbackBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    playbackBtn.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    [playbackBtn setTitle:[NSString stringWithFormat:@"Playback"] forState:UIControlStateNormal];
    
    [playbackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[playbackBtn setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
    
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 130, 170, 40);
    [searchBtn setBackgroundColor:[UIColor clearColor]];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[searchBtn setTag:2];
    [searchBtn setTitle:[NSString stringWithFormat:@"Search"] forState:UIControlStateNormal];
    searchBtn.titleLabel.textAlignment = UITextAlignmentLeft;
    searchBtn.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    searchBtn.titleLabel.text = @"Search";
    
    NSString* activeViewImgStr = [[NSBundle mainBundle] pathForResource:@"selected dot" ofType:@"png"];
    UIImage *activeViewImg = [UIImage imageWithContentsOfFile:activeViewImgStr];
    activeImg = [[UIImageView alloc]initWithFrame:CGRectMake(11, 87, 11, 11)];
    activeImg.image = activeViewImg;
    
    menuBg = [[UIView alloc]initWithFrame:CGRectMake(menuX, 30, 200, 185)];
    menuBg.backgroundColor = [UIColor blackColor];
    [menuBg addSubview:playlistBtn];
    [menuBg addSubview:playbackBtn];
    [menuBg addSubview:searchBtn];
    [menuBg addSubview:activeImg];
    
    [playbackBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[playlistBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[searchBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
    [self.view addSubview:menuBg];
    
    self.cueController = [[cueViewController alloc]init];
    [self.view addSubview:self.cueController.view];
  //  self.cueController.view.hidden = YES;
    
    appStarted = YES;
    
}

- (void)selectTab:(int)tabID
{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch(tabID)
    {
        case 0:
            [playbackBtn setSelected:true];
            [playlistBtn setSelected:false];
            [searchBtn setSelected:false];
            activeImg.frame = CGRectMake(11, 87, 11, 11);
            break;
        case 1:
        
          //       loadplaylistView = [[UIViewController alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
            //loadplaylistView = [[UIViewController alloc]init];
          //  loadplaylistView.frame = CGRectMake(100, 100, 200, 200);
          //  loadplaylistView.backgroundColor = [UIColor whiteColor];
          //       [main.mainViewController.view addSubview:loadplaylistView];
          //  [main.mainViewController presentModalViewController:loadplaylistView animated:YES];
            activeImg.frame = CGRectMake(11, 27, 11, 11);
            
            [playbackBtn setSelected:false];
            [playlistBtn setSelected:true];
            [searchBtn setSelected:false];
            
            
            break;
        case 2:
            [playbackBtn setSelected:false];
            [playlistBtn setSelected:false];
            [searchBtn setSelected:true];
            
            activeImg.frame = CGRectMake(11, 147, 11, 11);
            break;
    }
    if (self.selectedIndex == tabID) {
        // UINavigationController *navController = (UINavigationController *)[self selectedViewController];
        // [navController popToRootViewControllerAnimated:YES];
    } else {
        self.selectedIndex = tabID;
    }
    
}
- (void)hideTabBar{
    
    self.tabBar.hidden = YES;
}

- (void)buttonClicked:(id)sender
{
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)dealloc{
    
   // [self.playlistBtn release];
   // [self.playbackBtn release];
    //[self.searchBtn release];
    [self.cueController release];
    [self.menuBg release];
    [super dealloc];
}

@end
