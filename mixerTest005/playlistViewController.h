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
    SPPlaylist *plCallb;
    UIViewController *plViewController;
    NSMutableArray *starredTracksArray;
   
    UIScrollView *plMainView;
    
    int plCounter;
    int margin;
    CGFloat x;
    CGFloat y;
    CGFloat height;
    CGFloat width;
    double nrOfPl;
    double rows;
    int rowCount;
    double columns;
    int parentWidth;
    int parentHeight;
    
    BOOL createStarredBox;
    UIView *loadingView;
    BOOL orientationIsLandscape;
    
    BOOL playlistsLoaded;
}


@property (nonatomic, retain) UIScrollView *plMainView;

@property (nonatomic, retain) UIViewController *plViewController;


- (void)initGridParams;
- (void)plClicked:(id)sender;
- (NSString *)getTrackStr:(SPPlaylistItem *)plItem;
- (void)createStarredTracksPlaylist:(SPPlaylistContainer *)playlistContainer;
- (void)starredClicked;
- (void)setplaylistsloaded:(BOOL)val;



@end
