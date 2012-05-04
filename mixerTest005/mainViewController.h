//
//  mainViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewController.h"
#import "playlistViewController.h"
#import "playbackViewController.h"
#import "tabbarController.h"

@interface mainViewController : UIViewController{
    
    UIView *loadingView;
    BOOL appStarted;
    playlistViewController *plViewController;
    searchViewController *searchController;
    playbackViewController *plbackViewController;
    tabbarController *tabController;
    
    BOOL landscapeMode;
    
}

@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, retain) playlistViewController *plViewController;
@property (nonatomic, retain) playbackViewController *plbackViewController;
@property (nonatomic, retain) searchViewController *searchController;
@property (nonatomic, retain) tabbarController *tabController;
@property (nonatomic) BOOL landscapeMode;

- (void)activatePortraitMode;
- (void)activateLandscapeMode;
- (void)toggleGUIhidden:(BOOL)sethidden;


@end
