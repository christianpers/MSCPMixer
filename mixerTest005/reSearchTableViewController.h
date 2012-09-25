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
    UIView *loadingView;
    
    NSInteger offsetAlbum;
    NSInteger offsetTracks;
    NSInteger offsetArtists;
    NSInteger getmoreSectionNum;
}

@property (nonatomic, retain) NSMutableArray *detailArr;
@property (nonatomic, retain) UIView *loadingView;

-(void)cancel:(id)sender;

@end
