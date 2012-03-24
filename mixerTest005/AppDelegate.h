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
#import "playbackView.h"
#import "searchTableViewController.h"
#import "searchViewController.h"
#import "playlistViewController.h"
#import "secondChannelView.h"
#import "secondChannelUIViewController.h"
#import "playlistViewController.h"
#import "cueViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, SPSessionDelegate> {
    UIViewController *_mainViewController;
    UIWindow *window;
	audioControl *_playbackManager;
	SPTrack *_currentTrack;
    UINavigationController *navigationController;
    playlistViewController *plViewController;
    playbackView *plbackView;
    searchViewController *searchController;
    UILabel *playlistLabel;
    UILabel *playbackLabel;
    UILabel *searchLabel;
    UIView *loadingView;
    searchTableViewController *searchTViewController;
    secondChannelView *secChView;
    BOOL chTwoActive;
    secondChannelUIViewController *chTwoViewController;
    UIView *airplayIcon;
    cueViewController *cueController;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *mainViewController;
@property (nonatomic) BOOL chTwoActive; 

@property (nonatomic, retain) SPTrack *currentTrack;
@property (nonatomic, retain) audioControl *playbackManager;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) SPPlaylist *loadPlaylist;

@property (nonatomic, retain) playlistViewController *plViewController;
@property (nonatomic, retain) playbackView *plbackView;

@property (nonatomic, retain) UILabel *playlistLabel;
@property (nonatomic, retain) UILabel *playbackLabel;
@property (nonatomic, retain) UILabel *searchLabel;

@property (nonatomic, retain) cueViewController *cueController;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, retain) searchTableViewController *searchTViewController;

@property (nonatomic, retain) searchViewController *searchController;
@property (nonatomic, retain) secondChannelView *secChView;
@property (nonatomic, retain) secondChannelUIViewController *chTwoViewController;

@property (nonatomic, retain) UIView *airplayIcon;

- (void)userLogout;
- (void)initLoadGUI;
- (void)ativateSearchView;
- (void)showLogin;

- (void)createLoadingPlView;

- (void)playnewTrack:(SPTrack *)track;

- (void)addSongFromSearch:(NSURL *)trackURL;
- (void)addSongToPlaybackCue:(int)selRow :(int)selSection;
- (void)removeSongFromPlaybackCue:(int)selRow;

- (NSString *)getTrackStr:(SPPlaylistItem *)plItem;

- (void)setTrackPosition:(double)newVal;
- (void)newChannel:(UITapGestureRecognizer *)gesture;


@end


