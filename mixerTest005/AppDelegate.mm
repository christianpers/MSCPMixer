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
@synthesize loadPlaylist = loadPlaylist;
@synthesize chTwoActive;
@synthesize trackimg;
@synthesize imageContainer;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[self.window makeKeyAndVisible];
    
    [self.window setRootViewController:self.mainViewController];
    
    self.mainViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
   	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size] 
											   userAgent:@"MSCP.mixerTest005"
												   error:nil];
    
	self.playbackManager = [[[audioControl alloc] initWithPlaybackSession:[SPSession sharedSession]] autorelease];
    
	[self addObserver:self forKeyPath:@"currentTrack.duration" options:0 context:nil];
	[self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:0 context:nil];
  //  [self addObserver:self forKeyPath:@"currentTrackCh2.duration" options:0 context:nil];
	[self addObserver:self forKeyPath:@"playbackManager.trackPositionCh2" options:0 context:nil];
    
    
    [[SPSession sharedSession] setDelegate:self];
    
    [self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
  
    return YES;
}

-(void)showLogin {
	[self.mainViewController presentModalViewController:[[[LoginViewController alloc] init] autorelease]
											   animated:NO];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.duration"]) {
	//	self.positionSlider.maximumValue = self.currentTrack.duration;
        [self.mainViewController.plbackViewController setPlayduration:self.currentTrack.duration];
//        NSLog(@"duration set");
	} else if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
		// Only update the slider if the user isn't currently dragging it.
	//	if (!self.positionSlider.highlighted)
	//		self.positionSlider.value = self.playbackManager.trackPosition;
     //   NSLog(@"trackposition: %f",self.playbackManager.trackPosition);
        [self.mainViewController.plbackViewController updatePlayduration:self.playbackManager.trackPosition];
    } else if ([keyPath isEqualToString:@"playbackManager.trackPositionCh2"]) {
		// Only update the slider if the user isn't currently dragging it.
        //	if (!self.positionSlider.highlighted)
        //		self.positionSlider.value = self.playbackManager.trackPosition;
        //   NSLog(@"trackposition: %f",self.playbackManager.trackPosition);
        [self.mainViewController.plbackViewController updatePlaydurationCh2:self.playbackManager.trackPositionCh2];
    }
    
    else if ([keyPath isEqualToString:@"self.trackimg.album.cover.image"]) {
        tempImg = trackimg.album.cover.image;
        
        if (trackimg.album.cover.isLoaded){
            NSLog(@"loaded image nr: %d",plCounter);
            
            SPPlaylist *playlistDetail = [plContainer.playlists objectAtIndex:plCounter];
            SPPlaylistFolder *playlistFolder;
            NSString *plName;
            
            if ([playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
                playlistFolder = [plContainer.playlists objectAtIndex:plCounter];
                playlistDetail = [playlistFolder.playlists objectAtIndex:0];
                plName = playlistFolder.name;
            }else {
                plName = playlistDetail.name;
            }
            NSURL *idURL = playlistDetail.spotifyURL;
            NSMutableArray *innerDataContainer = [[NSMutableArray alloc]init];
            NSNumber *currplNum = [NSNumber numberWithInt:plCounter];
            [innerDataContainer addObject:currplNum];
            [innerDataContainer addObject:plName];
            [innerDataContainer addObject:tempImg];
            [innerDataContainer addObject:idURL];
      //      [imageContainer addObject:innerDataContainer];
            [self insertObject:innerDataContainer];
            [innerDataContainer release];
            
 //           [self createnewplBox:tempImg];
            if (plCounter < nrOfPl){
                plCounter++;
                [self checkPlLoad:plContainer];    
            }
        }
	}
    else if ([keyPath isEqualToString:@"self.loadPlaylist.items"]){
        //  self.plCallback = self.loadPlaylist.items;
        plCallb = self.loadPlaylist;
        if(self.loadPlaylist.isLoaded){
            
            [self setLoadedTrack:self.loadPlaylist];
        }
    }
    
    else if ([keyPath isEqualToString:@"imageContainer"]) {
        NSLog(@"test");
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
    [self.mainViewController.tabController.cueController.tableView reloadData];
    
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
            
            [self.mainViewController.tabController.cueController.tableView reloadData];
            
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
    [[Shared sharedInstance].masterCue removeAllObjects];
    
}

-(void)checkPlLoad:(SPPlaylistContainer *)plCon{
    
    SPPlaylist *playlistDetail = [plCon.playlists objectAtIndex:plCounter];
    
    if (![playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        
        if (!playlistDetail.isLoaded){
            self.loadPlaylist = playlistDetail;
        }
        else{
            [self setLoadedTrack:playlistDetail];
        }
    }
    else {
        SPPlaylistFolder *plFolder = (SPPlaylistFolder *)playlistDetail;
        SPPlaylist *pl = [plFolder.playlists objectAtIndex:0];
        self.loadPlaylist = pl;
    }
}

-(void)setLoadedTrack:(SPPlaylist *)pl{
    
    SPPlaylist *playlistDetail = pl;
    SPPlaylistFolder *playlistFolder;
    SPPlaylistItem *playlistItem;
    Boolean foundValidTrack = NO;
    NSString *plName;
    
    NSURL *trackURL;
    
    //check if folderSPPlaylistFolder
    if ([playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        playlistFolder = [plContainer.playlists objectAtIndex:plCounter];
        playlistDetail = [playlistFolder.playlists objectAtIndex:0];
        plName = playlistFolder.name;
        
    }else {
        plName = playlistDetail.name;
    }
    
    NSLog(@"fucking shit: %@",playlistDetail.name);
    for (SPPlaylistItem *trackTest in playlistDetail.items){
        if (!foundValidTrack){
            if(trackTest.itemURLType == SP_LINKTYPE_TRACK){
                SPTrack *trackAvailTest = [[SPSession sharedSession] trackForURL:trackTest.itemURL];
                if (trackAvailTest.availability == 1){
                    foundValidTrack = YES;
                    playlistItem = trackTest;
                    
                }
                
            }
        }
    }
    if (!foundValidTrack){
        
        NSNumber *num = [NSNumber numberWithInt:plCounter];
        [self performSelectorOnMainThread:@selector(setemptyPlaylist:) withObject:num waitUntilDone:NO];
        
        plCounter++;
        
        [self checkPlLoad:plContainer];
        
    }
    else{
        trackURL = playlistItem.itemURL;
        SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
        if (track.availability == 1){
            if (!track.album.cover.isLoaded) {
                CGImageRef cgref = [track.album.cover.image CGImage];
                CIImage *cim = [track.album.cover.image CIImage];
                
                if (cim == nil && cgref == NULL)
                {
                    NSLog(@"no underlying data");
                    self.trackimg = track;
                    // [self loadImage:track.album];
                }
                else{
                    NSLog(@"weird place");
                    //      [self createnewplBox:track.album.cover.image];
                    if (plCounter < nrOfPl){
                        [self checkPlLoad:plContainer];    
                    }
                    
                }

            }else {
                NSURL *idURL = playlistDetail.spotifyURL;
                NSMutableArray *innerDataContainer = [[NSMutableArray alloc]init];
                NSNumber *currplNum = [NSNumber numberWithInt:plCounter];
                [innerDataContainer addObject:currplNum];
                [innerDataContainer addObject:plName];
                [innerDataContainer addObject:track.album.cover.image];
                [innerDataContainer addObject:idURL];
         //       [imageContainer addObject:innerDataContainer];
         //       [imageContainer insertObject:innerDataContainer atIndex:[imageContainer count]];
                [self insertObject:innerDataContainer];
                
                [innerDataContainer release];
                
                plCounter++;
                [self checkPlLoad:plContainer];
            }
            
                       
        }
        else
        {
            NSNumber *num = [NSNumber numberWithInt:plCounter];
            [self performSelectorOnMainThread:@selector(setemptyPlaylist:) withObject:num waitUntilDone:NO];
            plCounter++;
            [self checkPlLoad:plContainer];
            
        }   
        
    }
}

/* array kvo helpers imagecontainer */

- (NSUInteger)countOfArr {       
    return [self.imageContainer count];
}    

- (id)objectInArrAtIndex:(NSUInteger)index {       
    return [self.imageContainer objectAtIndex:index];
}    

- (void)insertObject:(NSMutableArray *)obj{       
  //  [self.imageContainer insertObject:obj atIndex:index];
//    NSMutableArray *arr = [NSMutableArray arrayWithArray:obj];
 //   UIImage *img = [arr objectAtIndex:0];
 //   NSString *plTitle = [arr objectAtIndex:1];
    [self performSelectorOnMainThread:@selector(setplaylistImage:) withObject:obj waitUntilDone:NO];
  //  [self.imageContainer willChangeValueForKey:@"imageContainer"];
  //  [self.imageContainer didChangeValueForKey:@"imageContainer"];
    
} 

- (void)setplaylistImage:(NSMutableArray *)arr{
    [self.mainViewController.plViewController setArrayOnPlaylist:arr];    
    
}

- (void)setemptyPlaylist:(NSNumber *)num{
    
    NSInteger intnum = [num integerValue];
    [self.mainViewController.plViewController setemptyPlaylist:intnum];
}

- (void)removeObjectFromArrAtIndex:(NSUInteger)index {       
    [self.imageContainer removeObjectAtIndex:index];
}    

- (void)replaceObjectInArrAtIndex:(NSUInteger)index withObject:(id)obj {       
    [self.imageContainer replaceObjectAtIndex:index withObject:obj];
} 


NSUInteger playlistsAttempts;
NSUInteger loadplAttempts;
NSUInteger loadTrack;

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    
    if (![Shared sharedInstance].hasLoggedin){
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
            
            [self.mainViewController.loadingView removeFromSuperview];
            plContainer = [[SPSession sharedSession] userPlaylists];
            NSLog(@"logging in problem %d",[[plContainer playlists]count]);
        }
    }
    else{
        NSLog(@"loaded playlists");
        
        self.imageContainer = [NSMutableArray array];
        [self.mainViewController.loadingView removeFromSuperview];
        [self.mainViewController.plViewController initPlContainer:[[SPSession sharedSession] userPlaylists]];

  }  
}

- (void)startloadingOfPlaylists{
  //  [self.mainViewController.plViewController initGridParams];
  //  [self.mainViewController.plViewController loadplaylists];
    
    [self doLoadingOnNewThread];
    
}

- (void) doLoadingOnNewThread {
	[NSThread detachNewThreadSelector:@selector(startTheProcess) toTarget:self withObject:nil];
}
- (void) startTheProcess {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self addObserver:self forKeyPath:@"self.loadPlaylist.items" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.trackimg.album.cover.image" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    plCounter = 0;
    plContainer = [[SPSession sharedSession] userPlaylists];
    NSLog(@"length container:%d",[plContainer.playlists count]);
    nrOfPl = [[plContainer playlists] count];
    
    [self checkPlLoad:plContainer];
    
   
   
    
	[pool release];
}

/*----playlist pictures loader functions-----*/

-(void)sessionLostPlayToken:(SPSession *)session;
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost play token" message:@"That means another client is playing music with this account, so this one'll have to stop playing." delegate:nil cancelButtonTitle:@"Arrrrggghhh! My music!" otherButtonTitles:nil];
	[alert show];
    
    self.playbackManager.isPlaying = NO;
    [self.playbackManager stopAUGraph];
	
}

-(void)addSongFromSearch:(NSURL *)trackURL{
    
    [[Shared sharedInstance].masterCue addObject:trackURL];
    
    [self.mainViewController.tabController.cueController.tableView reloadData];
    
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
    
    [self.mainViewController.tabController.cueController.tableView reloadData];
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


-(void)setNotPlaying{
    
    [self.playbackManager setIsPlaying:NO];
}

-(void)userLogout{
    [self.mainViewController.tabController removeLogoutView];
    
    
    if ([SPSession sharedSession].isPlaying){
        
        [self.playbackManager fadeOutMusicCh1];
        // [self.playbackManager setIsPlaying:NO];
        [self performSelector:@selector(setNotPlaying) withObject:nil afterDelay:.6];
        
    }
    
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
    
    [self removeObserver:self forKeyPath:@"self.loadPlaylist.items"];
	[self removeObserver:self forKeyPath:@"self.trackimg.album.cover.image"];
    
    [self.mainViewController removeGUI];
    [self.mainViewController.plViewController setplaylistsloaded:NO];
    
    [self showLogin];
    [self removeGUI];
    [self.mainViewController.tabController.cueController.tableView reloadData];
    
    [self.playbackManager stopAUGraph];
    for (UIView *view in [self.mainViewController.plViewController.view subviews]){
        
        [view removeFromSuperview];
    }
 //   [self.mainViewController.plViewController.plMainView removeFromSuperview];
    [Shared sharedInstance].relogin = true;
    
    
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
    [imageContainer release];
    [loadPlaylist release];
 	[_currentTrack release];
	[_playbackManager release];
	[_window release];
	[_mainViewController release];
	[super dealloc];
}
@end

