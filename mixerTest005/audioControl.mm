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

AudioBufferList* bufferList;
BOOL startedCallback;
BOOL noInterrupt; 

static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {  
	
	int i, j; 
	
	
	if(startedCallback && noInterrupt) {
		
		//get a copy of the objectiveC class "self" we need this to get the next sample to fill the buffer
		audioControl *manager = (audioControl *)inRefCon;
        
		float * tempbuf = manager->tempbuf; 
        //	float * monobuf =  manager->monobuf; 
        
       
		//loop through all the buffers that need to be filled
		for (i = 0 ; i < ioData->mNumberBuffers; i++){
			//get the buffer to be filled
			AudioBuffer buffer = ioData->mBuffers[i];
			//printf("which buf %d numberOfSamples %d channels %d countertest %d \n", i, buffer.mDataByteSize, buffer.mNumberChannels, g_countertest);
			
			//if needed we can get the number of bytes that will fill the buffer using
			// int numberOfSamples = ioData->mBuffers[i].mDataByteSize;
			
			//get the buffer and point to it as an UInt32 (as we will be filling it with 32 bit samples)
			//if we wanted we could grab it as a 16 bit and put in the samples for left and right seperately
			//but the loop below would be for(j = 0; j < inNumberFrames * 2; j++) as each frame is a 32 bit number
			//UInt32 *frameBuffer = buffer.mData;
			
			short signed int *frameBuffer = (short signed int *)buffer.mData;
			
			//safety first
			inNumberFrames= inNumberFrames<4000?inNumberFrames:4000; 
            
			//float * tempbuf= manager->readbuffer_;
			
			int flag = manager->readflag_; 
			
			if (flag==1) {
                
				
				int pos = (*manager->readpos_); 
				int size= manager->buffersize_; 
				float * source =  manager->readbuffer_; 
                
				float mult = 32000.0; //just alllow a little leeway for limiter errors 32767.0; 
				int j; 
				
                //loop through the buffer and fill the frames
                for (j = 0; j < 2*inNumberFrames; j++){
                    // get NextPacket returns a 32 bit value, one frame.
                    //frameBuffer[j] = [[remoteIOplayer inMemoryAudioFile] getNextPacket];
                    //float value= 32767.0*sin((400*2*3.14159)*(j/44100.0)); 
                    //float value= mult*tempbuf[j]; //sin((400*2*3.14159)*(g_countertest/44100.0)); 
					
                    tempbuf[j] = source[pos]; //mult*(source[pos]); 
                    
                    pos = (pos+1)%size; 
                    //frameBuffer[2*j] = 0.0; //value; 
                    //frameBuffer[2*j+1] = 0.0; //value; 
                    
                    //++g_countertest; 
                }
				
				
                //(*(manager->readpos_)) += inNumberFrames;  
                
				(*(manager->readpos_)) = pos; 
				
				//converts to int
				for (int j = 0; j < 2*inNumberFrames; j++)
					frameBuffer[j] = mult*(tempbuf[j]);
                
				
				
			} else {
				
				for (int j = 0; j < inNumberFrames; j++){
					// get NextPacket returns a 32 bit value, one frame.
					//frameBuffer[j] = [[remoteIOplayer inMemoryAudioFile] getNextPacket];
					float value= 0.0; //32767.0*sin((400*2*3.14159)*(j/44100.0)); 
					//float value= mult*tempbuf[j]; //sin((400*2*3.14159)*(g_countertest/44100.0)); 
					
					frameBuffer[2*j] = value; 
					frameBuffer[2*j+1] = value; 
					
					//++g_countertest; 
				}
				
			}
			
		}
        
		
	} else {
		
		for (i = 0 ; i < ioData->mNumberBuffers; i++){
			AudioBuffer buffer = ioData->mBuffers[i];
            
			short signed int *frameBuffer = (short signed int *)buffer.mData;
            
			//loop through the buffer and fill the frames
			for (j = 0; j < inNumberFrames; j++){
                
				short signed int value= 0; //32767.0*0.0; 
				frameBuffer[2*j] = value;	
				frameBuffer[2*j+1] = value; 
				
				//++g_countertest; 
			}
			
		}
		
	}
	
	
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
            self.volume = 0.7;
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
@synthesize stereoStreamFormat;
@synthesize playbackIsPaused;



-(void)connectFirstChannelCallback{
    OSStatus result;
    
    rcbsFirst.inputProc = AudioUnitRenderDelegateCallback;
    rcbsFirst.inputProcRefCon = self;
    
    // set a callback for the specified node's specified input
    result = AUGraphSetNodeInputCallback(graph, mixerNodeChOne, 0, &rcbsFirst);
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }

    result = AUGraphUpdate(graph, NULL);
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
}

-(void)removeFirstChannelCallback{
    
    OSStatus result;
    result = AUGraphDisconnectNodeInput(graph, mixerNodeChOne, 0);
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphUpdate(graph, NULL);
    if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
}



/*second channel stuff !!!!!!!!! start
                                            */

-(void)closeDownChannelTwo{
	
	
	//OSStatus status = AudioOutputUnitStop(audioUnit);
	
	if(startedCallback) {
		
        //for(UInt32 i=0;i<bufferList->mNumberBuffers;i++) {
        //		free(bufferList->mBuffers[i].mData);
        //	}
        //	
       // free(bufferList);
        
        startedCallback	= NO;
		
	}
    
	//AudioUnitUninitialize(audioUnit);
	
	//AudioSessionSetActive(false);
    
}


-(void)canRead {
	readflag_ = true; 
	
}

-(void)cantRead {
    
	readflag_ = false; 
	
}


-(void)setUpData:(float *)readbuffer pos:(int *)readpos size:(int) siz {
	
    memset(readbuffer, 0, 1024);
	readbuffer_ = readbuffer; 
	readpos_ = readpos; 
	readflag_ = false; 
	buffersize_ = siz; 
	
	//gain_ = 1.0; 
	
}


-(void)setMasterVolCh2:(AudioUnitParameterValue)val{
    OSStatus result = noErr;
    
    NSLog(@"setting mastervol");
    result = AudioUnitSetParameter(mixerUnitChTwo, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, val, 0);
    if (noErr != result){
        
        { printf("mastervol result %lu %4.4s\n", result, (char*)&result); return; }
    }
}


-(void)connectSecChannelCallback{
    
    rcbsSecond.inputProc = &playbackCallback;
    rcbsSecond.inputProcRefCon = self;
    
    OSStatus result;
    
    UInt32 numInteractions = 0;
    result = AUGraphCountNodeInteractions(graph, mixerNodeChTwo, &numInteractions);
    if (numInteractions == 1){
        // set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(graph, mixerNodeChTwo, 0, &rcbsSecond);
        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        result = AUGraphUpdate(graph, NULL);
        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        startedCallback = YES;
        noInterrupt = YES;

    }     
   
}

-(void)removeSecChannelCallback{
  
    OSStatus result;
    
    UInt32 numInteractions = 0;
    result = AUGraphCountNodeInteractions(graph, mixerNodeChTwo, &numInteractions);
    if (numInteractions == 2){
        
        result = AUGraphDisconnectNodeInput(graph, mixerNodeChTwo, 0);
        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        result = AUGraphUpdate(graph, NULL);
        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }

        startedCallback = NO;
        noInterrupt = NO;    
        
    }
  }


/*second channel stuff !!!!!!!!!!! end
                                            */

-(BOOL)playTrack:(SPTrack *)trackToPlay error:(NSError **)error {
	
	[self.audioBufferCh1 clear];
    
  	if (trackToPlay.availability != SP_TRACK_AVAILABILITY_AVAILABLE) {
		if (error != NULL) *error = [NSError spotifyErrorWithCode:SP_ERROR_TRACK_NOT_PLAYABLE];
		self.currentTrack = nil;
		return NO;
	}
    
	self.currentTrack = trackToPlay;
   // self.volume = 0;
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

-(void)setMasterVolCh1:(AudioUnitParameterValue)val{
    OSStatus result = noErr;
    
    NSLog(@"setting mastervol");
    result = AudioUnitSetParameter(mixerUnitChOne,kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, val, 0);
    if (noErr != result){
        
        { printf("mastervol result %lu %4.4s\n", result, (char*)&result); return; }
    }
}

-(void)fadeOutMusicCh1{
    OSStatus result = noErr;
    result = AudioUnitSetParameter(mixerUnitChOne, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, self.volume, 0);
    self.volume-=.003; 
    NSLog(@"volume: %f",self.volume);
    if (self.volume > 1){
        [self performSelector:_cmd withObject:nil afterDelay:0.01];
        return;
        
    }
}
-(void)fadeOutMusicCh2{
    OSStatus result = noErr;
    result = AudioUnitSetParameter(mixerUnitChTwo, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, self.volume, 0);
    self.volume-=.003; 
    NSLog(@"volume: %f",self.volume);
    if (self.volume > 1){
        [self performSelector:_cmd withObject:nil afterDelay:0.01];
        return;
        
    }
}
-(void)fadeInMusicCh1{
    OSStatus result = noErr;
    result = AudioUnitSetParameter(mixerUnitChOne, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, self.volume, 0);
    self.volume+=.003; 
    NSLog(@"volume: %f",self.volume);
    if (self.volume < 1){
        [self performSelector:@selector(fadeInMusicCh1) withObject:nil afterDelay:0.01];
        return;
    }
}
-(void)fadeInMusicCh2{
    OSStatus result = noErr;
    result = AudioUnitSetParameter(mixerUnitChTwo, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, self.volume, 0);
    self.volume+=.003; 
    NSLog(@"volume: %f",self.volume);
    if (self.volume < 1){
        [self performSelector:@selector(fadeInMusicCh1) withObject:nil afterDelay:0.01];
        return;
    }
}

-(void)resetVarispeedUnit:(int)unit{
    if (unit == 1000){
        OSStatus result = noErr;
        
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChOne,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, 0, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
            
    }
    else{
        OSStatus result = noErr;
        
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChTwo,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0,1, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    
}


-(void)setPlaybackCents:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    if(channel == 1){
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChOne,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }else{
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChTwo,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
}

-(void)setPlaybackRate:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    if (channel == 1){
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChOne,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }else{
        NSLog(@"setting the playbackRate");
        result = AudioUnitSetParameter(timePitchUnitChTwo,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        } 
        
    }
    
   
    
    
}

-(void)setlopassEffectY:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    
    if (channel == 1){
        NSLog(@"setting the lopassfreq");
        result = AudioUnitSetParameter(lopassUnitChOne,kLowPassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    else if (channel == 2) {
        NSLog(@"setting the lopassfreq");
        result = AudioUnitSetParameter(lopassUnitChTwo,kLowPassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
    }
    
}
-(void)setlopassEffectX:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    
    if (channel == 1){
        NSLog(@"setting the lopassfreq");
        result = AudioUnitSetParameter(lopassUnitChOne,kLowPassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    else if (channel == 2){
        
        NSLog(@"setting the lopassfreq");
        result = AudioUnitSetParameter(lopassUnitChTwo,kLowPassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
    }
    
  
    
}

-(void)sethipassEffectY:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    if(channel == 1){
        NSLog(@"setting the hipassfreq: %f",val);
        result = AudioUnitSetParameter(hipassUnitChOne,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }else{
        NSLog(@"setting the hipassfreq: %f",val);
        result = AudioUnitSetParameter(hipassUnitChTwo,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    
   
    
}
-(void)sethipassEffectX:(AudioUnitParameterValue)val:(int)channel{
    
    OSStatus result = noErr;
    
    if (channel == 1){
        NSLog(@"setting the hipassresonance: %f",val);
        result = AudioUnitSetParameter(hipassUnitChOne,kHipassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }else{
        NSLog(@"setting the hipassresonance: %f",val);
        result = AudioUnitSetParameter(hipassUnitChTwo,kHipassParam_Resonance , kAudioUnitScope_Global, 0, val, 0);
        if (noErr != result){
            
            { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
        }
        
    }
    
   
    
}

-(void)setReverbX:(AudioUnitParameterValue)val{
   /* 
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassresonance");
    result = AudioUnitSetParameter(reverbUnit,kReverb2Param_DryWetMix , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    */
}
-(void)setReverbY:(AudioUnitParameterValue)val{
 /*   
    OSStatus result = noErr;
    
    NSLog(@"setting the hipassresonance");
    result = AudioUnitSetParameter(reverbUnit,kReverb2Param_Gain , kAudioUnitScope_Global, 0, val, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
  */
}
// enable or disables a specific bus
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue
{
    printf("BUS %lu isON %f\n", inputNum, isONValue);
    
    OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isONValue, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %ld %08ld %4.4s\n", result, result, (char*)&result); return; }
    
}

-(Boolean)isaugraphRunning{
    OSStatus result;
    
    Boolean isRunning = false;
    result = AUGraphIsRunning(graph, &isRunning);
    
    return isRunning;
}

                                 
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
    AUNode     mixerNode;
    
   // AUNode      mixerNodeChOne;
   // AUNode      mixerNodeChTwo;
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
    
	result = AUGraphAddNode(graph, &mixer_desc, &mixerNode);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    //channel 1
    result = AUGraphAddNode(graph, &mixer_desc, &mixerNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &converter_desc, &converterNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &hipass_desc, &hipassNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &lopass_desc, &lopassNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &timePitch_desc, &pitchNodeChOne);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    

    //channel 2
    result = AUGraphAddNode(graph, &mixer_desc, &mixerNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &converter_desc, &converterNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }

    result = AUGraphAddNode(graph, &hipass_desc, &hipassNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &lopass_desc, &lopassNodeChTwo);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(graph, &timePitch_desc, &pitchNodeChTwo);
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
	

       CAShow(graph);
    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(graph);
	if (result) { printf("AUGraphOpen result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    // grab the audio unit instances from the nodes
	result = AUGraphNodeInfo(graph, mixerNode, NULL, &mixerUnit);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
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
    
    result = AUGraphNodeInfo(graph, outputNode, NULL,&ioUnit);
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
    
    UInt32 numbusesChOne = 1;
    result = AudioUnitSetProperty(mixerUnitChOne, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbusesChOne, sizeof(numbusesChOne));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    UInt32 numbusesChTwo = 1;
    result = AudioUnitSetProperty(mixerUnitChTwo, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbusesChTwo, sizeof(numbusesChTwo));
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
    
    
    stereoStreamFormat.mSampleRate			= 44100.00;
	stereoStreamFormat.mFormatID			= kAudioFormatLinearPCM;
	stereoStreamFormat.mFormatFlags         = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	stereoStreamFormat.mFramesPerPacket     = 1;
	stereoStreamFormat.mChannelsPerFrame	= 2;
	stereoStreamFormat.mBitsPerChannel		= 16;
	stereoStreamFormat.mBytesPerPacket		= 4;
	stereoStreamFormat.mBytesPerFrame		= 4;
    
    /* CHANNEL 1
       connect channel 1 callback */ 
    
    
    [self connectFirstChannelCallback];
    
                   
                    
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
    
    result = AudioUnitSetProperty(timePitchUnitChOne
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
    result = AudioUnitSetProperty(mixerUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &stereoStreamFormat, sizeof(stereoStreamFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    
    // set the output stream format of the mixer
	result = AudioUnitSetProperty(mixerUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &stereoStreamFormat, sizeof(stereoStreamFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty(converterUnitChTwo
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  0,
                                  &stereoStreamFormat,
                                  sizeof(stereoStreamFormat));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed converterUnit"); 
    } 
    AudioStreamBasicDescription effectUnitInputFormatCh2;
    UInt32 propSizeCh2 = sizeof(AudioStreamBasicDescription);
    
    
    memset(&effectUnitInputFormatCh2, 0, propSizeCh2);
    result = AudioUnitGetProperty(lopassUnitChTwo, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &effectUnitInputFormatCh2, &propSizeCh2);
    // effectUnitInputFormat.Print();
    
    
    result = AudioUnitSetProperty(converterUnitChTwo
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormatCh2,
                                  sizeof(effectUnitInputFormatCh2));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
    
    result = AudioUnitSetProperty(timePitchUnitChTwo
                                  ,kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  0,
                                  &effectUnitInputFormatCh2,
                                  sizeof(effectUnitInputFormatCh2));
    
    if(noErr != result) {
        NSLog(@"streamInputFormat failed mixerinput 1"); 
    }
    
    result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, 1, 1, 0);
    
    result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Global, 1, 1, 0);
    
    result = AudioUnitSetParameter(mixerUnitChTwo,kMultiChannelMixerParam_Volume , kAudioUnitScope_Global, 0, 1, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    result = AudioUnitSetParameter(timePitchUnitChOne,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, 0, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(timePitchUnitChOne,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, 1, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    result = AudioUnitSetParameter(hipassUnitChOne,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, 40, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(hipassUnitChOne,kHipassParam_Resonance , kAudioUnitScope_Global, 0, 10, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
 
    
    result = AudioUnitSetParameter(timePitchUnitChTwo,kVarispeedParam_PlaybackCents , kAudioUnitScope_Global, 0, 0, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(timePitchUnitChTwo,kVarispeedParam_PlaybackRate , kAudioUnitScope_Global, 0, 1, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    result = AudioUnitSetParameter(hipassUnitChTwo,kHipassParam_CutoffFrequency , kAudioUnitScope_Global, 0, 40, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    result = AudioUnitSetParameter(hipassUnitChTwo,kHipassParam_Resonance , kAudioUnitScope_Global, 0, 10, 0);
    if (noErr != result){
        
        { printf("LopassEffect result %lu %4.4s\n", result, (char*)&result); return; }
    }
    
    
      
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
        if (isRunning){
            UInt32 numInteractions;
            result = AUGraphCountNodeInteractions(graph, mixerNodeChOne, &numInteractions);
            if (numInteractions == 1){
                
                [self connectFirstChannelCallback];
            
            }
        }
        if (!isRunning) {
        
            result = AUGraphStart(graph);
            if (result) { printf("AUGraphStart result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
            
            NSError *error = nil;
            BOOL success = YES;
            success &= [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            success &= [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
            printf("PLAY\n");
            UInt32 numInteractions;
            result = AUGraphCountNodeInteractions(graph, mixerNodeChOne, &numInteractions);
            if (numInteractions == 1){
                
                [self connectFirstChannelCallback];
            }
           
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
               
             //  [self fadeInMusicCh1];
           }
        } 
       else
        {
           // Explicitly stop the audio unit, otherwise it'll continue playing audio from the buffers it has.
           //[self stopAUGraph];
            
            OSStatus result;
            UInt32 numInteractions;
            result = AUGraphCountNodeInteractions(graph, mixerNodeChOne, &numInteractions);
            if (numInteractions == 2){
                [self fadeOutMusicCh1];
                [self removeFirstChannelCallback];
            }
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
        [self removeFirstChannelCallback];
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
