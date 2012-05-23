//
//  searchViewController.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "searchTableViewController.h"
#import "searchmodel.h"

@interface searchViewController : UIViewController{
    
    UITextField *searchField;
    int searchCount;
    BOOL noResult;
    UIButton *searchBtn;
    UIImageView *mscpImg;
    BOOL appStarted;
    searchmodel *model;
}

@property (nonatomic, retain) UITextField *searchField;
@property (nonatomic, retain) searchmodel *model;



-(void)searchClicked:(UIButton *)btn;
-(void)closeResultView;
-(void)createDetailView:(NSMutableArray *)resultArr;
- (void)initTableView:(NSMutableArray *)returnArr;

- (void)setlandscapemode;
- (void)setportraitmode;

- (void)showNoResult;

@end
