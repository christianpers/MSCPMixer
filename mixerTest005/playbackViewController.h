//
//  playbackViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import "effectController.h"
#import "CocoaLibSpotify.h"
#import "fftAnalyzerView.h"
#import <QuartzCore/QuartzCore.h>

@interface playbackViewController : UIViewController{
    
    UILabel *artistLbl;
    UILabel *titleLbl;
    UIButton *selBtn;
    UIView *trackControlBG;
    UIView *trackControlFG;
    UIView *secChannelView;
    double durationNum;
    UIView *controlView;
    effectController *timepitchController;
    effectController *lopassController;
    effectController *hipassController;
    effectController *channelOneVolController;
    UIView *effectContainerView;
    //fft analyzing
    fftAnalyzerView *fftView;
}

@property(nonatomic, retain) UILabel *artistLbl;
@property(nonatomic, retain) UILabel *titleLbl;
@property(nonatomic, retain) UIButton *selBtn;
@property(nonatomic, retain) UIView *trackControlBG;
@property(nonatomic, retain) UIView *trackControlFG;
@property(nonatomic, retain) UIView *controlView;
@property(nonatomic, retain) UIView *effectParentView;

@property(nonatomic, retain) effectController *timepitchController;
@property(nonatomic, retain) effectController *lopassController;
@property(nonatomic, retain) effectController *hipassController;
@property(nonatomic, retain) effectController *channelOneVolController;
@property(nonatomic, retain) fftAnalyzerView *fftView;



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

- (void)callmainplaytrack:(SPTrack *)track;
- (void)callfadeInMusicCh1;
- (void)resetTrackTitleAndArtist;

- (void)setmixerModeOn;
- (void)setonechannelmodeOn;

@end
