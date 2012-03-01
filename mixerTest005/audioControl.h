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
    
    BOOL                 isStereo;           // set to true if there is data in the audioDataRight member
    UInt32               frameCount;         // the total number of frames in the audio data
    UInt32               sampleNumber;       // the next audio sample to play
    AudioUnitSampleType  *audioDataLeft;     // the complete left (or mono) channel of audio data read from an audio file
    AudioUnitSampleType  *audioDataRight;    // the complete right channel of audio data read from an audio file
    
} soundStruct, *soundStructPtr;

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
    
    AudioStreamBasicDescription streamFormat;
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
    AUNode                      mixerNodeChTwo;
    AudioUnit                   converterUnitChOne;
    AudioUnit                   converterUnitChTwo;
    NSTimer                     *timer;
    AudioUnitParameterValue     masterVol;
   // SPCircularBuffer            *audioBufferCh1, *audioBufferCh2;
    
    //second channel stuff
    CFURLRef                        sourceURLArray[1];
    soundStruct                     soundStructArray[1];
    AudioStreamBasicDescription     stereoStreamFormat;
    AudioStreamBasicDescription     monoStreamFormat;
    AURenderCallbackStruct          rcbsSec; //second channel
    
	
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


//second channel stuff
- (void) readAudioFilesIntoMemory:(NSURL *)url;
- (void) setupStereoStreamFormat;
- (void) setMasterVolCh2:(AudioUnitParameterValue)val;
- (void) connectSecChannelCallback;
@property (readwrite)           AudioStreamBasicDescription stereoStreamFormat;
@property (readwrite)           AudioStreamBasicDescription monoStreamFormat;



- (void)incrementTrackPositionWithFrameCount:(UInt32)framesToAppend;

- (void)enableInput: (UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue;

- (void)seekToTrackPosition:(NSTimeInterval)newPosition;

/** Returns the playback position of the current track, in the range 0.0 to the current track's duration. */
@property (readonly) NSTimeInterval trackPosition;

/** Returns the current playback volume, in the range 0.0 to 1.0. */
@property (readwrite) AudioUnitParameterValue volume;

@property (nonatomic, retain) NSTimer *timer;


@end
