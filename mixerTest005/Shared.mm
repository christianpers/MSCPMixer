//
//  Shared.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Shared.h"

static Shared* sharedInstance;

@implementation Shared

@synthesize masterCue;
@synthesize curClickedPl;
@synthesize curVariSpeedEffect;
@synthesize effectgridX,effectgridY;
@synthesize hasLoggedin;
@synthesize currTrackPos;
@synthesize relogin;


+ (Shared*)sharedInstance
{
    if ( !sharedInstance)
    {
        sharedInstance = [[Shared alloc] init];
        
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if ( self )
    {
        masterCue = [[NSMutableArray alloc] init];
        curClickedPl = 0;
        curVariSpeedEffect = 1;
        effectgridY = 0;
        effectgridX = 0;
        hasLoggedin = false;
        currTrackPos = 0;
        relogin = false;
    }
    return self;
}

@end