//
//  secondChannelUIViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "effectController.h"


@interface secondChannelUIViewController : UIViewController <MPMediaPickerControllerDelegate> {
    
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
 
    UIView *controlView;
    UIView *effectParentView;
    NSURL *glAssetURL;
    NSString *glArtist;
    NSString *glTitle;
    BOOL    isPaused;
    
    UILabel *secChLabel;
   
}

@property(nonatomic, retain) UIView *controlView;
@property(nonatomic, retain) UIView *effectParentView;
@property(nonatomic, retain) UILabel *secChLabel;


- (void)showMediaPicker;
- (void)initDataVar;
- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist; 
- (void)loadAudioFile; //:(id)outURL;  
- (void)playTrack:(id)sender;
- (void)stopTrack:(id)sender;
- (void)pauseTrack:(id)sender;
- (void)removeChannelTwoUI;
- (void)createChannelTwoUI;
- (void)freeAudio;
- (void)newChannel:(UITapGestureRecognizer *)gesture;

@end
