//
//  AppDelegate.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "audioControl.h"
#import "plTableView.h"
#import "searchViewController.h"
#import "playlistViewController.h"
#import "cueViewController.h"
#import "playbackViewController.h"
#import "mainViewController.h"

#import "tabbarController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, SPSessionDelegate> {
    mainViewController *_mainViewController;
    UIWindow *window;
	audioControl *_playbackManager;
	SPTrack *_currentTrack;
    playlistViewController *plViewController;
    UIView *loadingView;
    BOOL chTwoActive;
    UIView *airplayIcon;
    cueViewController *cueController;
    UIViewController *logoutViewController;
    playbackViewController *plbackViewController;
    UIButton *userTxtBtn;
    tabbarController *tabController;
    UIViewController *loadviewController;
    
    SPTrack *trackimg;
    UIImage *tempImg;
    int plCounter;
    int nrOfPl;
    SPPlaylist *plCallb;
    NSMutableArray *imageContainer;
    SPPlaylistContainer *plContainer;
    NSMutableArray *missedPlArray;
    SPPlaylist *loadPlaylist;
    
    
    
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet mainViewController *mainViewController;
@property (nonatomic) BOOL chTwoActive; 

@property (nonatomic, retain) UIButton *userTxtBtn;

@property (nonatomic, retain) SPTrack *currentTrack;
@property (nonatomic, retain) audioControl *playbackManager;
@property (nonatomic, retain) SPPlaylist *loadPlaylist;
@property (nonatomic, retain) SPTrack *trackimg;
@property (nonatomic, retain) UIViewController *logoutViewController;

@property (nonatomic, retain) cueViewController *cueController;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, retain) searchViewController *searchController;
@property (nonatomic, retain) UIView *airplayIcon;
@property (nonatomic, retain) tabbarController *tabController;

- (void)userLogout;
- (void)initLoadGUI;
- (void)ativateSearchView;
- (void)showLogin;
- (void)showlogoutViewController;
- (void)removeLogoutView;

- (void)createLoadingPlView;

- (void)playnewTrack:(SPTrack *)track;

- (void)addSongFromSearch:(NSURL *)trackURL;
- (void)removeSongFromPlaybackCue:(int)selRow;

- (NSString *)getTrackStr:(SPPlaylistItem *)plItem;

- (void)setTrackPosition:(double)newVal;
- (void)newChannel:(UITapGestureRecognizer *)gesture;
- (void)addSongToCueChannelOne:(NSURL *)trackURL;

- (void)handlecuetrackSelect:(SPTrack *)track;
- (void)callfadeInMusicCh1;
- (void)setNotPlaying;

@end


