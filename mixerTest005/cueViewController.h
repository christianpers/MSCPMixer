//
//  cueViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "masterCueTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface cueViewController : UIViewController{
    
    
    UIPanGestureRecognizer *masterCuePan;
    masterCueTableView *tableView;
    UIButton *editbtn;
    UIButton *clearbtn;
}

@property (nonatomic, retain) UIPanGestureRecognizer *masterCuePan;
@property (nonatomic, retain) masterCueTableView *tableView;
@property (nonatomic, retain) UIView *editbtn;
@property (nonatomic, retain) UIButton *clearbtn;


- (void)editMasterCueList:(id)sender;
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)toggleMasterCueView;
- (void)removeCueChOne:(id)sender;

@end
