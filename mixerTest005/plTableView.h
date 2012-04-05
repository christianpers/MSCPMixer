//
//  plTableView.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"


@interface plTableView : UITableView 
<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *dataArray;

}
@property (nonatomic, retain) NSMutableArray *dataArray;

// Change this init function to whatever is convenient to you.
- (id) initWithFrame:(CGRect)theFrame 
        andDataArray:(NSMutableArray*)data;
    
@end
