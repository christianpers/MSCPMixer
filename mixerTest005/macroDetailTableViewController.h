//
//  macroDetailTableViewController.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface macroDetailTableViewController : UITableViewController{
    
    NSArray *detailArr;
}

@property (nonatomic, retain) NSArray *detailArr;

-(void)cancel:(id)sender;
@end
