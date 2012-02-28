//
//  effectController.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "effectgridView.h"

@interface effectController : UIView{
    
    effectgridView *gridView;
    
}

@property (nonatomic, retain) effectgridView *gridView;

- (void)variSpeedUnit;
- (void)lopassUnit;
- (void)hipassUnit;
- (void)reverbUnit;
- (void)masterVol;
- (void)drawEffectGrid:(int)tag;
- (void)trackControl;


@end
