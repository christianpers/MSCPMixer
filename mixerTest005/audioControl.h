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

//#import "CAStreamBasicDescription.h"
//#import "CAComponentDescription.h"
//#import "CARingBuffer.h"

#import "CocoaLibSpotify.h"

typedef struct {
    AudioStreamBasicDescription streamFormat;
    AUGraph                     graph;
    AudioUnit                   ioUnit;
    AudioUnit                   mixerUnit;
    AudioUnit                   lopassUnit;
    AudioUnit                   converterUnit;
    
    SPCircularBuffer            *audioBufferCh1;
    SPCircularBuffer            *audioBufferCh2;
    
    AudioBufferList             *inputBuffer;
    Float64                     firstInputSampleTime;
    Float64                     firstOutputSampleTime;
    Float64                     inToOutSampleTimeOffset;

    
} myAUGraphPlayer, *myAUGraphPlayerPtr;

@class audioControl;

@protocol audioControlDelegate <NSObject>

-(void)playbackManagerWillStartPlayingAudio:(audioControl *)aPlaybackManger;

@end




@interface audioControl : NSObject <SPSessionPlaybackDelegate>{
    
    SPSession                   *playbackSession;
    SPTrack                     *currentTrack;
    id<audioControlDelegate>    delegate;
    myAUGraphPlayer             player;   
    NSMethodSignature           *incrementTrackPositionMethodSignature;
    NSInvocation                *incrementTrackPositionInvocation;
    NSTimeInterval              currentTrackPosition;
    NSTimeInterval              trackPosition;
    AudioUnitParameterValue     volume;
    int                         currentCoreAudioSampleRate;
    
    AudioStreamBasicDescription streamFormat;
    AUGraph                     graph;
    AudioUnit                   ioUnit;
    AudioUnit                   mixerUnit;
    AudioUnit                   lopassUnit;
    AudioUnit                   converterUnit;
    AudioUnit                   timePitchUnit;
    AudioUnit                   reverbUnit;
    AudioUnit                   hipassUnit;
    
    AudioUnit                   lopassUnitChOne;
    AudioUnit                   hipassUnitChOne;
    AudioUnit                   timePitchUnitChOne;
    
    AudioUnit                   lopassUnitChTwo;
    AudioUnit                   hipassUnitChTwo;
    AudioUnit                   timePitchUnitChTwo;
    
    AudioUnit                   mixerUnitChOne;
    AudioUnit                   mixerUnitChTwo;
    AudioUnit                   converterUnitChOne;
    AudioUnit                   converterUnitChTwo;
    NSTimer                     *timer;
    AudioUnitParameterValue     masterVol;
    SPCircularBuffer            *audioBufferCh1, *audioBufferCh2;
	
}


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

- (void)fadeOutMusic:sender;
- (void)fadeInMusic;

-(void)startAUGraph;
-(void)stopAUGraph;

/*
 effect controls
 */

- (void)resetVarispeedUnit:(int)unit;
- (void)setMasterVol:(AudioUnitParameterValue)val;

- (void)setlopassEffectY: (AudioUnitParameterValue)val;
- (void)setlopassEffectX: (AudioUnitParameterValue)val;

-(void)sethipassEffectY:(AudioUnitParameterValue)val;
-(void)sethipassEffectX:(AudioUnitParameterValue)val;

-(void)setReverbX:(AudioUnitParameterValue)val;
-(void)setReverbY:(AudioUnitParameterValue)val;

- (void)setPlaybackRate: (AudioUnitParameterValue)val;
- (void)setPlaybackCents: (AudioUnitParameterValue)val;
/*
 effect controls
 */

- (void)incrementTrackPositionWithFrameCount:(UInt32)framesToAppend;

- (void)enableInput: (UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue;

- (void)seekToTrackPosition:(NSTimeInterval)newPosition;

/** Returns the playback position of the current track, in the range 0.0 to the current track's duration. */
@property (readonly) NSTimeInterval trackPosition;

/** Returns the current playback volume, in the range 0.0 to 1.0. */
@property (readwrite) AudioUnitParameterValue volume;

@property (nonatomic, retain) NSTimer *timer;


@end
