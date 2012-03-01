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
   
}

- (void)showMediaPicker;
- (void)createChannelTwoUI;
- (void)removeChannelTwoUI;
- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist; 
- (void)loadAudioFile; //:(id)outURL;  


@end
