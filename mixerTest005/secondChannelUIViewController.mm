//
//  secondChannelUIViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "secondChannelUIViewController.h"
#import <AVFoundation/AVAsset.h>
#import "AppDelegate.h"

@implementation secondChannelUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissModalViewControllerAnimated:YES];
	for (MPMediaItem* item in mediaItemCollection.items) {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
		NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration]; 
		//NSTimeInterval is a double
		duration_ = [dur doubleValue]; 
		
		//MPMediaItemPropertyArtist
		NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		if (nil == assetURL) {
			/**
			 * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
			 * in question is protected by DRM. (old m4p files)
			 */
			return;
		}
        NSLog(@"title: %@",title);
        [UIView animateWithDuration:1
                         animations:^{
                             //     self.tableView.alpha = 1;
                             //     self.tableView.hidden = YES;
                         }];
        
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
        [UIView commitAnimations];
        
    	[self exportAssetAtURL:assetURL withTitle:title withArtist:artist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
    
    [UIView animateWithDuration:1
                     animations:^{
                         //     self.tableView.alpha = 1;
                         //     self.tableView.hidden = YES;
                     }];
    
    [UIView beginAnimations : @"Display notif" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
   
    [UIView commitAnimations];
     //importingflag_=0; 
	
}



- (void)showMediaPicker {
	
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
	[self presentModalViewController:mediaPicker animated:YES];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    [everything setGroupingType: MPMediaGroupingAlbum];
    NSArray *collections = [everything collections];
    NSLog(@"ts");
    
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    int i = 0;
    int j=0;
    
    
    MPMediaQuery *allMedia = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate *mpp1 = [MPMediaPropertyPredicate predicateWithValue:@"2"     forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonEqualTo];
    [allMedia addFilterPredicate:mpp1];
    
    NSArray *itemsFromGenericQuery = [allMedia items];
    
    NSLog(@"itemCount: %d",[itemsFromGenericQuery count]);
    
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist {
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
	//release previous
	[outURL release];
	//need to retain? 
	outURL = assetURL; 
	[outURL retain]; 	
	
	
	NSLog(@"This is the title %@ and artist %@", title, artist); 
	
	//secondsread_ = 0; 
	
	[main.playbackManager cantRead];
	writepos_ = 0; 
	readpos_ = 0;
	initialreadflag_ = false; 
	
	for (int i=0; i<datasize_; ++i)
		data_[0]= 0.0; //zero out contents of buffer
    
	//initialise the audio player
    [main.playbackManager connectSecChannelCallback];

	playingflag_ =1; 
	
	//need to load the samples on a background thread
	//potential memory leak? should just be instance variable and freed at end? 
	//if thread finishes, is it deallocated automatically?
	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
										initWithTarget:self
										selector:@selector(loadAudioFile) 
										object:nil];
	[queue addOperation:operation]; 
	[operation release];
	
	
}

- (void)loadAudioFile {
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	
	backgroundloadflag_ = 1; 
	
	//http://developer.apple.com/library/ios/#documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/05_MediaRepresentations.html
	//+ (id)dictionaryWithObject:(id)anObject forKey:(id)aKey
	//(NSDictionary *)options = [NSDictionary dictionaryWithObject:(id)anObject forKey:(id)AVURLAssetPreferPreciseDurationAndTimingKey]
	//NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
	
	AVURLAsset * asset = [AVURLAsset URLAssetWithURL:outURL options:options]; //Nil
	//[asset retain]; //don't need to retain? 
	
	NSError *error = nil;
	AVAssetReader * filereader= [AVAssetReader assetReaderWithAsset:(AVAsset *)asset error:&error];
    
	[filereader retain];
    
	if (error==nil) {
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool required here, according to iphone forum posts
		
		//get sound file tracks 
		//NSArray * tracks = asset.tracks; //[asset tracksWithMediaType:   ]; 
		//NSUInteger numtracks = tracks.count; 
		//AVAssetTrack * track = [tracks objectAtIndex:0]; 
		
		//NSDictionary *outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
		
		//http://objective-audio.jp/2010/09/avassetreaderavassetwriter.html		
		NSDictionary *audioSetting = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
									  [NSNumber numberWithInt:2],AVNumberOfChannelsKey,	//how many channels has original? 
									  [NSNumber numberWithInt:32],AVLinearPCMBitDepthKey, //was 16
									  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
									  [NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,  //was NO
									  [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
									  [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
									  [NSData data], AVChannelLayoutKey, nil];	
		//if mono should hopefully convert it to stereo... 
		
		
		//need to check format possibilities, and also check whether allowed to convert. 	
		
		//AVAssetReaderTrackOutput * readaudiofile = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:(AVAssetTrack *)track outputSettings:nil];
		
		//AVAssetReaderTrackOutput * readaudiofile = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:(AVAssetTrack *)track outputSettings:audioSetting];
		//AVAssetReaderAudioMixOutput
		//NSArray *array = [NSArray	arrayWithObject:(AVAssetTrack *)track]; 	
		//AVAssetReaderAudioMixOutput * readaudiofile = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:array audioSettings:audioSetting];
		
		
		//should only be one track anyway
		AVAssetReaderAudioMixOutput * readaudiofile = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:(asset.tracks) audioSettings:audioSetting];
		
		//claim in source file that AVAssetReaderTrackOutput should be used! 
		//but this line freezes program
		//AVAssetReaderTrackOutput * readaudiofile = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:audioSetting];
        
		[readaudiofile retain];  
		
		BOOL yesorno = [filereader canAddOutput:(AVAssetReaderOutput *)readaudiofile];
		
		if (yesorno==NO) goto audiofileProblem; 
		
		[filereader addOutput:(AVAssetReaderOutput *)readaudiofile]; 
		
		//NSString *mediaType = [readaudiofile mediaType]; //should be soun	
		
		BOOL lastcheck = [filereader startReading]; 	
		
		if (lastcheck==NO) goto audiofileProblem; 
		
		//CMTimeRange time = filereader.timeRange;
		//8192 samples at once 
		
		//CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer
		
		//UInt32 numChannels = 2; //TOSORT inputFileFormat.mChannelsPerFrame; 
		//if (numChannels==0) numChannels = 1; 
		
		importingflag_=0;
		
		//take large chunks of data at a time
		//http://osdir.com/ml/coreaudio-api/2009-10/msg00030.html
		
		int actuallyfinished= 0; 
		
		// Iteratively read data from the input file and write to output
		for(;;) {
			
			if(earlyfinish_==1) {
				
				
				earlyfinish_=0; 
				
				break; 
			}
			
			if (restartflag_==1) {
                
				//[audio cantRead];
                [main.playbackManager cantRead];
				
				initialreadflag_ = false; 
				
				//a lot of repeat to code to restart: should really encapsulate in a class
				[filereader cancelReading]; 
				
				[readaudiofile release]; 
				[filereader release]; 
				
				filereader= [AVAssetReader assetReaderWithAsset:(AVAsset *)asset error:&error];
				
				[filereader retain];
				
				if (error!=nil) goto audiofileProblem; 
				
				readaudiofile = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:(asset.tracks) audioSettings:audioSetting];
				
				[readaudiofile retain];  
				
				yesorno = [filereader canAddOutput:(AVAssetReaderOutput *)readaudiofile];
				
				if (yesorno==NO) goto audiofileProblem; 
				
				[filereader addOutput:(AVAssetReaderOutput *)readaudiofile]; 
				
				BOOL lastcheck = [filereader startReading]; 	
				
				if (lastcheck==NO) goto audiofileProblem; 
				
				
				restartflag_ = 0; 
				actuallyfinished= 0; 
				
				//secondsread_ = 0.0; 
				
				//thread safety
				writepos_ = (readpos_ + 1024)%datasize_; 
			}
			
			int readtest = readpos_; 
			
			//test where readpos_ is; while within 2 seconds (half of buffer) must continue to fill up
			int diff = readtest<=writepos_?(writepos_- readtest):(writepos_+datasize_ - readtest); 
			
			
			if ((diff < (datasize_/2)) && (actuallyfinished==0)) {
				
				CMSampleBufferRef ref = [readaudiofile copyNextSampleBuffer];
				
				if(ref!=NULL) {
					
					Boolean nexttest = CMSampleBufferDataIsReady(ref); 
					
					//finished?
					if (nexttest==NO) 
						goto audiofileProblem;
					
					//CMTime time= CMSampleBufferGetDuration(ref);
					//CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription (ref); 
					
					CMItemCount countsamp= CMSampleBufferGetNumSamples(ref); 	
					
					//CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(ref); 
					
					UInt32 frameCount = countsamp; 
					
					//countsamp= CMSampleBufferGetNumSamples(ref); 	
					
					CMBlockBufferRef blockBuffer;
					AudioBufferList audioBufferList;
					
					//allocates new buffer memory
					CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList),NULL, NULL, 0, &blockBuffer);
					
					float * buffer = (float * ) audioBufferList.mBuffers[0].mData; 
					
					//int bytesize = audioBufferList.mBuffers[0].mNumberChannels;
					//int numchannels = audioBufferList.mBuffers[0].mDataByteSize;
					//int numbuffers = audioBufferList.mNumberBuffers; 
					
					for (int j=0; j<2*frameCount; ++j) {
						
						data_[writepos_] = buffer[j]; 
						
						writepos_ = (writepos_ + 1)%datasize_; 
					}
					
					CFRelease(ref);
					CFRelease(blockBuffer);
					
					// If no frames were returned, conversion is finished
					if(0 == frameCount) {
						
						actuallyfinished=1; 
						//in case user presses restart button! 
						//break;
						
					}
					
				} else {
					
					
					actuallyfinished=1;
				}
				
			}	else {
				
				if (!initialreadflag_) 	{
					initialreadflag_ = true; 
                    [main.playbackManager canRead];
				//	[audio canRead];
				} else {
					
					usleep(100); //1000 = 1 msec 
				}
				
			}
			
		}
		
		
		//any cleanup? 
		//for later, to tell main thread done...?
		//performSelectorOnMainThread
		
		[filereader cancelReading]; 
		
		[readaudiofile release]; 
		[filereader release]; 
		
		[pool drain]; 
		
		backgroundloadflag_ = 0; 
		
		return; 
		
		
	}
	
audiofileProblem: 
	
	
	backgroundloadflag_ = 0; 
	
}






- (void)createChannelTwoUI{
    
       
    UIButton *addtrack = [UIButton buttonWithType:UIButtonTypeCustom];
    addtrack.frame = CGRectMake(50, self.view.bounds.size.height-100, 200, 40);// position in the parent view and set the size of the
    addtrack.backgroundColor = [UIColor blackColor];
    [addtrack setTitle:[NSString stringWithFormat:@"ADD TRACK"] forState:UIControlStateNormal];
    [addtrack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addtrack addTarget:self 
                 action:@selector(showMediaPicker)
       forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:addtrack];
    
    effectController *lopassChTwoController = [[effectController alloc]initWithFrame:CGRectMake(300, 30, 40, 40)];
    lopassChTwoController.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lopassChTwoController];
    [lopassChTwoController setTag:6];
    
    UILabel *lblLopassChTwo = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
    lblLopassChTwo.textAlignment =  UITextAlignmentCenter;
    lblLopassChTwo.textColor = [UIColor blackColor];
    lblLopassChTwo.backgroundColor = [UIColor clearColor];
    lblLopassChTwo.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    lblLopassChTwo.text = @"L";
    [lopassChTwoController addSubview:lblLopassChTwo];
    [lblLopassChTwo release];  
    
    [lopassChTwoController release];
   
    
    datasize_ = 44100*8; 
	data_ = new float[datasize_];
	writepos_ = 0; 
	readpos_ = 0;
	initialreadflag_ = false; 
	restartflag_ = 0; 
	backgroundloadflag_ = 0; 
	earlyfinish_ = 0; 
	playingflag_=0; 
	
	//safety
	importingflag_ = 0; 
    
	
	//create here, not fully started yet
//	audio = [[AudioDeviceManager alloc] init];
//	[audio retain]; 
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
	[main.playbackManager setUpData:data_ pos:&readpos_ size:datasize_]; //allocate buffers

    
    
}

- (void)removeChannelTwoUI{
    
    for (UIView *view in self.view.subviews){
        if (view.tag != 10){
            [view removeFromSuperview];
            
        }
        
    }
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
