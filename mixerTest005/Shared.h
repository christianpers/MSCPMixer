//
//  Shared.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shared : NSObject
{
    NSMutableArray *masterCue;
    int curClickedPl;
    int curVariSpeedEffect;
    int effectgridX;
    int effectgridY;
    BOOL hasLoggedin;
    Float64 currTrackPos;
}

@property (nonatomic, retain) NSMutableArray *masterCue;
@property (nonatomic) int curClickedPl;
@property (nonatomic) int curVariSpeedEffect;
@property (nonatomic) int effectgridX;
@property (nonatomic) int effectgridY;
@property (nonatomic) BOOL hasLoggedin;
@property (nonatomic) Float64 currTrackPos;

+ (Shared*)sharedInstance;

@end
