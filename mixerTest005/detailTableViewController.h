//
//  detailTableViewController.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPAlbumBrowse.h"
#import "macroDetailTableViewController.h"

@interface detailTableViewController : UITableViewController{
    
    NSArray *detailArr;
    SPAlbumBrowse *albBrowse;
    UIView *loadingView;
}

@property (nonatomic, retain) NSArray *detailArr;
@property (nonatomic, retain) SPAlbumBrowse *albBrowse;
@property (nonatomic, retain) UIView *loadingView;

-(void)cancel:(id)sender;
@end
