//
//  audioControl.h
//  mixerTest003
//
//  Created by Christian Persson on 2011-11-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "SPCircularBuffer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

//#import "CAStreamBasicDescription.h"
//#import "CAComponentDescription.h"
//#import "CARingBuffer.h"

#import "CocoaLibSpotify.h"
#import "fftAnalyzerView.h"

@class audioControl;

@protocol audioControlDelegate <NSObject>

-(void)playbackManagerWillStartPlayingAudio:(audioControl *)aPlaybackManger;

@end




@interface audioControl : NSObject <SPSessionPlaybackDelegate>{
    
    SPSession                   *playbackSession;
    SPTrack                     *currentTrack;
    id<audioControlDelegate>    delegate;
    NSMethodSignature           *incrementTrackPositionMethodSignature;
    NSInvocation                *incrementTrackPositionInvocation;
    NSTimeInterval              currentTrackPosition;
    NSTimeInterval              trackPosition;
    AudioUnitParameterValue     volume;
    int                         currentCoreAudioSampleRate;
    
    
    AUGraph                     graph;
    AudioUnit                   ioUnit;
    AudioUnit                   mixerUnit;
    
    AudioUnit                   lopassUnitChOne;
    AudioUnit                   hipassUnitChOne;
    AudioUnit                   timePitchUnitChOne;
    
    AudioUnit                   lopassUnitChTwo;
    AudioUnit                   hipassUnitChTwo;
    AudioUnit                   timePitchUnitChTwo;
    
    AudioUnit                   mixerUnitChOne;
    AudioUnit                   mixerUnitChTwo;
    AUNode                      mixerNodeChOne;
    AUNode                      mixerNodeChTwo;
    AUNode                      mixerNode;
    AudioUnit                   converterUnitChOne;
    AudioUnit                   converterUnitChTwo;
    NSTimer                     *timer;
    AudioUnitParameterValue     masterVol;
   // SPCircularBuffer            *audioBufferCh1, *audioBufferCh2;
    
    //second channel stuff
   
    AURenderCallbackStruct          rcbsFirst;
    AURenderCallbackStruct          rcbsSecond; //second channel
    AURenderCallbackStruct          ioRenderCallback;
    
    
    CFArrayRef audioOutputRoutes;
    
@public
    AudioStreamBasicDescription     asbdChOne;
    AudioStreamBasicDescription     asbdChTwo;
    AudioStreamBasicDescription     effectUnitInputFormat;
    float tempbuf[8000];
	//float monobuf[4000]; 
	//float inputbuf[1024]; 
	//float outputbuf[1024]; 
	float * readbuffer_;	//for storing samples from music library file playback
	int * readpos_;
	int buffersize_; 
	int audioproblems; 
	int readflag_;
    BOOL chTwoPlaying;
    
    //fft objects
    FFTSetup fftSetup;
	COMPLEX_SPLIT A;
    void *fftInBuffer;
    float *fftOutBuffer;
    size_t bufferCapacity;	// In samples
    int log2n, n, nOver2;
    size_t index;	// In samples
    fftAnalyzerView *fftView;
	
}

@property (nonatomic) AudioUnit mixerUnit;
@property (nonatomic) AudioUnit mixerUnitChOne;
@property (nonatomic) AudioUnit mixerUnitChTwo;
@property (nonatomic) AudioUnit timePitchUnitChOne;
@property (nonatomic) AudioUnit timePitchUnitChTwo;




- (void)setFFTView: (fftAnalyzerView *)fftViewer;


- (void)initializeAudioBuffer: (NSUInteger)bufferSizeBytes;
- (void)createCARingBuffer;
- (void)setupInputASBD: (const sp_audioformat *)audioformat;
/** Initialize a new SPPlaybackManager object. 
 
 @param aSession The session that should stream and decode audio data.
 @return Returns the created playback manager.
 */ 
-(id)initWithPlaybackSession:(SPSession *)aSession;


/** Returns the currently playing track, or `nil` if nothing is playing. */
@property (nonatomic, readonly, retain) SPTrack *currentTrack;

/** Returns the manager's delegate. */
@property (nonatomic, readwrite, assign) id <audioControlDelegate> delegate;

/** Returns the session that is performing decoding and playback. */
@property (nonatomic, readonly, retain) SPSession *playbackSession;
/** Returns `YES` if the track is currently playing, `NO` if not.
 
 If currentTrack is not `nil`, playback is paused.
 */
@property (readwrite) BOOL isPlaying;
/** Plays the given track.
 


 
 @param trackToPlay The track that should be played.
 @param error An `NSError` pointer reference that, if not `NULL`, will be filled with an error describing any failure. 
 @return Returns `YES` is playback started successfully, `NO` if not.
 */
-(BOOL)playTrack:(SPTrack *)trackToPlay error:(NSError **)error;
/** Seek the current playback position to the given time. 
 
 @param offset The time at which to seek to. Must be between 0.0 and the duration of the playing track.
 */

- (void)fadeOutMusicCh1;
- (void)fadeOutMusicCh2;
- (void)fadeInMusicCh1;
- (void)fadeInMusicCh2;

-(void)startAUGraph;
-(void)stopAUGraph;

-(Boolean)isaugraphRunning;



/*
 effect controls
 */

- (void)resetVarispeedUnit:(int)unit;
- (void)setMasterVolCh1:(AudioUnitParameterValue)val;

- (void)setlopassEffectY: (AudioUnitParameterValue)val :(int)channel;
- (void)setlopassEffectX: (AudioUnitParameterValue)val :(int)channel;

-(void)sethipassEffectY:(AudioUnitParameterValue)val:(int)channel;
-(void)sethipassEffectX:(AudioUnitParameterValue)val:(int)channel;

-(void)setReverbX:(AudioUnitParameterValue)val;
-(void)setReverbY:(AudioUnitParameterValue)val;

- (void)setPlaybackRate: (AudioUnitParameterValue)val:(int)channel;
-(void)setPlaybackCents:(AudioUnitParameterValue)val:(int)channel;

-(void)checkavailableOutputRoutes;

//second channel stuff
- (void) setMasterVolCh2:(AudioUnitParameterValue)val;
- (void) connectSecChannelCallback;
- (void) removeSecChannelCallback;
- (void) closeDownChannelTwo;
- (void) toggleChannelTwoPlayingStatus:(BOOL)playingStatus;
- (void) canRead;
- (void) cantRead;

-(void)setUpData:(float *)readbuffer pos:(int *)readpos size:(int) siz;
@property (readwrite)           AudioStreamBasicDescription asbdChOne;
@property (readwrite)           AudioStreamBasicDescription asbdChTwo;



- (void)incrementTrackPositionWithFrameCount:(UInt32)framesToAppend;

- (void)enableInput: (UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue;

- (void)seekToTrackPosition:(NSTimeInterval)newPosition;

/** Returns the playback position of the current track, in the range 0.0 to the current track's duration. */
@property (readonly) NSTimeInterval trackPosition;

/** Returns the current playback volume, in the range 0.0 to 1.0. */
@property (readwrite) AudioUnitParameterValue volume;

@property (nonatomic, retain) NSTimer *timer;

@property(nonatomic) BOOL playbackIsPaused;

@property(nonatomic, assign)fftAnalyzerView *fftView;



@end
