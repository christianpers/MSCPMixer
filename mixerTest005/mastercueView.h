//
//  mastercueView.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "masterCueTableView.h"

@interface mastercueView : UIView{
    
    UIPanGestureRecognizer *masterCuePan;
    masterCueTableView *tableView;
    UIButton *editbtn;
    
}

@property (nonatomic, retain) UIPanGestureRecognizer *masterCuePan;
@property (nonatomic, retain) masterCueTableView *tableView;
@property (nonatomic, retain) UIView *editbtn;


- (void)editMasterCueList:(id)sender;
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer;
- (void)toggleMasterCueView;

@end
