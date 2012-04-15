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
#import "masterCueTableView.h"
#import "searchTableViewController.h"
#import "searchViewController.h"
#import "playlistViewController.h"
#import "secondChannelUIViewController.h"
#import "playlistViewController.h"
#import "cueViewController.h"
#import "playbackViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, SPSessionDelegate> {
    UIViewController *_mainViewController;
    UIWindow *window;
	audioControl *_playbackManager;
	SPTrack *_currentTrack;
    UINavigationController *navigationController;
    playlistViewController *plViewController;
    searchViewController *searchController;
    UILabel *playlistLabel;
    UILabel *playbackLabel;
    UILabel *searchLabel;
    UIView *loadingView;
    searchTableViewController *searchTViewController;
    BOOL chTwoActive;
    secondChannelUIViewController *chTwoViewController;
    UIView *airplayIcon;
    cueViewController *cueController;
    UIViewController *logoutViewController;
    playbackViewController *plbackViewController;
    UIButton *userTxtBtn;
    
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *mainViewController;
@property (nonatomic) BOOL chTwoActive; 

@property (nonatomic, retain) UIButton *userTxtBtn;

@property (nonatomic, retain) SPTrack *currentTrack;
@property (nonatomic, retain) audioControl *playbackManager;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) SPPlaylist *loadPlaylist;
@property (nonatomic, retain) UIViewController *logoutViewController;

@property (nonatomic, retain) playlistViewController *plViewController;
@property (nonatomic, retain) playbackViewController *plbackViewController;

@property (nonatomic, retain) UILabel *playlistLabel;
@property (nonatomic, retain) UILabel *playbackLabel;
@property (nonatomic, retain) UILabel *searchLabel;

@property (nonatomic, retain) cueViewController *cueController;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, retain) searchTableViewController *searchTViewController;

@property (nonatomic, retain) searchViewController *searchController;
@property (nonatomic, retain) secondChannelUIViewController *chTwoViewController;

@property (nonatomic, retain) UIView *airplayIcon;

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


