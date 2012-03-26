//
//  effectViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "effectgridView.h"

@interface effectViewController : UIViewController{
    
    effectgridView *gridView;
    BOOL aboveMiddleY;
    AudioUnitParameterValue paramVal1;
    AudioUnitParameterValue paramVal2;
    float setY;
    float setX;
    CGSize parentSize;
}

@property (nonatomic, retain) effectgridView *gridView;

- (void)variSpeedUnit;
- (void)lopassUnit;
- (void)hipassUnit;
- (void)reverbUnit;
- (void)masterVolCh1;
- (void)drawEffectGrid:(int)tag;
- (void)trackControl;

//ch two
- (void)lopassUnitChTwo;
- (void)hipassUnitChTwo;
- (void)variSpeedUnitChTwo;
- (void)masterVolCh2;

@end
