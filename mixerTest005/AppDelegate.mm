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
@synthesize chTwoViewController;
@synthesize airplayIcon;
@synthesize plViewController;
@synthesize cueController;
@synthesize logoutViewController;
@synthesize plbackViewController;
@synthesize userTxtBtn;


int labelWidth = 300;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[self.window makeKeyAndVisible];
    
    self.searchController = [[searchViewController alloc]init];
    self.chTwoViewController = [[secondChannelUIViewController alloc]init];
    
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
    [self.window addSubview:newloadingView];
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 580, winSize.width, 60)];
    // lbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
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
    
  //  [self.playbackManager stopAUGraph];
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
    [self.chTwoViewController.view removeFromSuperview];
    [self.airplayIcon removeFromSuperview];
    [[Shared sharedInstance].masterCue removeAllObjects];
    [self.userTxtBtn removeFromSuperview];
}

- (void)initLoadGUI{
    
    CGSize winSize = self.window.frame.size;
    
    UITapGestureRecognizer *menuTouchSearch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchSearch.numberOfTapsRequired = 1;
    
    self.searchLabel = [[UILabel alloc]initWithFrame:CGRectMake(winSize.width-labelWidth, 160, labelWidth, 40)];
    self.searchLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    self.searchLabel.textColor = [UIColor whiteColor];
    self.searchLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
    self.searchLabel.text = [NSString stringWithFormat:@"Search"];
    [self.searchLabel addGestureRecognizer:menuTouchSearch];
    self.searchLabel.UserInteractionEnabled = YES;
    [self.searchLabel setTag:12];
    [self.window addSubview:self.searchLabel];
    self.searchLabel.hidden = YES;
    
    [menuTouchSearch release];
    
    //PLAYBACK viewcontroller
    self.plbackViewController = [[playbackViewController alloc]init];
    [self.mainViewController.view addSubview:self.plbackViewController.view];
    
    UITapGestureRecognizer *menuTouchPlayback = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchPlayback.numberOfTapsRequired = 1;
    
    self.playbackLabel = [[UILabel alloc]initWithFrame:CGRectMake(winSize.width-labelWidth, 100, labelWidth, 40)];
    self.playbackLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
    self.playbackLabel.textColor = [UIColor blackColor];
    self.playbackLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
    self.playbackLabel.text = [NSString stringWithFormat:@"Playback"];
    [self.playbackLabel addGestureRecognizer:menuTouchPlayback];
    self.playbackLabel.UserInteractionEnabled = YES;
    [self.playbackLabel setTag:11];
    [self.window addSubview:self.playbackLabel];
    self.playbackLabel.hidden = YES;
    
    [menuTouchPlayback release];
    
    
    //CUE controller
    self.cueController = [[cueViewController alloc]init];
    [self.window addSubview:self.cueController.view];
    self.cueController.view.hidden = YES;
    
    UITapGestureRecognizer *menuTouchPlaylist = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainMenuClick:)];
    menuTouchPlaylist.numberOfTapsRequired = 1;
    
    self.playlistLabel = [[UILabel alloc]initWithFrame:CGRectMake(winSize.width-labelWidth, 40, labelWidth, 40)];
    self.playlistLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    self.playlistLabel.textColor = [UIColor whiteColor];
    self.playlistLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
    self.playlistLabel.text = [NSString stringWithFormat:@"My playlists"];
    [self.playlistLabel addGestureRecognizer:menuTouchPlaylist];
    self.playlistLabel.UserInteractionEnabled = YES;
    [self.playlistLabel setTag:10];
    [self.window addSubview:self.playlistLabel];
    self.playlistLabel.hidden = YES;
    
    [menuTouchPlaylist release];
    
    
    
    //AIRPLAY view
    UIView *mpVolumeViewParentView = [[UIView alloc]initWithFrame:CGRectMake(20, 60, 50, 50)];
    mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    [self.window addSubview:mpVolumeViewParentView];
    MPVolumeView *myVolumeView =
    [[MPVolumeView alloc] initWithFrame: mpVolumeViewParentView.bounds];
    [mpVolumeViewParentView addSubview: myVolumeView];
    //myVolumeView.showsRouteButton = YES;
    myVolumeView.showsVolumeSlider = NO;
    self.airplayIcon = mpVolumeViewParentView;
    [myVolumeView release];
    [mpVolumeViewParentView release];
    

    //CHANNEL 2 viewcontroller
    self.chTwoViewController = [[secondChannelUIViewController alloc]init];
    [self.mainViewController.view insertSubview:self.chTwoViewController.view aboveSubview:self.plbackViewController.view];
    
  
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
        [self.mainViewController.view insertSubview:self.plViewController.view belowSubview:self.plbackViewController.view];
        
        SPUser *user = [[SPSession sharedSession]user];
        
        NSString *userName = user.displayName;
        
        self.userTxtBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.userTxtBtn.center = CGPointMake(25, 30);
        self.userTxtBtn.backgroundColor = [UIColor clearColor];
        [self.userTxtBtn setTitle:[NSString stringWithFormat:@"Logged in as: %@",userName] forState:UIControlStateNormal];
        self.userTxtBtn.titleLabel.textAlignment = UITextAlignmentLeft;
        [self.userTxtBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.userTxtBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.userTxtBtn sizeToFit];
        [self.userTxtBtn addTarget:self 
                   action:@selector(showlogoutViewController)
         forControlEvents:UIControlEventTouchDown];
        
        [self.window addSubview:self.userTxtBtn];
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
       
        self.playbackLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor whiteColor];
        
        self.searchLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor whiteColor];
        
        self.playlistLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor blackColor];
        
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (lbl.tag == 11){
        self.airplayIcon.hidden = NO;
        self.userTxtBtn.hidden = NO;
        [self.mainViewController.view bringSubviewToFront:self.plbackViewController.view];
        [self.mainViewController.view bringSubviewToFront:self.chTwoViewController.view];
        
        self.playbackLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor blackColor];
        
        self.searchLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor whiteColor];
        
        self.playlistLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor whiteColor];
        
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
    else if (lbl.tag == 12){
       
        
        self.airplayIcon.hidden = YES;
        self.userTxtBtn.hidden = YES;
        
        self.playbackLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor whiteColor];
        
        self.searchLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor blackColor];
        
        self.playlistLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor whiteColor];
        
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
  
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutBtn.frame = CGRectMake(30, 30, 180, 55);
    logoutBtn.backgroundColor = [UIColor blackColor];
    logoutBtn.layer.cornerRadius = 5;
    [logoutBtn setTitle:[NSString stringWithFormat:@"Switch user"] forState:UIControlStateNormal];
    logoutBtn.titleLabel.textAlignment = UITextAlignmentCenter;
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   // logoutBtn.titleLabel.font = [UIFont systemFontOfSize:14];
  //  [logoutBtn sizeToFit];
    [logoutBtn addTarget:self 
               action:@selector(userLogout)
     forControlEvents:UIControlEventTouchDown];
    
    [self.logoutViewController.view addSubview:logoutBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(30, 95, 180, 55);
    cancelBtn.backgroundColor = [UIColor blackColor];
    cancelBtn.layer.cornerRadius = 5;
    [cancelBtn setTitle:[NSString stringWithFormat:@"Cancel"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.textAlignment = UITextAlignmentCenter;
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
    [self.chTwoViewController release];
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

