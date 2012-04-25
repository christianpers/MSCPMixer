//
//  reSearchTableViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "trackTableViewController.h"


@interface reSearchTableViewController : UITableViewController{
    
    NSMutableArray *detailArr;
    SPAlbumBrowse *albBrowse;
    SPArtistBrowse *artBrowse;
    UIView *loadingView;
}

@property (nonatomic, retain) NSMutableArray *detailArr;
@property (nonatomic, retain) SPAlbumBrowse *albBrowse;
@property (nonatomic, retain) SPArtistBrowse *artBrowse;
@property (nonatomic, retain) UIView *loadingView;

-(void)cancel:(id)sender;

@end
