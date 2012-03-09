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
@synthesize plbackView = _plbackView;
@synthesize pllistView = _pllistView;
@synthesize playbackLabel = _playbackLabel;
@synthesize playlistLabel = _playlistLabel;
@synthesize searchLabel = _searchLabel;
@synthesize cueView = _cueView;
@synthesize loadingView = _loadingView;
@synthesize searchTViewController = _searchTViewController;
@synthesize searchController = _searchController;
@synthesize secChView = _secChView;
@synthesize chTwoActive;
@synthesize chTwoViewController;
@synthesize pllistViewController;


int labelWidth = 300;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[self.window makeKeyAndVisible];
    
    
    self.searchController = [[searchViewController alloc]init];
    self.chTwoViewController = [[secondChannelUIViewController alloc]init];
    
    
    
    //  searchTableViewController *rootView = [[searchTableViewController alloc]init];
    //  self.navigationController = [[UINavigationController alloc]initWithRootViewController:rootView];
    
  	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"MSCP.mixerTest005"
												   error:nil];
    
	self.playbackManager = [[[audioControl alloc] initWithPlaybackSession:[SPSession sharedSession]] autorelease];
    
	[self addObserver:self forKeyPath:@"currentTrack.duration" options:0 context:nil];
	[self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:0 context:nil];
    
    [[SPSession sharedSession] setDelegate:self];
    
    //  [self.window addSubview:self.navigationController.view];
    [self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
    //[self showLogin];
    
    [self initLoadGUI];
    
    return YES;
}

-(void)showLogin {
	[self.mainViewController presentModalViewController:[[[LoginViewController alloc] init] autorelease]
											   animated:NO];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.duration"]) {
	//	self.positionSlider.maximumValue = self.currentTrack.duration;
        [self.plbackView setPlayduration:self.currentTrack.duration];
        NSLog(@"duration set");
	} else if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
		// Only update the slider if the user isn't currently dragging it.
	//	if (!self.positionSlider.highlighted)
	//		self.positionSlider.value = self.playbackManager.trackPosition;
     //   NSLog(@"trackposition: %f",self.playbackManager.trackPosition);
        [self.plbackView updatePlayduration:self.playbackManager.trackPosition];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[SPSession sharedSession]logout];
    
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
        self.currentTrack = track;
        return;
    }
	
}


-(void)newChannel:(UITapGestureRecognizer *)gesture{
    
    if ([self.playbackManager isaugraphRunning]){
        CGRect bounds = self.plbackView.bounds;
        CGSize winSize = self.window.frame.size;
        CGPoint effectParentPos = self.plbackView.effectParentView.frame.origin;
        CGRect effectParentSize = self.plbackView.effectParentView.bounds;
        
        if (!chTwoActive){
            chTwoActive = YES;
            [UIView animateWithDuration:1
                             animations:^{
                                 //     self.tableView.alpha = 1;
                                 //     self.tableView.hidden = YES;
                             }];
            
            [UIView beginAnimations : @"Display notif" context:nil];
            [UIView setAnimationDuration:1];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            self.plbackView.effectParentView.frame = CGRectMake(effectParentPos.x, effectParentPos.y, effectParentSize.size.width, bounds.size.height/2-100);
            self.plbackView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height/2);
            self.secChView.frame = CGRectMake(0, bounds.size.height/2, bounds.size.width, bounds.size.height/2);
            
            self.cueView.frame = CGRectMake(200, bounds.size.height-700, self.cueView.bounds.size.width, self.cueView.bounds.size.height);
            self.plbackView.trackControlBG.frame = CGRectMake(400, bounds.size.height-700, self.plbackView.trackControlBG.bounds.size.width, self.plbackView.trackControlBG.bounds.size.height);
            
            
            self.plbackView.timepitchController.frame = CGRectMake(20, bounds.size.height/4, self.plbackView.timepitchController.bounds.size.width, self.plbackView.timepitchController.bounds.size.height);
            
            self.plbackView.lopassController.frame = CGRectMake(80, 30, self.plbackView.timepitchController.bounds.size.width, self.plbackView.timepitchController.bounds.size.height);
            
            self.plbackView.hipassController.frame = CGRectMake(40, 100, self.plbackView.timepitchController.bounds.size.width, self.plbackView.timepitchController.bounds.size.height);
            
            self.plbackView.channelOneVolController.frame = CGRectMake(100, 200, self.plbackView.channelOneVolController.bounds.size.width, self.plbackView.channelOneVolController.bounds.size.height);
            
            self.plbackView.artistLbl.hidden = YES;
            self.plbackView.titleLbl.hidden = YES;
            
            
            [UIView commitAnimations];
            
            [self.chTwoViewController createChannelTwoUI];
        }
        else{
            chTwoActive = NO;
            [UIView animateWithDuration:1
                             animations:^{
                                 //     self.tableView.alpha = 1;
                                 //     self.tableView.hidden = YES;
                                 [self.chTwoViewController removeChannelTwoUI];
                             }];
            
            [UIView beginAnimations : @"Display notif" context:nil];
            [UIView setAnimationDuration:1];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            
            self.plbackView.artistLbl.hidden = NO;
            self.plbackView.titleLbl.hidden = NO;
            
            self.plbackView.frame = CGRectMake(0, 0, winSize.width, winSize.height);
            self.secChView.frame = CGRectMake(0, winSize.height-70, winSize.width,50);
            self.plbackView.effectParentView.frame = CGRectMake(effectParentPos.x, effectParentPos.y, effectParentSize.size.width, bounds.size.height-180);
            
            
            [UIView commitAnimations];
            
        }
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start spotify channel first" message:@"This channel is disabled until channel 1 is started, sorry dude." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}


- (void)setTrackPosition:(double)newVal {
    NSTimeInterval setnewTrackPos = self.playbackManager.trackPosition;
    setnewTrackPos += newVal;
   [self.playbackManager seekToTrackPosition:setnewTrackPos];
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
    
    self.plbackView = [[playbackView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    self.plbackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    [self.plbackView setTag:20];
    [self.mainViewController.view addSubview:self.plbackView];
    
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
    
    self.cueView = [[mastercueView alloc]initWithFrame:CGRectMake((winSize.width/2-600/2), winSize.height-200, 400, 60)];
    
    [self.window addSubview:self.cueView];
    self.cueView.hidden = YES;
    
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
    
    
    UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
    logout.frame = CGRectMake(winSize.width-200, 300, 200, 40);// position in the parent view and set the size of the
    logout.backgroundColor = [UIColor clearColor];
    [logout setTitle:[NSString stringWithFormat:@"Logout"] forState:UIControlStateNormal];
    [logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [logout addTarget:self 
               action:@selector(userLogout)
     forControlEvents:UIControlEventTouchDown];
    
    //[self.window addSubview:logout];
    
    
    self.secChView = [[secondChannelView alloc] init];
    self.secChView.frame = CGRectMake(0, self.plbackView.bounds.size.height-70, self.plbackView.bounds.size.width, 50);
    self.secChView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    
 //   [self.mainViewController.view insertSubview:self.secChView aboveSubview:self.plbackView];
    
    UITapGestureRecognizer *secChTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newChannel:)];
    secChTouch.numberOfTapsRequired = 1;
   
    UILabel *secChLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.plbackView.bounds.size.width, 40)];
    secChLbl.backgroundColor = [UIColor clearColor];
    secChLbl.textColor = [UIColor blackColor];
    secChLbl.textAlignment = UITextAlignmentCenter;
    secChLbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    secChLbl.text = [NSString stringWithFormat:@"Channel 2"];
    [secChLbl addGestureRecognizer:secChTouch];
    secChLbl.UserInteractionEnabled = YES;
    [secChLbl setTag:10];
    [self.secChView addSubview:secChLbl];
    
    [secChLbl release];
    [secChTouch release];
    
    
    self.chTwoViewController.view = self.secChView;
    [self.mainViewController.view insertSubview:self.chTwoViewController.view aboveSubview:self.plbackView];
    
}

NSUInteger playlistsAttempts;
NSUInteger loadplAttempts;
NSUInteger loadTrack;

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    
    
    CGSize winSize = self.window.frame.size;
    
    if (![Shared sharedInstance].hasLoggedin){
        [Shared sharedInstance].hasLoggedin = true;
        self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        self.loadingView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.9];
        [self.window addSubview:self.loadingView];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 580, winSize.width, 60)];
        // lbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
        lbl.text = [NSString stringWithFormat:@"LOADING UR PLAYLISTS"];
        lbl.textAlignment = UITextAlignmentCenter;
        [self.loadingView addSubview:lbl];
        [lbl release];
        
        UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        av.frame=CGRectMake((winSize.width/2)-(85/2), ((winSize.height/2)-(85/2))-40, 85, 85);
        av.tag  = 1;
        [self.loadingView addSubview:av];
        [av startAnimating];
    } 
    
    // Invoked by SPSession after a successful login.
	[self.mainViewController dismissModalViewControllerAnimated:YES];
    
    if (![[[SPSession sharedSession] userPlaylists] isLoaded])
    {
        playlistsAttempts++;
        
        if (playlistsAttempts < 50) 
        {
            [self performSelector:_cmd withObject:nil afterDelay:1.0];
            return;
        }
        else{
            self.cueView.hidden = NO;
            self.playlistLabel.hidden = NO;
            self.searchLabel.hidden = NO;
            self.playbackLabel.hidden = NO;
            
            [self.loadingView removeFromSuperview];
            
            
        }
    }
    else{
        NSLog(@"loaded playlists");
        
        self.cueView.hidden = NO;
        self.playlistLabel.hidden = NO;
        self.searchLabel.hidden = NO;
        self.playbackLabel.hidden = NO;
        
        [self.loadingView removeFromSuperview];
        
        self.pllistViewController = [[playlistViewController alloc]init];
        
        self.pllistView = [[playlistView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        self.pllistViewController.view = self.pllistView;
        
        [self.mainViewController.view insertSubview:self.pllistViewController.view belowSubview:self.plbackView]; 
        
        [self.pllistView initGridParams];
        [self.pllistView loadPlaylistView:[[SPSession sharedSession] userPlaylists]];
        [self.pllistView checkPlLoad:[[SPSession sharedSession]userPlaylists]];
        
        
        
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
    
    SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
    
    if (![SPSession sharedSession].playing){
        [self playnewTrack:track];
        
    }
}

-(void)addSongToPlaybackCue:(int)selRow:(int)selSection{
    
    NSLog(@"addSongtoplaybackcue %d",[Shared sharedInstance].curClickedPl);
    
    SPPlaylistContainer *container = [[SPSession sharedSession] userPlaylists];
    
    SPPlaylist *playlistDetail = [container.playlists objectAtIndex:[Shared sharedInstance].curClickedPl];
    
    if ([playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        
        SPPlaylistFolder *plFolder = [container.playlists objectAtIndex:[Shared sharedInstance].curClickedPl];
        SPPlaylist *pl = [plFolder.playlists objectAtIndex:selSection];
        playlistDetail = pl;
        
    }
    SPPlaylistItem *playlistItem;
    
    NSURL *trackURL;
    
    playlistItem = [playlistDetail.items objectAtIndex:selRow];
    
    trackURL = playlistItem.itemURL;
    
    NSString *urlStr =[trackURL absoluteString];
    
    NSLog(@"track url: %@",urlStr);
    
    [[Shared sharedInstance].masterCue addObject:trackURL];
    
    for (NSURL *str in [Shared sharedInstance].masterCue){
        NSLog(@"str:%@",str);
    }
    
    SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
    
    if (![SPSession sharedSession].playing){
        [self playnewTrack:track];
        
    }
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
        [self.mainViewController.view bringSubviewToFront:self.pllistView];
        self.playbackLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor whiteColor];
        
        self.searchLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor whiteColor];
        
        self.playlistLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor blackColor];
        
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (lbl.tag == 11){
        [self.mainViewController.view bringSubviewToFront:self.plbackView];
        [self.mainViewController.view bringSubviewToFront:self.secChView];
        self.playbackLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor blackColor];
        
        self.searchLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor whiteColor];
        
        self.playlistLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor whiteColor];
        
        [self.searchController dismissViewControllerAnimated:YES completion:nil];
        
        
    }
    else if (lbl.tag == 12){
        [self.playbackManager checkavailableOutputRoutes];
        
        //  [self.mainViewController.view bringSubviewToFront:self.spSearchView.view];
        self.playbackLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playbackLabel.textColor = [UIColor whiteColor];
        
        self.searchLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        self.searchLabel.textColor = [UIColor blackColor];
        
        self.playlistLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        self.playlistLabel.textColor = [UIColor whiteColor];
        
        [self.mainViewController presentViewController:self.searchController animated:YES completion:nil];
        
    }
}


-(void)userLogout{
    
    [[SPSession sharedSession] logout];
    
    
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    
	// Invoked by SPSession after a failed login.
    
	// Forward to the login view controller
	if ([self.mainViewController.modalViewController respondsToSelector:_cmd])
		[self.mainViewController.modalViewController performSelector:_cmd withObject:aSession withObject:error];
}



-(void)sessionDidLogOut:(SPSession *)aSession {
    NSLog(@"session logged out");
    self.cueView.hidden = YES;
    self.playlistLabel.hidden = YES;
    self.searchLabel.hidden = YES;
    self.playbackLabel.hidden = YES;
    
   // [self.pllistView removeObservers];
    
    for (UIView *view in [self.pllistViewController.view subviews]){
        
        [view removeFromSuperview];
    }
    [self.pllistViewController.view removeFromSuperview];
    
    self.pllistViewController = nil;
    
    [self.mainViewController presentModalViewController:[[[LoginViewController alloc] init] autorelease]
											   animated:YES];
}
-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
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
    [_loadingView release];
    [_playlistLabel release];
    [_playbackLabel release];
    [_searchLabel release];
    [_pllistView release];
    [_plbackView release];
    [_loadPlaylist release];
 	[_currentTrack release];
	[_playbackManager release];
	[_window release];
	[_mainViewController release];
	[_navigationController release];
    [_secChView release];
    [super dealloc];
}
@end

