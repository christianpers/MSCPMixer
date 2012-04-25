//
//  trackTableViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface trackTableViewController : UITableViewController{
    
    NSArray *detailArr;
}
@property (nonatomic, retain) NSArray *detailArr;

-(void)cancel:(id)sender;

@end
