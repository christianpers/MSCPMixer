//
//  AppDelegate.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "plTableView.h"
#import "Shared.h"

#include "appkey.c"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;
@synthesize navigationController = _navigationController;
@synthesize loadPlaylist = _loadPlaylist;
@synthesize playbackLabel = _playbackLabel;
@synthesize playlistLabel = _playlistLabel;
@synthesize searchLabel = _searchLabel;
@synthesize loadingView = _loadingView;
@synthesize searchTViewController = _searchTViewController;
@synthesize searchController = _searchController;
@synthesize chTwoActive;
@synthesize airplayIcon;
@synthesize plViewController;
@synthesize cueController;
@synthesize logoutViewController;
@synthesize plbackViewController;
@synthesize userTxtBtn;
@synthesize activeView, bgMenu;
@synthesize menuController;

int labelWidth = 170;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[self.window makeKeyAndVisible];
    
    [self.window setRootViewController:self.mainViewController];
    
    self.mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.searchController = [[searchViewController alloc]init];
    
    
  	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"MSCP.mixerTest005"
												   error:nil];
    
	self.playbackManager = [[[audioControl alloc] initWithPlaybackSession:[SPSession sharedSession]] autorelease];
    
	[self addObserver:self forKeyPath:@"currentTrack.duration" options:0 context:nil];
	[self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:0 context:nil];
    
    [[SPSession sharedSession] setDelegate:self];
    
    [self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
  
    return YES;
}

-(void)showLogin {
	[self.mainViewController presentModalViewController:[[[LoginViewController alloc] init] autorelease]
											   animated:NO];
}

-(void)createLoadingPlView{
    
    CGSize winSize = self.window.frame.size;
    UIView *newloadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    
    newloadingView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.9];
    [self.mainViewController.view addSubview:newloadingView];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 580, winSize.width, 60)];
    // lbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    lbl.text = [NSString stringWithFormat:@"LOADING UR PLAYLISTS"];
    lbl.textAlignment = UITextAlignmentCenter;
    [newloadingView addSubview:lbl];
    [lbl release];
    
    UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    av.frame=CGRectMake((winSize.width/2)-(85/2), ((winSize.height/2)-(85/2))-40, 85, 85);
    av.tag  = 1;
    [newloadingView addSubview:av];
    [av startAnimating];
    
    self.loadingView = newloadingView;
    
    [newloadingView release];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.duration"]) {
	//	self.positionSlider.maximumValue = self.currentTrack.duration;
        [self.plbackViewController setPlayduration:self.currentTrack.duration];
        NSLog(@"duration set");
	} else if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
		// Only update the slider if the user isn't currently dragging it.
	//	if (!self.positionSlider.highlighted)
	//		self.positionSlider.value = self.playbackManager.trackPosition;
     //   NSLog(@"trackposition: %f",self.playbackManager.trackPosition);
        [self.plbackViewController updatePlayduration:self.playbackManager.trackPosition];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    if (![SPSession sharedSession].playing && !self.playbackManager.chTwoPlayingProp){
        
        [self.playbackManager stopAUGraph];
    }
    
  
  //  [[SPSession sharedSession]logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.cueController.tableView reloadData];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
   // [self.playbackManager stopAUGraph];
   // [[SPSession sharedSession]logout];
    
}

- (void)callfadeInMusicCh1{
    [self.playbackManager fadeInMusicCh1];
    
}

- (void)handlecuetrackSelect:(SPTrack *)track{
    
    [self.playbackManager fadeOutMusicCh1];
    [self performSelector:@selector(playnewTrack:) withObject:track afterDelay:.6];
    [self performSelector:@selector(callfadeInMusicCh1) withObject:nil afterDelay:.8];
    
    
}

- (void)playnewTrack:(SPTrack *)track{
    // [self.playbackManager stopAUGraph];
    //  [self.mainViewController dismissModalViewControllerAnimated:YES];
    
    
    SPTrack *trackToPlay = track;
    
    if (trackToPlay != nil) {
        
        if (!track.isLoaded) {
            // Since we're trying to play a brand new track that may not be loaded, 
            // we may have to wait for a moment before playing. Tracks that are present 
            // in the user's "library" (playlists, starred, inbox, etc) are automatically loaded
            // on login. All this happens on an internal thread, so we'll just try again in a moment.
            [self performSelector:@selector(playnewTrack:) withObject:trackToPlay afterDelay:0.1];
            return;
        }
        NSError *error = nil;
        
        if (![self.playbackManager playTrack:track error:&error]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [[alert autorelease] show];
        }
        else {
            self.currentTrack = track;
            
            [self.cueController.tableView reloadData];
            
        }
        
        return;
    }
	
}


- (void)setTrackPosition:(double)newVal {
    NSTimeInterval setnewTrackPos = self.playbackManager.trackPosition;
    setnewTrackPos += newVal;
   [self.playbackManager seekToTrackPosition:setnewTrackPos];
}

- (void)removeGUI{
    [self.searchLabel removeFromSuperview];
    [self.plbackViewController.view removeFromSuperview];
    [self.playbackLabel removeFromSuperview];
    [self.cueController.view removeFromSuperview];
    [self.playlistLabel removeFromSuperview];
    [self.airplayIcon removeFromSuperview];
    [[Shared sharedInstance].masterCue removeAllObjects];
    [self.userTxtBtn removeFromSuperview];
    [self.activeView removeFromSuperview];
    [self.bgMenu removeFromSuperview];
    
}

- (void)initLoadGUI{
    
    CGSize winSize = self.window.frame.size;
    
    self.menuController = [[UIViewController alloc]init];
    self.menuController.view.frame = CGRectMake(580, 30, labelWidth+30, 185);
    self.menuController.view.backgroundColor = [UIColor blackColor];
    self.menuController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
   
    activeViewX = winSize.width-(labelWidth + 20);
    
    UITapGestureRecognizer *menuTouchSearch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchSearch.numberOfTapsRequired = 1;
    
    self.bgMenu = [[UIView alloc]initWithFrame:CGRectMake(0, 0, labelWidth+30, 185)];
    bgMenu.backgroundColor = [UIColor blackColor];
    //[self.menuController.view addSubview:self.bgMenu];
    
    
    NSString* activeViewImgStr = [[NSBundle mainBundle] pathForResource:@"selected dot" ofType:@"png"];
    UIImage *activeViewImg = [UIImage imageWithContentsOfFile:activeViewImgStr];
    self.activeView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 87, 11, 11)];
    activeView.image = activeViewImg;
    self.activeView.hidden = YES;
    
    [self.menuController.view addSubview:self.activeView];
    
    
    self.searchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 130, labelWidth, 40)];
    self.searchLabel.backgroundColor = [UIColor clearColor];
    self.searchLabel.textColor = [UIColor whiteColor];
    self.searchLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    self.searchLabel.text = [NSString stringWithFormat:@"Search"];
    [self.searchLabel addGestureRecognizer:menuTouchSearch];
    self.searchLabel.UserInteractionEnabled = YES;
    [self.searchLabel setTag:12];
    [self.menuController.view addSubview:self.searchLabel];
    self.searchLabel.hidden = YES;
    
    [menuTouchSearch release];
    
    //PLAYBACK viewcontroller
    self.plbackViewController = [[playbackViewController alloc]init];
    [self.mainViewController.view addSubview:self.plbackViewController.view];
    //[self.mainViewController presentViewController:self.plbackViewController animated:NO completion:nil];
    
    UITapGestureRecognizer *menuTouchPlayback = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchPlayback.numberOfTapsRequired = 1;
    
    self.playbackLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, labelWidth, 40)];
    //self.playbackLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    self.playbackLabel.backgroundColor = [UIColor clearColor];
    self.playbackLabel.textColor = [UIColor whiteColor];
    self.playbackLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
   // [self.playbackLabel setFont:[UIFont fontWithName:@"GothamHTF-Medium" size:26]];
    self.playbackLabel.text = [NSString stringWithFormat:@"Playback"];
    [self.playbackLabel addGestureRecognizer:menuTouchPlayback];
    self.playbackLabel.UserInteractionEnabled = YES;
    [self.playbackLabel setTag:11];
    [self.menuController.view addSubview:self.playbackLabel];
    self.playbackLabel.hidden = YES;
    
    [menuTouchPlayback release];
    
    
    //CUE controller
    self.cueController = [[cueViewController alloc]init];
    [self.mainViewController.view addSubview:self.cueController.view];
    self.cueController.view.hidden = YES;
    
    
    UITapGestureRecognizer *menuTouchPlaylist = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchPlaylist.numberOfTapsRequired = 1;
    
    self.playlistLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, labelWidth, 40)];
    self.playlistLabel.backgroundColor = [UIColor clearColor];
    self.playlistLabel.textColor = [UIColor whiteColor];
    self.playlistLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
    self.playlistLabel.text = [NSString stringWithFormat:@"My playlists"];
    [self.playlistLabel addGestureRecognizer:menuTouchPlaylist];
    self.playlistLabel.UserInteractionEnabled = YES;
    [self.playlistLabel setTag:10];
    [self.menuController.view addSubview:self.playlistLabel];
    self.playlistLabel.hidden = YES;
    
    [menuTouchPlaylist release];
    
    //AIRPLAY view
    UIView *mpVolumeViewParentView = [[UIView alloc]initWithFrame:CGRectMake(60, 30, 50, 50)];
    mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    [self.mainViewController.view addSubview:mpVolumeViewParentView];
    MPVolumeView *myVolumeView =
    [[MPVolumeView alloc] initWithFrame: mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview: myVolumeView];
    //myVolumeView.showsRouteButton = YES;
    myVolumeView.showsVolumeSlider = NO;
    self.airplayIcon = mpVolumeViewParentView;
    [myVolumeView release];
    [mpVolumeViewParentView release];

    [self.mainViewController.view addSubview:self.menuController.view];
    
  
}

NSUInteger playlistsAttempts;
NSUInteger loadplAttempts;
NSUInteger loadTrack;

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    
    if (![Shared sharedInstance].hasLoggedin){
        
        [self createLoadingPlView];
        [self initLoadGUI];
        
        [Shared sharedInstance].hasLoggedin = true;
        
    } 
    
    // Invoked by SPSession after a successful login.
	[self.mainViewController dismissModalViewControllerAnimated:YES];
    
    if (![[[SPSession sharedSession] userPlaylists] isLoaded]&&[[[SPSession sharedSession] starredPlaylist] isLoaded])
    {
        playlistsAttempts++;
        
        if (playlistsAttempts < 50) 
        {
            [self performSelector:_cmd withObject:nil afterDelay:1.0];
            return;
        }
        else{
            self.cueController.view.hidden = NO;
            self.playlistLabel.hidden = NO;
            self.searchLabel.hidden = NO;
            self.playbackLabel.hidden = NO;
            
            [self.loadingView removeFromSuperview];
        }
    }
    else{
        NSLog(@"loaded playlists");
        
        self.cueController.view.hidden = NO;
        self.playlistLabel.hidden = NO;
        self.searchLabel.hidden = NO;
        self.playbackLabel.hidden = NO;
        
        [self.loadingView removeFromSuperview];
       // [self.loadingView release];
        
        self.plViewController = [[playlistViewController alloc]init];
        
      //  [self.mainViewController presentViewController:self.plViewController animated:NO completion:nil];
        [self.mainViewController.view insertSubview:self.plViewController.view belowSubview:self.plbackViewController.view];
      
        NSString* infoImgStr = [[NSBundle mainBundle] pathForResource:@"info" ofType:@"png"];
        UIImage *infoImg = [UIImage imageWithContentsOfFile:infoImgStr];
        
        self.userTxtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.userTxtBtn.frame = CGRectMake(10, 25, 36, 36);
        self.userTxtBtn.backgroundColor = [UIColor clearColor];
       // [self.userTxtBtn setTitle:[NSString stringWithFormat:@"i"] forState:UIControlStateNormal];
        [self.userTxtBtn setBackgroundImage:infoImg forState:UIControlStateNormal];
        self.userTxtBtn.titleLabel.textAlignment = UITextAlignmentLeft;
        [self.userTxtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.userTxtBtn.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(30.0)];
       
        [self.userTxtBtn addTarget:self 
                   action:@selector(showlogoutViewController)
         forControlEvents:UIControlEventTouchDown];
        
        [self.mainViewController.view addSubview:self.userTxtBtn];
        
        self.activeView.hidden = NO;
    }  
}

-(void)sessionLostPlayToken:(SPSession *)session;
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost play token" message:@"That means another client is playing music with this account, so this one'll have to stop playing." delegate:nil cancelButtonTitle:@"Arrrrggghhh! My music!" otherButtonTitles:nil];
	[alert show];
    
    self.playbackManager.isPlaying = NO;
    [self.playbackManager stopAUGraph];
	
}

-(void)addSongFromSearch:(NSURL *)trackURL{
    
    [[Shared sharedInstance].masterCue addObject:trackURL];
    
    [self.cueController.tableView reloadData];
    
    SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
    
    if (![SPSession sharedSession].playing){
        [self playnewTrack:track];
        
    }
}

-(void)addSongToCueChannelOne:(NSURL *)trackURL{
    
    [[Shared sharedInstance].masterCue addObject:trackURL];
    
    SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
    
    if (![SPSession sharedSession].playing){
        [self playnewTrack:track];
        
    }
    
    [self.cueController.tableView reloadData];
}


-(void)removeSongFromPlaybackCue:(int)selRow{
    
    SPPlaylistContainer *container = [[SPSession sharedSession] userPlaylists];
    
    SPPlaylist *playlistDetail = [container.playlists objectAtIndex:[Shared sharedInstance].curClickedPl];
    
    SPPlaylistItem *playlistItem;
    
    NSURL *trackURL;
    
    playlistItem = [playlistDetail.items objectAtIndex:selRow];
    
    trackURL = playlistItem.itemURL;
    
    [[Shared sharedInstance].masterCue removeObject:trackURL];
    
    for (NSURL *str in [Shared sharedInstance].masterCue){
        NSLog(@"str:%@",str);
    }
}

- (void)mainMenuClick:(UITapGestureRecognizer *)gesture{
    UIView *lbl = [gesture view];
    if (lbl.tag == 10){
        self.airplayIcon.hidden = NO;
        self.userTxtBtn.hidden = NO;
        [self.mainViewController.view bringSubviewToFront:self.plViewController.view];
        [self.mainViewController.view bringSubviewToFront:self.menuController.view];
        
        
        self.activeView.frame = CGRectMake(5, 27, 11, 11);
       
       // [self.plbackViewController dismissViewControllerAnimated:YES completion:nil];
       // [self.mainViewController presentViewController:self.plViewController animated:YES completion:nil];
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (lbl.tag == 11){
        self.airplayIcon.hidden = NO;
        self.userTxtBtn.hidden = NO;
        [self.mainViewController.view bringSubviewToFront:self.plbackViewController.view];
        [self.mainViewController.view bringSubviewToFront:self.menuController.view];
        
        
        self.activeView.frame = CGRectMake(5, 87, 11, 11);
        
     //   [self.plViewController dismissViewControllerAnimated:YES completion:nil];
     //   [self.mainViewController presentViewController:self.plbackViewController animated:YES completion:nil];
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
    else if (lbl.tag == 12){
       
        
        self.airplayIcon.hidden = YES;
        self.userTxtBtn.hidden = YES;
        
        
        self.activeView.frame = CGRectMake(5, 147, 11, 11);
     //   [self.plbackViewController dismissViewControllerAnimated:YES completion:nil];
     //   [self.plViewController dismissViewControllerAnimated:YES completion:nil];
        [self.mainViewController presentViewController:self.searchController animated:YES completion:nil];
        
    }
}

- (void)showlogoutViewController{
    
    self.logoutViewController = [[UIViewController alloc] init];
    self.logoutViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.logoutViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.mainViewController presentModalViewController:self.logoutViewController animated:YES];
    self.logoutViewController.view.superview.frame = CGRectMake(0, 0, 240, 190); //it's important to do this after presentModalViewController
    self.logoutViewController.view.superview.center = self.mainViewController.view.center;
    
    SPUser *user = [[SPSession sharedSession]user];
    NSString *userName = user.displayName;
    UILabel *loggedInUser = [[UILabel alloc] initWithFrame:CGRectMake(30, 7, 180, 30)];
    loggedInUser.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(16.0)];
    loggedInUser.text = [NSString stringWithFormat:@"Logged in as: %@",userName];
    loggedInUser.textColor = [UIColor blackColor];
    loggedInUser.backgroundColor = [UIColor clearColor];
    [self.logoutViewController.view addSubview:loggedInUser];
    [loggedInUser release];
    
  
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(30, 50, 180, 55);
    logoutBtn.backgroundColor = [UIColor blackColor];
    logoutBtn.layer.cornerRadius = 5;
    [logoutBtn setTitle:[NSString stringWithFormat:@"Switch user"] forState:UIControlStateNormal];
    logoutBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    logoutBtn.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(16.0)];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   // logoutBtn.titleLabel.font = [UIFont systemFontOfSize:14];
  //  [logoutBtn sizeToFit];
    [logoutBtn addTarget:self 
               action:@selector(userLogout)
     forControlEvents:UIControlEventTouchDown];
    
    [self.logoutViewController.view addSubview:logoutBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(30, 115, 180, 55);
    cancelBtn.backgroundColor = [UIColor blackColor];
    cancelBtn.layer.cornerRadius = 5;
    [cancelBtn setTitle:[NSString stringWithFormat:@"Cancel"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    cancelBtn.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(16.0)];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  //  cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
  //  [cancelBtn sizeToFit];
    [cancelBtn addTarget:self 
                  action:@selector(removeLogoutView)
        forControlEvents:UIControlEventTouchDown];

     [self.logoutViewController.view addSubview:cancelBtn];
    
}

-(void)removeLogoutView{
    
    [self.logoutViewController dismissModalViewControllerAnimated:YES];
}

-(void)setNotPlaying{
    
    [self.playbackManager setIsPlaying:NO];
}

-(void)userLogout{
    
    if ([SPSession sharedSession].isPlaying){
        
        [self.playbackManager fadeOutMusicCh1];
        // [self.playbackManager setIsPlaying:NO];
        [self performSelector:@selector(setNotPlaying) withObject:nil afterDelay:.6];
        
    }
    
    [[SPSession sharedSession] logout];
    [self removeLogoutView];
    
    
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    
	// Invoked by SPSession after a failed login.
    
	// Forward to the login view controller
	if ([self.mainViewController.modalViewController respondsToSelector:_cmd])
		[self.mainViewController.modalViewController performSelector:_cmd withObject:aSession withObject:error];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
    NSLog(@"session logged out");
    
    [self removeGUI];
    [self.playbackManager stopAUGraph];
    for (UIView *view in [self.plViewController.view subviews]){
        
        [view removeFromSuperview];
    }
    [self.plViewController.plMainView removeFromSuperview];
    [Shared sharedInstance].relogin = true;
    [self.mainViewController presentModalViewController:[[[LoginViewController alloc] init] autorelease]
											   animated:YES];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error"
													message:nil
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[[alert autorelease] show];
}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[[alert autorelease] show];
}

- (void)dealloc
{
  /*  [self removeObserver:self forKeyPath:@"currentTrack.name"];
	[self removeObserver:self forKeyPath:@"currentTrack.artists"];
	[self removeObserver:self forKeyPath:@"currentTrack.album.cover.image"];
	[self removeObserver:self forKeyPath:@"playbackManager.trackPosition"];
    */
   // [_loadingView release];
    [_playlistLabel release];
    [_playbackLabel release];
    [_searchLabel release];
    [self.plbackViewController release];
    [_loadPlaylist release];
 	[_currentTrack release];
	[_playbackManager release];
	[_window release];
	[_mainViewController release];
	[_navigationController release];
    [super dealloc];
}
@end

