//
//  playlistViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface playlistViewController : UIViewController{
    SPPlaylistContainer *plContainer;
    SPPlaylist *_loadPlaylist;
    NSMutableArray *plCallback;
    SPPlaylist *plCallb;
    SPTrack *_trackimg;
    UIViewController *plViewController;
    UIImage *_tempImg;
    SPPlaylistItem *loadItem;
    sp_linktype itemCallback;
    NSMutableArray *missedPlArray;
    NSMutableArray *starredTracksArray;
   
    UIScrollView *plMainView;
    
    int plCounter;
    int margin;
    CGFloat x;
    CGFloat y;
    CGFloat height;
    CGFloat width;
    int nrOfPl;
    int rows;
    int rowCount;
    int columns;
    int parentWidth;
    int parentHeight;
    
    int tagAdd;
    BOOL createStarredBox;
}


@property (nonatomic, retain) UIScrollView *plMainView;

@property (nonatomic, retain) SPPlaylistContainer *plContainer;
@property (nonatomic, retain) SPPlaylist *loadPlaylist;
@property (nonatomic, retain) NSMutableArray *plCallback;
@property (nonatomic, retain) SPTrack *trackimg;
@property (nonatomic, retain) UIViewController *plViewController;
@property (nonatomic, retain) UIImage *tempImg;
@property (nonatomic, retain) SPPlaylistItem *loadItem;
@property (nonatomic) sp_linktype itemCallback;
@property (nonatomic, retain) SPPlaylist *plCallb;


- (void)initGridParams;
- (void)loadPlaylistView:(SPPlaylistContainer *)playlistContainer;
- (void)setImage:(UIImage *)imageToSet track:(SPTrack *)track;
- (void)setLoadedTrack:(SPPlaylist *)pl;
- (void)createnewplBox:(UIImage *)img;
- (void)plClicked:(id)sender;
- (void)checkPlLoad:(SPPlaylistContainer *)plCon;
- (NSString *)getTrackStr:(SPPlaylistItem *)plItem;
- (void)removeObservers;
- (void)setMissedPlaylists;
- (void)checkMissedPlaylists:(SPPlaylist *)pl;
- (void)createStarredTracksPlaylist:(SPPlaylistContainer *)playlistContainer;
- (void)starredClicked;


@end
