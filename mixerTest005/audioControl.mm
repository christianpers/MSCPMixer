//
//  audioControl.m
//  mixerTest003
//
//  Created by Christian Persson on 2011-11-08.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "audioControl.h"
#import "Shared.h"
#import "AppDelegate.h"
/*
OSStatus GraphRenderProc(void *inRefCon,
                         AudioUnitRenderActionFlags *ioActionFlags,
                         const AudioTimeStamp *inTimeStamp,
                         UInt32 inBusNumber,
                         UInt32 inNumberFrames,
                         AudioBufferList * ioData)
{
    myAUGraphPlayerPtr player = (myAUGraphPlayerPtr)inRefCon;
    // Have we ever logged output timing? (for offset calculation)
    if (player->firstOutputSampleTime < 0.0) {
        player->firstOutputSampleTime = inTimeStamp->mSampleTime;
        if ((player->firstInputSampleTime > 0.0) &&
            (player->inToOutSampleTimeOffset < 0.0)) {
            player->inToOutSampleTimeOffset = player->firstInputSampleTime
            - player->firstOutputSampleTime;
            
            } 
    
    }
    // Copy samples out of ring buffer
    OSStatus outputProcErr = noErr;
    outputProcErr = player->ringBuffer->Fetch(ioData,
                                              inNumberFrames,
                                              inTimeStamp->mSampleTime +
                                              player->inToOutSampleTimeOffset);
}
*/

 static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
 {
     /*
     SoundBufferPtr sndbuf = (SoundBufferPtr)inRefCon;
 
     UInt32 bufSamples = sndbuf[inBusNumber].numFrames;
     AudioUnitSampleType *in = sndbuf[inBusNumber].data;
 
     AudioUnitSampleType *outA = (AudioUnitSampleType *)ioData->mBuffers[0].mData;
     AudioUnitSampleType *outB = (AudioUnitSampleType *)ioData->mBuffers[1].mData;
 
     UInt32 sample = sndbuf[inBusNumber].sampleNum;
     for (UInt32 i = 0; i < inNumberFrames; ++i) {
         if (1 == inBusNumber) {
             outA[i] = 0;
             outB[i] = in[sample++];
         } else {
             outA[i] = in[sample++];
             outB[i] = 0;
         }
         if (sample >= bufSamples) sample = 0;
     }
     sndbuf[inBusNumber].sampleNum = sample;
  // printf("bus %d sample %d\n", inBusNumber, sample);
      */
 return noErr;
 }

@interface audioControl ()


@property (nonatomic, readwrite, retain) SPTrack *currentTrack;
@property (nonatomic, readwrite, retain) SPSession *playbackSession;
@property (nonatomic, readwrite, retain) SPCircularBuffer *audioBufferCh1;
@property (nonatomic, readwrite, retain) SPCircularBuffer *audioBufferCh2;
@property (readwrite) NSTimeInterval trackPosition;

-(void)informDelegateOfAudioPlaybackStarting;

-(void)teardownCoreAudio;
-(BOOL)setupAudioGraphWithAudioFormat:(const sp_audioformat *)audioFormat error:(NSError **)err;

static OSStatus AudioUnitRenderDelegateCallback(void *inRefCon,
                                                AudioUnitRenderActionFlags *ioActionFlags,
                                                const AudioTimeStamp *inTimeStamp,
                                                UInt32 inBusNumber,
                                                UInt32 inNumberFrames,
                                                AudioBufferList *ioData);

@end

static NSString * const kSPPlaybackManagerKVOContext = @"kSPPlaybackManagerKVOContext"; 
static NSUInteger const kMaximumBytesInBuffer = 44100 * 2 * 2 * 0.5; // 0.5 Second @ 44.1kHz, 16bit per channel, stereo
static NSUInteger const kUpdateTrackPositionHz = 5;

@implementation audioControl


    
-(id)initWithPlaybackSession:(SPSession *)aSession {
        
        if ((self = [super init])) {
            
            self.playbackSession = aSession;
            self.playbackSession.playbackDelegate = self;
            self.volume = 0.0;
            self.audioBufferCh1 = [[SPCircularBuffer alloc] initWithMaximumLength:kMaximumBytesInBuffer];
            self.audioBufferCh2 = [[SPCircularBuffer alloc] initWithMaximumLength:kMaximumBytesInBuffer];
            
            [self addObserver:self
                   forKeyPath:@"playbackSession.playing"
                      options:0
                      context:kSPPlaybackManagerKVOContext];
            
            // We pre-allocate the NSInvocation for setting the current playback time for performance reasons.
            // See SPPlaybackManagerAudioUnitRenderDelegateCallback() for more.
            SEL incrementTrackPositionSelector = @selector(incrementTrackPositionWithFrameCount:);
            incrementTrackPositionMethodSignature = [[audioControl instanceMethodSignatureForSelector:incrementTrackPositionSelector] retain];
            incrementTrackPositionInvocation = [[NSInvocation invocationWithMethodSignature:incrementTrackPositionMethodSignature] retain];
            [incrementTrackPositionInvocation setSelector:incrementTrackPositionSelector];
            [incrementTrackPositionInvocation setTarget:self];
           
        }
    return self;
}





-(void)dealloc {
    
    [self removeObserver:self forKeyPath:@"playbackSession.playing"];
    
    self.playbackSession.playbackDelegate = nil;
    self.playbackSession = nil;
    self.currentTrack = nil;

    
    DisposeAUGraph(graph);
    
    [self.audioBufferCh1 clear];
    self.audioBufferCh1 = nil;
    [self.audioBufferCh2 clear];
    self.audioBufferCh2 = nil;
    
                                    
     incrementTrackPositionInvocation.target = nil;
     [incrementTrackPositionInvocation release];
     incrementTrackPositionInvocation = nil;
     [incrementTrackPositionMethodSignature release];
     incrementTrackPositionMethodSignature = nil;
                                     
    [super dealloc];
}

@synthesize playbackSession;
@synthesize trackPosition;
@synthesize volume;
@synthesize delegate;
@synthesize currentTrack;
@synthesize timer;
@synthesize audioBufferCh1;
@synthesize audioBufferCh2;

-(BOOL)playTrack:(SPTrack *)trackToPlay error:(NSError **)error {
	
	[self.audioBufferCh1 clear];
    
  	if (trackToPlay.availability != SP_TRACK_AVAILABILITY_AVAILABLE) {
		if (error != NULL) *error = [NSError spotifyErrorWithCode:SP_ERROR_TRACK_NOT_PLAYABLE];
		self.currentTrack = nil;
		return NO;
	}
    
	self.currentTrack = trackToPlay;
    self.volume = 0;
	self.trackPosition = 0.0;
	BOOL result = [self.playbackSession playTrack:self.currentTrack error:error];
	if (result){
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.plbackView setTrackTitleAndArtist:self.currentTrack];
		self.playbackSession.playing = YES;
    }
	else{
		self.currentTrack = nil;
	}
	return result;
}



-(void)setMasterVol:(AudioUnitParameterValue)val{
    OSStatus result = noErr;
    
    NSLog(@"setting mastervol");
    result = AudioUnitSetParameter(mixerUnit,kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, val, 0);
    if (noErr != result){
        
        { printf("mastervol result %lu %4.4s\n", result, (char*)&result); return; }
    }
}



-(void)fadeOutMusic:sender{
    OSStatus result = noErr;
    AudioUnitParameterValue val = 1;

    for (int i = 0;i<10000;i++){
          
        result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, val, 0);
        val-=.0001; 
       
    }
}


-(void)fadeInMusic{
    OSStatus result = noErr;
    result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, self.volume, 0);
    self.volume+=.001; 
    NSLog(@"volume: %f",self.volume);
    if (self.volume < 1){
        [self performSelector:@selector(fadeInMusic) withObject:nil afterDelay:0.01];
        return;
    }
    
}

-(void)resetVarispeedUnit:(int)unit{
    if (unit == 1000){
        OSStatus result = noErr;
        
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, 0, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
            
    }
    else{
        OSStatus result = noErr;
        
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0,1, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    
}


-(void)setPlaybackCents:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the playbackRate");
    result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
}

-(void)setPlaybackRate:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the playbackRate");
    result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    
}

-(void)setlopassEffectY:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the lopassfreq");
    result = AudioUnitSetParameter(lopassUnit,kLowPassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
}
-(void)setlopassEffectX:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the lopassfreq");
    result = AudioUnitSetParameter(lopassUnit,kLowPassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
}

-(void)sethipassEffectY:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassfreq: %f",val);
    result = AudioUnitSetParameter(hipassUnit,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
}
-(void)sethipassEffectX:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassresonance: %f",val);
    result = AudioUnitSetParameter(hipassUnit,kHipassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
}

-(void)setReverbX:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassresonance");
    result = AudioUnitSetParameter(reverbUnit,kReverb2Param_DryWetMix , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
}
-(void)setReverbY:(AudioUnitParameterValue)val{
    
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassresonance");
    result = AudioUnitSetParameter(reverbUnit,kReverb2Param_Gain , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
}
// enable or disables a specific bus
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue
{
    printf("BUS %d isON %f\n", inputNum, isONValue);
    
    OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isONValue, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %d %08X %4.4s\n", result, result, (char*)&result); return; }
    
}
/*
-(void)initializeAudioBuffer:(NSUInteger)bufferSizeBytes{
    
    //Allocate an AudioBufferList plus enough space
    //for array of AudioBuffers
    UInt32  propsize = offsetof(AudioBufferList, mBuffers[0])+
    (sizeof(AudioBuffer) * player.streamFormat.mChannelsPerFrame);
    
    //malloc buffer lists
    player.inputBuffer = (AudioBufferList *)malloc(propsize);
    player.inputBuffer->mNumberBuffers = player.streamFormat.mChannelsPerFrame;
    
    //Pre-malloc buffers for AudioBufferLists
    for(UInt32 i = 0; i < player.inputBuffer->mNumberBuffers;i++){
        player.inputBuffer->mBuffers[i].mNumberChannels = 1;
        player.inputBuffer->mBuffers[i].mDataByteSize = bufferSizeBytes;
        player.inputBuffer->mBuffers[i].mData = malloc(bufferSizeBytes);
        
    }
}

-(void)createCARingBuffer{
    
    //Alloc ring buffer that will hold data from spotify stream
    player.ringBuffer = new CARingBuffer();
    player.ringBuffer->Allocate(player.streamFormat.mChannelsPerFrame,
                                 player.streamFormat.mBytesPerFrame,
                                 kMaximumBytesInBuffer * 3);
}
*/
                                 
-(BOOL)setupAudioGraphWithAudioFormat:(const sp_audioformat *)audioFormat error:(NSError **)err {
    
    NSError *error = nil;
	BOOL success = YES;
	success &= [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
	success &= [[AVAudioSession sharedInstance] setActive:YES error:&error];
	
	if (!success && err != NULL) {
		*err = error;
		return NO;
	}
	
    
    printf("InitializeAUGraph\n");
    
    /*Master ch effects
     */
    AUNode     lopassNode;
    AUNode     pitchNode; 
    AUNode     reverbNode; 
    AUNode     hipassNode; 
    
    /*ch 1 effects
     */
    AUNode      lopassNodeChOne;
    AUNode      hipassNodeChOne;
    AUNode      pitchNodeChOne;
    
    /*ch 2 effects
     */
    AUNode      lopassNodeChTwo;
    AUNode      hipassNodeChTwo;
    AUNode      pitchNodeChTwo;
    
    /*Generic AUs
     */
    AUNode     outputNode;
    AUNode     converterNode;
    AUNode     mixerNode;
    
    AUNode      mixerNodeChOne;
    AUNode      mixerNodeChTwo;
    AUNode      converterNodeChOne;
    AUNode      converterNodeChTwo;
     
    
    printf("set ASBD\n");
    
    //sets player->streamformat
   // [self setInputASBD:audioFormat];
    
    OSStatus result = noErr;
    
    //create new AUGraph
    printf("new AUGraph\n");
    
    result = NewAUGraph(&graph);
    if (result) { printf("NewAUGraph result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    
    // output unit
    AudioComponentDescription output_desc;
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
 
  //  CAComponentDescription output_desc(kAudioUnitType_Output, kAudioUnitSubType_RemoteIO, kAudioUnitManufacturer_Apple);
    
    // iPodEQ unit
    AudioComponentDescription lopass_desc;
    lopass_desc.componentType = kAudioUnitType_Effect;
    lopass_desc.componentSubType = kAudioUnitSubType_LowPassFilter;
    lopass_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    lopass_desc.componentFlags = 0;
    lopass_desc.componentFlagsMask = 0;
  //  CAComponentDescription lopass_desc(kAudioUnitType_Effect, kAudioUnitSubType_LowPassFilter, kAudioUnitManufacturer_Apple);
    
    // multichannel mixer unit
    AudioComponentDescription mixer_desc;
    mixer_desc.componentType = kAudioUnitType_Mixer;
    mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixer_desc.componentFlags = 0;
    mixer_desc.componentFlagsMask = 0;
	//CAComponentDescription mixer_desc(kAudioUnitType_Mixer, kAudioUnitSubType_MultiChannelMixer, kAudioUnitManufacturer_Apple);
    
    // multichannel mixer unit
    AudioComponentDescription converter_desc;
    converter_desc.componentType = kAudioUnitType_FormatConverter;
    converter_desc.componentSubType = kAudioUnitSubType_AUConverter;
    converter_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    converter_desc.componentFlags = 0;
    converter_desc.componentFlagsMask = 0;
	//CAComponentDescription converter_desc(kAudioUnitType_FormatConverter, kAudioUnitSubType_AUConverter, kAudioUnitManufacturer_Apple);
    
    // multichannel mixer unit
    AudioComponentDescription timePitch_desc;
    timePitch_desc.componentType = kAudioUnitType_FormatConverter;
    timePitch_desc.componentSubType = kAudioUnitSubType_Varispeed;
    timePitch_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    timePitch_desc.componentFlags = 0;
    timePitch_desc.componentFlagsMask = 0;
	//CAComponentDescription timePitch_desc(kAudioUnitType_FormatConverter, kAudioUnitSubType_Varispeed, kAudioUnitManufacturer_Apple);
    
    AudioComponentDescription reverb_desc;
    reverb_desc.componentType = kAudioUnitType_Effect;
    reverb_desc.componentSubType = kAudioUnitSubType_Reverb2;
    reverb_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    reverb_desc.componentFlags = 0;
    reverb_desc.componentFlagsMask = 0;
   // CAComponentDescription reverb_desc(kAudioUnitType_Effect, kAudioUnitSubType_Reverb2, kAudioUnitManufacturer_Apple);
    
    AudioComponentDescription hipass_desc;
    hipass_desc.componentType = kAudioUnitType_Effect;
    hipass_desc.componentSubType = kAudioUnitSubType_HighPassFilter;
    hipass_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    hipass_desc.componentFlags = 0;
    hipass_desc.componentFlagsMask = 0;
    
  //  CAComponentDescription hipass_desc(kAudioUnitType_Effect, kAudioUnitSubType_HighPassFilter, kAudioUnitManufacturer_Apple);
    
    printf("add nodes\n");
    
    // create a node in the graph that is an AudioUnit, using the supplied AudioComponentDescription to find and open that unit
	result = AUGraphAddNode(graph, &output_desc, &outputNode);
	if (result) { printf("AUGraphNewNode 1 result %lu %4.4s\n", result, (char*)&result); return; }
    
//    result = AUGraphAddNode(graph, &lopass_desc, &lopassNode);
//    if (result) { printf("AUGraphNewNode 2 result %lu %4.4s\n", result, (char*)&result); return; }
    
	result = AUGraphAddNode(graph, &mixer_desc, &mixerNode);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
//    result = AUGraphAddNode(graph, &converter_desc, &converterNode);
//	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
//    result = AUGraphAddNode(graph, &timePitch_desc, &pitchNode);
//	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
//    result = AUGraphAddNode(graph, &reverb_desc, &reverbNode);
//	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
//    result = AUGraphAddNode(graph, &hipass_desc, &hipassNode);
//	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    //channel 1
    result = AUGraphAddNode(graph, &hipass_desc, &hipassNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &lopass_desc, &lopassNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &timePitch_desc, &pitchNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    //channel 2
    result = AUGraphAddNode(graph, &hipass_desc, &hipassNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &lopass_desc, &lopassNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &timePitch_desc, &pitchNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    
    result = AUGraphAddNode(graph, &mixer_desc, &mixerNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &mixer_desc, &mixerNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &converter_desc, &converterNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &converter_desc, &converterNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    

    // connect a node's output to a node's input
    // mixer -> eq -> output
    // CHANNEL 1
    result = AUGraphConnectNodeInput(graph, mixerNodeChOne, 0, converterNodeChOne, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, converterNodeChOne, 0, lopassNodeChOne, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, lopassNodeChOne, 0, hipassNodeChOne, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, hipassNodeChOne, 0, pitchNodeChOne, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, pitchNodeChOne, 0, mixerNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    
    // CHANNEL 2
    result = AUGraphConnectNodeInput(graph, mixerNodeChTwo, 0, converterNodeChTwo, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, converterNodeChTwo, 0, lopassNodeChTwo, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, lopassNodeChTwo, 0, hipassNodeChTwo, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, hipassNodeChTwo, 0, pitchNodeChTwo, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphConnectNodeInput(graph, pitchNodeChTwo, 0, mixerNode, 1);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    
    result = AUGraphConnectNodeInput(graph, mixerNode, 0, outputNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
	
    
   /* 
    result = AUGraphConnectNodeInput(graph, mixerNode, 0, converterNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(graph, converterNode, 0, lopassNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, lopassNode, 0, pitchNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, pitchNode, 0, hipassNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, hipassNode, 0, reverbNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(graph, reverbNode, 0, outputNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
  */
    CAShow(graph);
    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(graph);
	if (result) { printf("AUGraphOpen result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    // grab the audio unit instances from the nodes
	result = AUGraphNodeInfo(graph, mixerNode, NULL, &mixerUnit);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
//    result = AUGraphNodeInfo(graph, lopassNode, NULL, &lopassUnit);
//    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
//    result = AUGraphNodeInfo(graph, converterNode, NULL,&converterUnit);
//    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
  /*  
    result = AUGraphNodeInfo(graph, pitchNode, NULL,&timePitchUnit);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, reverbNode, NULL,&reverbUnit);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, hipassNode, NULL,&hipassUnit);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
   */ 
    
    result = AUGraphNodeInfo(graph, hipassNodeChOne, NULL,&hipassUnitChOne);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, lopassNodeChOne, NULL,&lopassUnitChOne);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, pitchNodeChOne, NULL,&timePitchUnitChOne);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    
    result = AUGraphNodeInfo(graph, hipassNodeChTwo, NULL,&hipassUnitChTwo);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, lopassNodeChTwo, NULL,&lopassUnitChTwo);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, pitchNodeChTwo, NULL,&timePitchUnitChTwo);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    
    result = AUGraphNodeInfo(graph, mixerNodeChOne, NULL, &mixerUnitChOne);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, mixerNodeChTwo, NULL, &mixerUnitChTwo);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
   
    result = AUGraphNodeInfo(graph, converterNodeChOne, NULL, &converterUnitChOne);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(graph, converterNodeChTwo, NULL, &converterUnitChTwo);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    
    
    // set bus count
	UInt32 numbuses = 2;
    printf("set input bus count %lu\n", numbuses);
    
    NSLog (@"Setting kAudioUnitProperty_MaximumFramesPerSlice for mixer unit global scope");
    // Increase the maximum frames per slice allows the mixer unit to accommodate the
    //    larger slice size used when the screen is locked.
    UInt32 maximumFramesPerSlice = 4096; //4096 is supposed to be used during lockscreen. Should use 1024 during active mode
    UInt32 maximumFramesPerSliceActive = 1024;
    
    result = AudioUnitSetProperty (
                                   mixerUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
     if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
 /*   
    result = AudioUnitSetProperty (
                                   converterUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   lopassUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }

    result = AudioUnitSetProperty (
                                   hipassUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   reverbUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   timePitchUnit,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
*/
    //ch1
    result = AudioUnitSetProperty (
                                   lopassUnitChOne,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }

    result = AudioUnitSetProperty (
                                   hipassUnitChOne,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }

    result = AudioUnitSetProperty (
                                   timePitchUnitChOne,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }


    //ch2
    result = AudioUnitSetProperty (
                                   lopassUnitChTwo,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   hipassUnitChTwo,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   timePitchUnitChTwo,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   mixerUnitChOne,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   mixerUnitChTwo,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   converterUnitChTwo,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty (
                                   converterUnitChOne,
                                   kAudioUnitProperty_MaximumFramesPerSlice,
                                   kAudioUnitScope_Global,
                                   0,
                                   &maximumFramesPerSlice,
                                   sizeof (maximumFramesPerSlice)
                                   );
    
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
 
	
    result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate = (float)audioFormat->sample_rate;
    outputFormat.mFormatID = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
   // outputFormat.mFormatFlags = kAudioFormatFlagsAudioUnitCanonical;
    outputFormat.mBytesPerPacket = audioFormat->channels * sizeof(SInt16);
    outputFormat.mFramesPerPacket = 1;
    outputFormat.mBytesPerFrame = outputFormat.mBytesPerPacket;
    outputFormat.mChannelsPerFrame = audioFormat->channels;
    outputFormat.mBitsPerChannel = 16;
    outputFormat.mReserved = 0;
    
    
    AURenderCallbackStruct rcbs;
    rcbs.inputProc = AudioUnitRenderDelegateCallback;
    rcbs.inputProcRefCon = self;
    
    AURenderCallbackStruct rcbsSec;
    rcbsSec.inputProc = renderInput;
    rcbsSec.inputProcRefCon = self;
 
    // set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback(graph, mixerNodeChOne, 0, &rcbs);
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    // set a callback for the specified node's specified input
//   result = AUGraphSetNodeInputCallback(graph, mixerNodeChTwo, 0, &rcbsSec);
 //   if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
 
    
    /* CHANNEL 1
                    */
    // set the input stream format, this is the format of the audio for mixer input
    result = AudioUnitSetProperty(mixerUnitChOne, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
     
    // set the output stream format of the mixer
	result = AudioUnitSetProperty(mixerUnitChOne, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty(converterUnitChOne
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  0,
                                  &outputFormat,
                                  sizeof(outputFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed converterUnit"); 
    } 
    AudioStreamBasicDescription effectUnitInputFormat;
    UInt32 propSize = sizeof(AudioStreamBasicDescription);
    
    memset(&effectUnitInputFormat, 0, propSize);
    result = AudioUnitGetProperty(lopassUnitChOne, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &effectUnitInputFormat, &propSize);
    // effectUnitInputFormat.Print();
    
    
    result = AudioUnitSetProperty(converterUnitChOne
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormat,
                                  sizeof(effectUnitInputFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
    
    
  /* CHANNEL 2
                */
    
    // set the input stream format, this is the format of the audio for mixer input
    result = AudioUnitSetProperty(mixerUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    
    // set the output stream format of the mixer
	result = AudioUnitSetProperty(mixerUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty(converterUnitChTwo
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  0,
                                  &outputFormat,
                                  sizeof(outputFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed converterUnit"); 
    } 
    memset(&effectUnitInputFormat, 0, propSize);
    result = AudioUnitGetProperty(lopassUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &effectUnitInputFormat, &propSize);
    // effectUnitInputFormat.Print();
    
    
    result = AudioUnitSetProperty(converterUnitChTwo
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormat,
                                  sizeof(effectUnitInputFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
    
    
    
    
    
	
   
	for (int i = 0; i < numbuses; ++i) {
		// setup render callback struct
	//	AURenderCallbackStruct rcbs;
	//	rcbs.inputProc = &SPPlaybackManagerAudioUnitRenderDelegateCallback;
	//	rcbs.inputProcRefCon = &player;
        
    //   AURenderCallbackStruct rcbs;
	//	rcbs.inputProc = AudioUnitRenderDelegateCallback;
	//	rcbs.inputProcRefCon = self;
        
        
        printf("set AUGraphSetNodeInputCallback\n");
        
        // set a callback for the specified node's specified input
    //    result = AUGraphSetNodeInputCallback(graph, mixerNode, i, &rcbs);
    //    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
		
		printf("set input bus %d, client kAudioUnitProperty_StreamFormat\n", i);
        
               
        // set the input stream format, this is the format of the audio for mixer input
		result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &effectUnitInputFormat, sizeof(effectUnitInputFormat));
        if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	}
 
    printf("set output kAudioUnitProperty_StreamFormat\n");
    /* 
    // set the output stream format of the mixer
	result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
   
    result = AudioUnitSetProperty(converterUnit
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  0,
                                  &outputFormat,
                                  sizeof(outputFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed converterUnit"); 
    } 
    
   //  ---- Get the format of the input bus of the effect unit --- this is the important bit 
    
   // CAStreamBasicDescription effectUnitInputFormat;
    AudioStreamBasicDescription effectUnitInputFormatMaster;
    UInt32 propSizemaster = sizeof(AudioStreamBasicDescription);
    
    memset(&effectUnitInputFormatMaster, 0, propSizemaster);
    result = AudioUnitGetProperty(lopassUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &effectUnitInputFormatMaster, &propSizemaster);
   // effectUnitInputFormat.Print();
    
    
    result = AudioUnitSetProperty(converterUnit
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormatMaster,
                                  sizeof(effectUnitInputFormatMaster));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
 
   
    // ---- Get the format of the input bus of the effect unit --- this is the important bit 
    
    result = AudioUnitSetProperty(lopassUnit
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormatMaster,
                                  sizeof(effectUnitInputFormatMaster));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
    */
    result = AudioUnitSetParameter(mixerUnitChTwo,kMultiChannelMixerParam_Volume , kAudioUnitScope_Global, 0, 0, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
   /* result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, 0, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(timePitchUnit,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, 1, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    result = AudioUnitSetParameter(hipassUnit,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, 40, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(hipassUnit,kHipassParam_Resonance , kAudioUnitScope_Global, 0, 10, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    */
      
    CAShow(graph);
    
    printf("AUGraphInitialize\n");
    
    // now that we've set everything up we can initialize the graph, this will also validate the connections
	result = AUGraphInitialize(graph);
    if (result) { printf("AUGraphInitialize result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    [self startAUGraph];
  //  self.firstInputSampleTime = -1;
  //  player.firstOutputSampleTime = -1;
  //  player.inToOutSampleTimeOffset = -1;
    currentCoreAudioSampleRate = audioFormat->sample_rate;
    return YES;
}

                                 
-(NSInteger)session:(SPSession *)aSession shouldDeliverAudioFrames:(const void *)audioFrames ofCount:(NSInteger)frameCount format:(const sp_audioformat *)audioFormat {
                                     
        // This is called by CocoaLibSpotify when there's audio data to be played. Since Core Audio uses callbacks as well to 
        // fetch data, we store the data in an intermediate buffer. This method is called on an aritrary thread, so everything
        // must be thread-safe. In addition, this method must not block - if your buffers are full, return 0 and the delivery will
        // be tried again later.
                                     
        [self retain]; // Try to avoid the object being deallocated while this is going on.
    
                                     
        if (frameCount == 0) {
            // If this happens (frameCount of 0), the user has seeked the track somewhere (or similar). 
            // Clear audio buffers and wait for more data.
            [self.audioBufferCh1 clear];
            return 0;
            }
                                     
        if (audioFormat->sample_rate != currentCoreAudioSampleRate)
            // Spotify contains audio in various sample rates. If we encounter one different to the current
            // sample rate, we need to tear down our Core Audio setup and set it up again.
            [self teardownCoreAudio];
    
    //    [self setInputASBD:audioFormat];
                                     
        if (graph == NULL) {
            // Setup Core Audio if it hasn't been set up yet.
            NSError *error = nil;
            if (![self setupAudioGraphWithAudioFormat:audioFormat error:&error]) {
                NSLog(@"[%@ %@]: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error);
                return 0;
                }
        }
                                    
        if (self.audioBufferCh1.length == 0){
                [self informDelegateOfAudioPlaybackStarting];
                [self setIsPlaying:YES];
                
           
        }
        
        NSUInteger frameByteSize = sizeof(SInt16) * audioFormat->channels;
        NSUInteger dataLength = frameCount * frameByteSize;
        NSUInteger bufferSizeBytes = kMaximumBytesInBuffer * sizeof(SInt16);
    /*
        if (player.ringBuffer == NULL){
            [self createCARingBuffer];
            [self initializeAudioBuffer:bufferSizeBytes];
            [self informDelegateOfAudioPlaybackStarting];
            
        }
     */                                            
        if ((self.audioBufferCh1.maximumLength - self.audioBufferCh1.length) < dataLength) {
            // Only allow whole deliveries in, since libSpotify wants us to consume whole frames, whereas
            // the buffer works in bytes, meaning we could consume a fraction of a frame.
           return 0;
        }
  /*
   Ringbuffer testing, never worked out but has to fix it sometime. So much cooler !
   
    AudioTimeStamp *timeStamp;
    
    
    // Have we ever logged input timing? (for offset calculation)
    if (player.firstInputSampleTime < 0.0) {
        player.firstInputSampleTime = timeStamp->mSampleTime;
        if ((player.firstOutputSampleTime > 0.0) &&
            (player.inToOutSampleTimeOffset < 0.0)) {
            player.inToOutSampleTimeOffset = player.firstInputSampleTime -
            player.firstOutputSampleTime;
        }
    }
           
      
       
        player.inputBuffer->mBuffers[0].mData = (void *)audioFrames;
        if (player.streamFormat.mChannelsPerFrame == 2){
            player.inputBuffer->mBuffers[1].mData = (void *)audioFrames;
        }
        
        OSStatus outputProcErr = noErr;
        outputProcErr = player.ringBuffer->Store(player.inputBuffer,
                                  frameCount, 
                                  timeStamp->mSampleTime);
     */
        [self.audioBufferCh1 attemptAppendData:audioFrames ofLength:dataLength];
                                     
        [self release];
    return frameCount;
}

-(void)teardownCoreAudio{
    if (graph == NULL)
        return;
    
    // Tear down the audio init properly.
    [self stopAUGraph];
    AUGraphUninitialize(graph);
    DisposeAUGraph(graph);
	
#if TARGET_OS_IPHONE
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
#else 
  //  CloseComponent(outputAudioUnit);
#endif
  //  outputAudioUnit = NULL;
     currentCoreAudioSampleRate = 0;
}
    

-(void)startAUGraph{
    if (graph == NULL){
        return;
    }
    else{
        OSStatus result;
        
        Boolean isRunning = false;
        result = AUGraphIsRunning(graph, &isRunning);
        if (result) { printf("AUGraphIsRunning result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        if (!isRunning) {
        
            result = AUGraphStart(graph);
            if (result) { printf("AUGraphStart result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
            
            NSError *error = nil;
            BOOL success = YES;
            success &= [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            success &= [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
            printf("PLAY\n");
           
       }
       
    }
   
}



-(void)seekToTrackPosition:(NSTimeInterval)newPosition {
	if (newPosition <= self.currentTrack.duration) {
		[self.playbackSession seekPlaybackToOffset:newPosition];
		self.trackPosition = newPosition;
        [self setVolume:1];
	}	
}

-(void)stopAUGraph{
    
    if (graph == NULL){
        return;
    }
    else{
        OSStatus result;
        Boolean isRunning = false;
        result = AUGraphIsOpen(graph, &isRunning);
        
        if (isRunning){
            printf("Stop\n");
            
            result = AUGraphStop(graph);
            if (result) { printf("AUGraphStop result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        }
    }   
}
/*                                 
-(void)setInputASBD:(const sp_audioformat *)audioformat{
    
    
    player.streamFormat.mSampleRate = (float)audioformat->sample_rate;
    player.streamFormat.mFormatID = kAudioFormatLinearPCM;
    player.streamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kAudioFormatFlagsNativeEndian;
    player.streamFormat.mBytesPerPacket = audioformat->channels * sizeof(SInt16);
    player.streamFormat.mFramesPerPacket = 1;
    player.streamFormat.mBytesPerFrame = player.streamFormat.mBytesPerPacket;
    player.streamFormat.mChannelsPerFrame = audioformat->channels;
    player.streamFormat.mBitsPerChannel = 16;
    player.streamFormat.mReserved = 0;
    
    
}
 */                                
-(void)informDelegateOfAudioPlaybackStarting {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
        return;
        }
    [self.delegate playbackManagerWillStartPlayingAudio:self];
}
                                 
                                 
+(NSSet *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObject:@"playbackSession.playing"];
}
                                 
-(BOOL)isPlaying {
    return self.playbackSession.isPlaying;
}
                                 
-(void)setIsPlaying:(BOOL)isPlaying {
    self.playbackSession.playing = isPlaying;
}
                                 
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
                                     
    if ([keyPath isEqualToString:@"playbackSession.playing"] && context == kSPPlaybackManagerKVOContext) {
       if (self.playbackSession.isPlaying) {
           [self startAUGraph];
           if (self.volume < 0.1){
               
               [self fadeInMusic];
           }
      //     self.volume = 0;
      //     
        } 
       else
        {
           // Explicitly stop the audio unit, otherwise it'll continue playing audio from the buffers it has.
           [self stopAUGraph];
        }
    }
    else
    {
      [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
                                
#pragma mark -
#pragma mark Playback Callbacks
                                 
-(void)sessionDidLosePlayToken:(SPSession *)aSession {
                                     
    // This delegate is called when playback stops because the Spotify account is being used for playback elsewhere.
    // In practice, playback is only paused and you can call [SPSession -setIsPlaying:YES] to start playback again and 
    // pause the other client.
                                     
}
                                 
-(void)sessionDidEndPlayback:(SPSession *)aSession {
                                     
    // This delegate is called when playback stops naturally, at the end of a track.
                                     
    // Not routing this through to the main thread causes odd locks and crashes.
    [self performSelectorOnMainThread:@selector(sessionDidEndPlaybackOnMainThread:)
                                                withObject:aSession
                                                waitUntilDone:NO];
    
}
                                 
-(void)sessionDidEndPlaybackOnMainThread:(SPSession *)aSession {
    NSURL *currentURL = [self.currentTrack spotifyURL];
    int loop = 0;
    int currentTrackIndexNum = 0;
    int cueLength = [[Shared sharedInstance].masterCue count];
    for (NSURL *url in [Shared sharedInstance].masterCue){
        if ([url isEqual:currentURL]){
            currentTrackIndexNum = loop;
        }
        loop++;
    }
    NSLog(@"currenttrackindex: %d",currentTrackIndexNum);
    if (currentTrackIndexNum+1 < cueLength){
        NSURL *trackURL = [[Shared sharedInstance].masterCue objectAtIndex:currentTrackIndexNum+1];
        SPTrack *track = [[SPSession sharedSession]trackForURL:trackURL];
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main playnewTrack:track]; 
        
        
        
    }
    else{
        [self stopAUGraph];
    }
    
    self.currentTrack = nil;	
}

static UInt32 framesSinceLastTimeUpdate = 0;

static OSStatus AudioUnitRenderDelegateCallback(void *inRefCon,
                                                                 AudioUnitRenderActionFlags *ioActionFlags,
                                                                 const AudioTimeStamp *inTimeStamp,
                                                                 UInt32 inBusNumber,
                                                                 UInt32 inNumberFrames,
                                                                 AudioBufferList *ioData) {
    
    // This callback is called by Core Audio when it needs more audio data to fill its buffers.
    // This callback is both super time-sensitive and called on some arbitrary thread, so we
    // have to be extra careful with performance and locking.
    //   audioControl *self = inRefCon;
    audioControl *control = (audioControl *)inRefCon;
    //    myAUGraphPlayerPtr player = (myAUGraphPlayerPtr)inRefCon;
    //	[self retain]; // Try to avoid the object being deallocated while this is going on.
    
    AudioBuffer *buffer = &(ioData->mBuffers[0]);
	UInt32 bytesRequired = buffer->mDataByteSize;
    framesSinceLastTimeUpdate += inNumberFrames;
	int sampleRate = control->currentCoreAudioSampleRate;
    
    // If we don't have enough data, tell Core Audio about it.
	NSUInteger availableData = [control->audioBufferCh1 length];
	if (availableData < bytesRequired) {
		buffer->mDataByteSize = 0;
		*ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
        //		[self release];
		return noErr;
    }
    
    // Since we told Core Audio about our audio format in -setupCoreAudioWithAudioFormat:error:,
    // we can simply copy data out of our buffer straight into the one given to us in the callback.
    // SPCircularBuffer deals with thread safety internally so we don't need to worry about it here.
    buffer->mDataByteSize = (UInt32)[control->audioBufferCh1 readDataOfLength:bytesRequired intoAllocatedBuffer:&buffer->mData];
    
	if (sampleRate > 0 && framesSinceLastTimeUpdate >= sampleRate/kUpdateTrackPositionHz) {
        // Only update 5 times per second.
        // Since this render callback from Core Audio is so time-sensitive, we avoid allocating objects
        // and having to use an autorelease pool by pre-allocating the NSInvocation, setting its argument here
        // and setting it off on the main thread without waiting here. The -trackPosition property is atomic, so the
        // worst race condition that can happen is the property gets set out of order. Since we update at 5Hz, the 
        // chances of this happening are slim.
		[control->incrementTrackPositionInvocation setArgument:&framesSinceLastTimeUpdate atIndex:2];
		[control->incrementTrackPositionInvocation performSelectorOnMainThread:@selector(invoke)
                                                                    withObject:nil
                                                                 waitUntilDone:NO];
		framesSinceLastTimeUpdate = 0;
	}
        
    //	[self release];
    
    return noErr;
}

-(void)incrementTrackPositionWithFrameCount:(UInt32)framesToAppend {
	if (currentCoreAudioSampleRate > 0)
		self.trackPosition = self.trackPosition + (double)framesToAppend/currentCoreAudioSampleRate;
}
                               
@end
