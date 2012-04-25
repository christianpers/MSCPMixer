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

@interface searchViewController : UIViewController{
    
    UITextField *searchField;
    SPSearch *search;
    int searchCount;
    BOOL noResult;
}

@property (nonatomic, retain) UITextField *searchField;
@property (nonatomic, retain) SPSearch *search;

-(void)searchClicked:(UIButton *)btn;
-(void)createSearchList:(SPSearch *)returnObj;
-(void)closeResultView;
-(void)createDetailView:(NSMutableArray *)resultArr;


@end
