//
//  playbackView.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "effectController.h"
#import "CocoaLibSpotify.h"



@interface playbackView : UIView{

    UILabel *artistLbl;
    UILabel *titleLbl;
    UIButton *selBtn;
    UIView *trackControlBG;
    UIView *trackControlFG;
    UIView *secChannelView;
    double durationNum;
    UIView *controlView;
   
    
   
}

@property(nonatomic, retain) UILabel *artistLbl;
@property(nonatomic, retain) UILabel *titleLbl;
@property(nonatomic, retain) UIButton *selBtn;
@property(nonatomic, retain) UIView *trackControlBG;
@property(nonatomic, retain) UIView *trackControlFG;
@property(nonatomic, retain) UIView *controlView;




- (void)playnextTrack:(id)sender;
- (void)playprevTrack:(id)sender;
- (void)setTrackTitleAndArtist:(SPTrack *)track;
- (void)showEffectOptionsPitch:(UILongPressGestureRecognizer *)gestureRecognizer;
- (void)setTimePitchEffect:(id)sender;
- (void)removeTimePitchPopup;
- (void)playTrack:(id)sender;
- (void)stopTrack:(id)sender;
- (void)pauseTrack:(id)sender;
- (void)setPlayduration:(double)length;
- (void)updatePlayduration:(double)val;
- (void)trackdurationSwipe:(UISwipeGestureRecognizer *)gesture;


@end
