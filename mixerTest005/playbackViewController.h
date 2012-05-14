//
//  playbackViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "effectController.h"
#import "CocoaLibSpotify.h"
#import "fftAnalyzerView.h"
#import <QuartzCore/QuartzCore.h>
#import "mediaPickerController.h"

@interface playbackViewController : UIViewController <MPMediaPickerControllerDelegate>{
    
    UILabel *artistLbl;
    UILabel *titleLbl;
    UIButton *selBtn;
    UIButton *playBtn;
    UIButton *pauseBtn;
    UIButton *playch2Btn;
    UIButton *pausech2Btn;
    UIView *secChannelView;
    double durationNum;
    UIView *controlView;
    effectController *timepitchController;
    effectController *lopassController;
    effectController *hipassController;
    effectController *channelOneVolController;
    
    UILabel *effectParamCh1Nr1;
    UILabel *effectParamCh1Nr2;
    //fft analyzing
    fftAnalyzerView *fftView;
    
    //mixermode stuff
    UIView *effectParentViewCh2;
    UIView *line;
    UIView *controlViewCh2;
    effectController *timepitchControllerCh2;
    effectController *lopassControllerCh2;
    effectController *hipassControllerCh2;
    effectController *channelTwoVolController;
    UIButton *addtrack;
    UILabel *artistlblCh2;
    UILabel *titlelblCh2;
    UIImageView *crossfadeKnob;
    UIImageView *crossfadeBg;
    float crossfadevolch1, crossfadevolch2;
    
    NSURL* outURL;
	NSURL* pcmURL;
	int datasize_; 
	float * data_;
	int writepos_;	
	int readpos_; 
    //	AudioDeviceManager *audio; 
	int initialreadflag_; 
	int earlyfinish_; 
	int restartflag_; 
	int backgroundloadflag_; 
	int playingflag_; 
	int importingflag_; 
	
	//double secondsread_; 
	double duration_; 
    
    NSURL *glAssetURL;
    NSString *glArtist;
    NSString *glTitle;
    BOOL    isPaused;
    
    BOOL appStarted;
    
    UIImageView *bgLogo;
    
    UIImageView *bgLogoRight;
    UILabel *effectParamCh2Nr1;
    UILabel *effectParamCh2Nr2;
    
    UILabel *timeRemainingCh1;
    UILabel *timeRemainingCh2;
    
    NSTimeInterval currenttrackCh2Duration;
    
  
}

@property(nonatomic, retain) UILabel *artistLbl;
@property(nonatomic, retain) UILabel *titleLbl;
@property(nonatomic, retain) UIButton *selBtn;
@property(nonatomic, retain) UIView *controlView;
@property(nonatomic, retain) UIView *effectParentView;

@property(nonatomic, retain) effectController *timepitchController;
@property(nonatomic, retain) effectController *lopassController;
@property(nonatomic, retain) effectController *hipassController;
@property(nonatomic, retain) effectController *channelOneVolController;
@property(nonatomic, retain) fftAnalyzerView *fftView;

@property(nonatomic, retain) UIButton *playBtn;
@property(nonatomic, retain) UIButton *pauseBtn;

@property(nonatomic, retain) UIButton *playch2Btn;
@property(nonatomic, retain) UIButton *pausech2Btn;



//mixermode

@property(nonatomic, retain) UIView *line;
@property(nonatomic, retain) UIView *effectParentViewCh2;
@property(nonatomic, retain) effectController *timepitchControllerCh2;
@property(nonatomic, retain) effectController *lopassControllerCh2;
@property(nonatomic, retain) effectController *hipassControllerCh2;
@property(nonatomic, retain) effectController *channelTwoVolController;
@property(nonatomic, retain) UIView *controlViewCh2;
@property(nonatomic, retain) UIButton *addtrack;
@property(nonatomic, retain) UILabel *artistlblCh2;
@property(nonatomic, retain) UILabel *titlelblCh2;

//@property(nonatomic, retain) UIImageView *crossfadeBg;
@property(nonatomic, retain) UIImageView *crossfadeKnob;



- (void)playnextTrack:(id)sender;
- (void)playprevTrack:(id)sender;
- (void)setTrackTitleAndArtist:(SPTrack *)track;
- (void)setDefaultPitchController:(UITapGestureRecognizer *)gestureRecognizer;
- (void)playTrack:(id)sender;
- (void)stopTrack:(id)sender;
- (void)pauseTrack:(id)sender;
- (void)setPlayduration:(double)length;
- (void)updatePlayduration:(double)val;

- (void)callmainplaytrack:(SPTrack *)track;
- (void)callfadeInMusicCh1;
- (void)resetTrackTitleAndArtist;

- (void)setmixerModeOn;
- (void)setonechannelmodeOn;

- (void)toggleplayandpause:(BOOL)hidden;

//channel two stuff
- (void)showMediaPicker;
- (void)initDataVar;
- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist; 
- (void)loadAudioFile; //:(id)outURL;  
- (void)playTrack:(id)sender;
- (void)stopTrack:(id)sender;
- (void)pauseTrack:(id)sender;
- (void)freeAudio;
- (void)setPlaydurationCh2:(double)length;
- (void)updatePlaydurationCh2:(double)val;


@end
