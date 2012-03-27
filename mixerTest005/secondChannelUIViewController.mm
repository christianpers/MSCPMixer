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
#import <QuartzCore/QuartzCore.h>

@implementation secondChannelUIViewController

@synthesize controlView, effectParentView, secChLabel;


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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    
    UIView *chtwoView = [[UIView alloc]initWithFrame:CGRectMake(0, winSize.height-70, winSize.width, 50)];
    chtwoView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    
    self.view = chtwoView;
    
    
    [chtwoView release];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    
    
    UITapGestureRecognizer *secChTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(newChannel:)];
    secChTouch.numberOfTapsRequired = 1;
    
    self.secChLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, winSize.width, 40)];
    self.secChLabel.backgroundColor = [UIColor clearColor];
    self.secChLabel.textColor = [UIColor blackColor];
    self.secChLabel.textAlignment = UITextAlignmentCenter;
    self.secChLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    self.secChLabel.text = [NSString stringWithFormat:@"Channel 2"];
    [self.secChLabel addGestureRecognizer:secChTouch];
    self.secChLabel.UserInteractionEnabled = YES;
    [self.secChLabel setTag:10];
    [self.view addSubview:self.secChLabel];
    
    
    [secChTouch release];
}

-(void)newChannel:(UITapGestureRecognizer *)gesture{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([main.playbackManager isaugraphRunning]){
        CGRect bounds = main.plbackViewController.view.bounds;
        CGSize winSize = main.window.frame.size;
        CGPoint effectParentPos = main.plbackViewController.effectParentView.frame.origin;
        CGRect effectParentSize = main.plbackViewController.effectParentView.bounds;
        
        if (!main.chTwoActive){
            main.chTwoActive = YES;
            [UIView animateWithDuration:1
                             animations:^{
                                 //     self.tableView.alpha = 1;
                                 //     self.tableView.hidden = YES;
                             }];
            
            [UIView beginAnimations : @"Display notif" context:nil];
            [UIView setAnimationDuration:1];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            main.plbackViewController.effectParentView.frame = CGRectMake(effectParentPos.x, effectParentPos.y, effectParentSize.size.width, bounds.size.height/2-100);
            main.plbackViewController.view.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height/2);
            self.view.frame = CGRectMake(0, bounds.size.height/2, bounds.size.width, bounds.size.height/2);
            
            main.cueController.view.frame = CGRectMake(200, bounds.size.height-700, main.cueController.view.bounds.size.width, main.cueController.view.bounds.size.height);
            main.plbackViewController.trackControlBG.frame = CGRectMake(400, bounds.size.height-700, main.plbackViewController.trackControlBG.bounds.size.width, main.plbackViewController.trackControlBG.bounds.size.height);
            
            
            main.plbackViewController.timepitchController.frame = CGRectMake(20, bounds.size.height/4, main.plbackViewController.timepitchController.bounds.size.width, main.plbackViewController.timepitchController.bounds.size.height);
            
            main.plbackViewController.lopassController.frame = CGRectMake(80, 30, main.plbackViewController.timepitchController.bounds.size.width, main.plbackViewController.timepitchController.bounds.size.height);
            
            main.plbackViewController.hipassController.frame = CGRectMake(40, 100, main.plbackViewController.timepitchController.bounds.size.width, main.plbackViewController.timepitchController.bounds.size.height);
            
            main.plbackViewController.channelOneVolController.frame = CGRectMake(100, 200, main.plbackViewController.channelOneVolController.bounds.size.width, main.plbackViewController.channelOneVolController.bounds.size.height);
            
            main.plbackViewController.artistLbl.hidden = YES;
            main.plbackViewController.titleLbl.hidden = YES;
            
            
            [UIView commitAnimations];
            
            [self createChannelTwoUI];
        }
        else{
            main.chTwoActive = NO;
            [UIView animateWithDuration:1
                             animations:^{
                                 //     self.tableView.alpha = 1;
                                 //     self.tableView.hidden = YES;
                                 [self removeChannelTwoUI];
                             }];
            
            [UIView beginAnimations : @"Display notif" context:nil];
            [UIView setAnimationDuration:1];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            
            main.plbackViewController.artistLbl.hidden = NO;
            main.plbackViewController.titleLbl.hidden = NO;
            
            main.plbackViewController.view.frame = CGRectMake(0, 0, winSize.width, winSize.height);
            self.view.frame = CGRectMake(0, winSize.height-70, winSize.width,50);
            main.plbackViewController.effectParentView.frame = CGRectMake(effectParentPos.x, effectParentPos.y, effectParentSize.size.width, winSize.height-180);
            
            
            [UIView commitAnimations];
            
        }
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Start spotify channel first" message:@"This channel is disabled until channel 1 is started, sorry dude." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}




- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissModalViewControllerAnimated:YES];
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
   // memset(data_, 0, datasize_);
    [main.playbackManager toggleChannelTwoPlayingStatus:YES];
    
    [self freeAudio];
    
    [self initDataVar];
    
	for (MPMediaItem* item in mediaItemCollection.items) {
		//NSString *titletest = [item valueForProperty:MPMediaItemPropertyTitle];
		//NSString *artisttest = [item valueForProperty:MPMediaItemPropertyArtist];
        
		glTitle = [item valueForProperty:MPMediaItemPropertyTitle];
		glTitle = [item valueForProperty:MPMediaItemPropertyArtist];
		NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration]; 
		//NSTimeInterval is a double
		duration_ = [dur doubleValue]; 
		
		//MPMediaItemPropertyArtist
		glAssetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		if (nil == glAssetURL) {
			/**
			 * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
			 * in question is protected by DRM. (old m4p files)
			 */
			return;
		}
        NSLog(@"title: %@",glTitle);
        [UIView animateWithDuration:1
                         animations:^{
                             //     self.tableView.alpha = 1;
                             //     self.tableView.hidden = YES;
                             main.playlistLabel.hidden = NO;
                             main.playbackLabel.hidden = NO;
                             main.searchLabel.hidden = NO;
                             main.cueController.view.hidden = NO;
                         }];
        
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
        [UIView commitAnimations];
        
    	[self exportAssetAtURL:glAssetURL withTitle:glTitle withArtist:glArtist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[self dismissModalViewControllerAnimated:YES];
    
    [UIView animateWithDuration:1
                     animations:^{
                         //     self.tableView.alpha = 1;
                         //     self.tableView.hidden = YES;
                         main.playlistLabel.hidden = NO;
                         main.playbackLabel.hidden = NO;
                         main.searchLabel.hidden = NO;
                         main.cueController.view.hidden = NO;
                     }];
    
    [UIView beginAnimations : @"Display notif" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
   
    [UIView commitAnimations];
     importingflag_=0; 
	
}



- (void)showMediaPicker {
	
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
	[self presentModalViewController:mediaPicker animated:YES];
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
    main.playlistLabel.hidden = YES;
    main.playbackLabel.hidden = YES;
    main.searchLabel.hidden = YES;
    main.cueController.view.hidden = YES;
    
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
	
	for (int i=0; i<datasize_; ++i){
		data_[i]= 0.0; //zero out contents of buffer
	}	
	//initialise the audio player
    [main.playbackManager connectSecChannelCallback];
    [main.playbackManager connectSecMastermixerBus];

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
                        [self freeAudio];
                        
                        [main.playbackManager toggleChannelTwoPlayingStatus:NO];
						//in case user presses restart button! 
						//break;
						
					}
					
				} else {
					
					
					actuallyfinished=1;
                    [self freeAudio];
                    
                    [main.playbackManager toggleChannelTwoPlayingStatus:NO];
				}
				
			}	else {
				
				if (!initialreadflag_) 	{
					initialreadflag_ = true; 
                    [main.playbackManager canRead];
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


- (void)initDataVar{
    
    
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
    
    
    //setting up the controls 

}


- (void)createChannelTwoUI{
    
    CGSize parentSize = self.view.frame.size;
    
    self.effectParentView = [[UIView alloc]initWithFrame:CGRectMake(50, 30, parentSize.width-100, parentSize.height-60)];
    self.effectParentView.backgroundColor = [UIColor clearColor];
    self.effectParentView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.view addSubview:self.effectParentView];
    
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
    [self.effectParentView addSubview:lopassChTwoController];
    [lopassChTwoController setTag:6];
    
    UILabel *lblLopassChTwo = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
    lblLopassChTwo.textAlignment =  UITextAlignmentCenter;
    lblLopassChTwo.textColor = [UIColor whiteColor];
    lblLopassChTwo.backgroundColor = [UIColor clearColor];
    lblLopassChTwo.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    lblLopassChTwo.text = @"L";
    [lopassChTwoController addSubview:lblLopassChTwo];
    [lblLopassChTwo release];  
    
    [lopassChTwoController release];
    
    effectController *hipassChTwoController = [[effectController alloc]initWithFrame:CGRectMake(500, 80, 40, 40)];
    hipassChTwoController.backgroundColor = [UIColor blackColor];
    [self.effectParentView addSubview:hipassChTwoController];
    [hipassChTwoController setTag:8];
    
    UILabel *lblHipassChTwo = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
    lblHipassChTwo.textAlignment =  UITextAlignmentCenter;
    lblHipassChTwo.textColor = [UIColor whiteColor];
    lblHipassChTwo.backgroundColor = [UIColor clearColor];
    lblHipassChTwo.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    lblHipassChTwo.text = @"H";
    [hipassChTwoController addSubview:lblHipassChTwo];
    [lblHipassChTwo release];  
    
    [hipassChTwoController release];
    
    effectController *timepitchChTwoController = [[effectController alloc]initWithFrame:CGRectMake(200, 230, 40, 40)];
    timepitchChTwoController.backgroundColor = [UIColor blackColor];
    [self.effectParentView addSubview:timepitchChTwoController];
    [timepitchChTwoController setTag:9];
    
    UILabel *lbltimepitchChTwo = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
    lbltimepitchChTwo.textAlignment =  UITextAlignmentCenter;
    lbltimepitchChTwo.textColor = [UIColor whiteColor];
    lbltimepitchChTwo.backgroundColor = [UIColor clearColor];
    lbltimepitchChTwo.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    lbltimepitchChTwo.text = @"T";
    [timepitchChTwoController addSubview:lbltimepitchChTwo];
    [lbltimepitchChTwo release];  
    
    [timepitchChTwoController release];
    
    effectController *mastervolControllerChTwo = [[effectController alloc]initWithFrame:CGRectMake(200, 10, 60, 60)];
    mastervolControllerChTwo.backgroundColor = [UIColor blackColor];
    [self.effectParentView addSubview:mastervolControllerChTwo];
    [mastervolControllerChTwo setTag:7]; 
    
    UILabel *lblvol = [[UILabel alloc]initWithFrame:CGRectMake(0,15,60,30)];
    lblvol.textAlignment =  UITextAlignmentCenter;
    lblvol.textColor = [UIColor whiteColor];
    lblvol.backgroundColor = [UIColor clearColor];
    lblvol.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
    lblvol.text = @"Vol";
    [mastervolControllerChTwo addSubview:lblvol];
    [lblvol release];   
    [mastervolControllerChTwo release];
    
    //setting up the controls 
    CGSize parent = self.view.bounds.size;
    
    UIView *cView = [[UIView alloc]initWithFrame:CGRectMake((parent.width/2)-(150/2), 130, 150, 70)];
    cView.backgroundColor = [UIColor clearColor];
    self.controlView = cView;
    [self.view addSubview:self.controlView];
    self.controlView.layer.cornerRadius = 10;
    self.controlView.layer.borderWidth = 2;
    self.controlView.layer.borderColor = [[UIColor blackColor]CGColor];
    [cView release];
    
    NSString* imagePathStop = [[NSBundle mainBundle] pathForResource:@"stopCh2" ofType:@"png"];
    NSString* imagePathPause = [[NSBundle mainBundle] pathForResource:@"pauseCh2" ofType:@"png"];
    
    UIImage *stopImg = [UIImage imageWithContentsOfFile:imagePathStop];
    UIImage *pauseImg = [UIImage imageWithContentsOfFile:imagePathPause];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 13, 43, 43)];
    [stopBtn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlView addSubview:stopBtn];
    [stopBtn addTarget:self 
                action:@selector(stopTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [stopBtn release];
    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(90, 13, 43, 43)];
    [pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlView addSubview:pauseBtn];
    [pauseBtn addTarget:self 
                 action:@selector(pauseTrack:)
       forControlEvents:UIControlEventTouchDown];
    
    [pauseBtn release];
    
}


- (void)pauseTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (isPaused){
        isPaused = NO;
        [main.playbackManager canRead];
    }else{
        isPaused = YES;
        [main.playbackManager cantRead];
    }
    
}

-(void)stopTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main.playbackManager cantRead];
    
    
    [self freeAudio];
    
    [self initDataVar];
    
    //[main.playbackManager removeSecChannelCallback];
    [main.playbackManager removeSecMastermixerBus];
    
    [main.playbackManager toggleChannelTwoPlayingStatus:NO];
    
    
}

- (void)removeChannelTwoUI{
    
    for (UIView *view in self.view.subviews){
        if (view.tag != 10){
            [view removeFromSuperview];
            
        }
        
    }
}


- (void)freeAudio {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
   
    
    memset(data_, 0, datasize_);
    
    [main.playbackManager cantRead];
    
    [main.playbackManager removeSecChannelCallback];
    
    [main.playbackManager closeDownChannelTwo];
	//stop audio if necessary
	if(playingflag_==1) {
		
		playingflag_=0; 
	}
	
	//stop background loading thread
	if(backgroundloadflag_ == 1)
		earlyfinish_ = 1; 
	
	while(backgroundloadflag_==1)
	{
		usleep(5000); //wait for file thread to finish
	}
	
	
	
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [secChLabel release];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}



@end
