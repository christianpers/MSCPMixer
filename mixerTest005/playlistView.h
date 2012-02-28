//
//  playlistView.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface playlistView : UIScrollView{
    SPPlaylistContainer *plContainer;
    SPPlaylist *_loadPlaylist;
    NSMutableArray *plCallback;
    SPTrack *_trackimg;
    UIViewController *plViewController;
    UIImage *_tempImg;

}

@property (nonatomic, retain) SPPlaylistContainer *plContainer;
@property (nonatomic, retain) SPPlaylist *loadPlaylist;
@property (nonatomic, retain) NSMutableArray *plCallback;
@property (nonatomic, retain) SPTrack *trackimg;
@property (nonatomic, retain) UIViewController *plViewController;
@property (nonatomic, retain) UIImage *tempImg;

- (void)initGridParams;
- (void)loadPlaylistView:(SPPlaylistContainer *)playlistContainer;
- (void)setImage:(UIImage *)imageToSet track:(SPTrack *)track;
- (void)setLoadedTrack:(SPPlaylist *)pl;
- (void)createnewplBox:(UIImage *)img;
- (void)plClicked:(id)sender;
- (void)checkPlLoad:(SPPlaylistContainer *)plCon;
- (NSString *)getTrackStr:(SPPlaylistItem *)plItem;
- (void)removeObservers;

@end
