//
//  playbackView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "playbackView.h"
#import "Shared.h"
#import "AppDelegate.h"


@implementation playbackView

@synthesize artistLbl, titleLbl, selBtn;
@synthesize trackControlBG, trackControlFG;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGSize parentSize = self.frame.size;
        int yPos = parentSize.height-170;
        int cntrlHeight = 100;
        int mastervolHeight = 200;
        
        self.artistLbl = [[UILabel alloc]initWithFrame:CGRectMake(400,self.bounds.size.height-200,300,30)];
        self.artistLbl.textAlignment =  UITextAlignmentCenter;
        self.artistLbl.textColor = [UIColor blackColor];
        artistLbl.backgroundColor = [UIColor whiteColor];
        self.artistLbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
        self.artistLbl.text = @"Artist";
        
        [self addSubview:self.artistLbl];
        
        self.titleLbl = [[UILabel alloc]initWithFrame:CGRectMake(400,self.bounds.size.height-150,300,30)];
        self.titleLbl.textAlignment =  UITextAlignmentCenter;
        self.titleLbl.textColor = [UIColor blackColor];
        artistLbl.backgroundColor = [UIColor whiteColor];
        self.titleLbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
        self.titleLbl.text = @"Title";
        
        [self addSubview:self.titleLbl];
        
        
        NSString* imagePathNext = [[NSBundle mainBundle] pathForResource:@"nextTrack" ofType:@"png"];
        NSString* imagePathPrev = [[NSBundle mainBundle] pathForResource:@"prevTrack" ofType:@"png"];
        NSString* imagePathStop = [[NSBundle mainBundle] pathForResource:@"stopbtn" ofType:@"png"];
        NSString* imagePathPause = [[NSBundle mainBundle] pathForResource:@"pause" ofType:@"png"];
        NSString* imagePathPlay = [[NSBundle mainBundle] pathForResource:@"playNew" ofType:@"png"];
        
        
        UIImage *nextImg = [UIImage imageWithContentsOfFile:imagePathNext];
        UIImage *prevImg = [UIImage imageWithContentsOfFile:imagePathPrev];
        UIImage *stopImg = [UIImage imageWithContentsOfFile:imagePathStop];
        UIImage *pauseImg = [UIImage imageWithContentsOfFile:imagePathPause];
        UIImage *playImg = [UIImage imageWithContentsOfFile:imagePathPlay];
        
        UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(180, 400, 43, 43)];
        [playBtn setBackgroundImage:playImg forState:UIControlStateNormal];
        [self addSubview:playBtn];
        [playBtn addTarget:self 
                    action:@selector(playTrack:)
          forControlEvents:UIControlEventTouchDown];
        
        [playBtn release];
        
        UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(260, 400, 43, 43)];
        [stopBtn setBackgroundImage:stopImg forState:UIControlStateNormal];
        [self addSubview:stopBtn];
        [stopBtn addTarget:self 
                    action:@selector(stopTrack:)
          forControlEvents:UIControlEventTouchDown];
        
        [stopBtn release];
        
        UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(340, 400, 43, 43)];
        [pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
        [self addSubview:pauseBtn];
        [pauseBtn addTarget:self 
                     action:@selector(pauseTrack:)
           forControlEvents:UIControlEventTouchDown];
        
        [pauseBtn release];
        
        UIButton *prevBtn = [[UIButton alloc]initWithFrame:CGRectMake(420, 400, 43, 43)];
        [prevBtn setBackgroundImage:prevImg forState:UIControlStateNormal];
        [self addSubview:prevBtn];
        [prevBtn addTarget:self 
                    action:@selector(playprevTrack:)
          forControlEvents:UIControlEventTouchDown];
        
        [prevBtn release];
            
        UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(500, 400, 43, 43)];
        [nextBtn setBackgroundImage:nextImg forState:UIControlStateNormal];
        [self addSubview:nextBtn];
        [nextBtn addTarget:self 
                    action:@selector(playnextTrack:)
          forControlEvents:UIControlEventTouchDown];
        
        [nextBtn release];
        
        
        effectController *timepitchController = [[effectController alloc]initWithFrame:CGRectMake(10, 512, 40, 40)];
        timepitchController.backgroundColor = [UIColor whiteColor];
        [self addSubview:timepitchController];
        [timepitchController setTag:1];
        
        UILabel *lblTimepitch = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        lblTimepitch.textAlignment = UITextAlignmentCenter;
        lblTimepitch.textColor = [UIColor blackColor];
        lblTimepitch.backgroundColor = [UIColor clearColor];
        lblTimepitch.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
        lblTimepitch.text = @"T";
        [timepitchController addSubview:lblTimepitch];
        [lblTimepitch release];
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] 
                                              initWithTarget:self action:@selector(showEffectOptionsPitch:)];
        lpgr.minimumPressDuration = 1.3; //seconds
        [timepitchController addGestureRecognizer:lpgr];
        [lpgr release];
        
        [timepitchController release];
       
        
        
        effectController *lopassController = [[effectController alloc]initWithFrame:CGRectMake(100, 100, 40, 40)];
        lopassController.backgroundColor = [UIColor whiteColor];
        [self addSubview:lopassController];
        [lopassController setTag:2];
        
        UILabel *lblLopass = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
        lblLopass.textAlignment =  UITextAlignmentCenter;
        lblLopass.textColor = [UIColor blackColor];
        lblLopass.backgroundColor = [UIColor clearColor];
        lblLopass.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
        lblLopass.text = @"L";
        [lopassController addSubview:lblLopass];
        [lblLopass release];   
        
        [lopassController release];
      
        effectController *hipassController = [[effectController alloc]initWithFrame:CGRectMake(300, 0, 40, 40)];
        hipassController.backgroundColor = [UIColor whiteColor];
        [self addSubview:hipassController];
        [hipassController setTag:3];
        
        UILabel *lblHipass = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
        lblHipass.textAlignment =  UITextAlignmentCenter;
        lblHipass.textColor = [UIColor blackColor];
        lblHipass.backgroundColor = [UIColor clearColor];
        lblHipass.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
        lblHipass.text = @"H";
        [hipassController addSubview:lblHipass];
        [lblHipass release];  
        
        [hipassController release];
                       
        effectController *reverbController = [[effectController alloc]initWithFrame:CGRectMake(300, 500, 40, 40)];
        reverbController.backgroundColor = [UIColor whiteColor];
        [self addSubview:reverbController];
        [reverbController setTag:4];
        
        UILabel *lblReverb = [[UILabel alloc]initWithFrame:CGRectMake(5,5,30,30)];
        lblReverb.textAlignment =  UITextAlignmentCenter;
        lblReverb.textColor = [UIColor blackColor];
        lblReverb.backgroundColor = [UIColor clearColor];
        lblReverb.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
        lblReverb.text = @"R";
        [reverbController addSubview:lblReverb];
        [lblReverb release]; 
        [reverbController release];
        
        effectController *mastervolController = [[effectController alloc]initWithFrame:CGRectMake(200, 10, 60, 60)];
        mastervolController.backgroundColor = [UIColor whiteColor];
        [self addSubview:mastervolController];
        [mastervolController setTag:5]; 
        
        UILabel *lblvol = [[UILabel alloc]initWithFrame:CGRectMake(0,15,60,30)];
        lblvol.textAlignment =  UITextAlignmentCenter;
        lblvol.textColor = [UIColor blackColor];
        lblvol.backgroundColor = [UIColor clearColor];
        lblvol.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
        lblvol.text = @"Vol";
        [mastervolController addSubview:lblvol];
        [lblvol release];   
        [mastervolController release];
        
        self.trackControlBG = [[UIView alloc]initWithFrame:CGRectMake(100, 860, 0, 50)];
        self.trackControlBG.backgroundColor = [UIColor whiteColor];
        
        self.trackControlFG = [[UIView alloc]initWithFrame:CGRectMake(0, 5, 0, 40)];
        [self.trackControlBG addSubview:trackControlFG];
        self.trackControlFG.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.trackControlBG];
        
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(trackdurationSwipe:)];
        [self.trackControlBG addGestureRecognizer:pgr];
        [pgr release];
        
            
    }
    return self;
}


- (void)trackdurationSwipe:(UIPanGestureRecognizer *)gesture{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint panval;
        panval = [gesture translationInView:self];
        
        [main setTrackPosition:(panval.x/10)];
        
    }
}


- (void)playnextTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSURL *currTrack = [[main.playbackManager currentTrack]spotifyURL];
    int currTrackIndex = 0;
    int indexPlaying = 0;
    int cueLength = [[Shared sharedInstance].masterCue count];
    for (NSURL *url in [Shared sharedInstance].masterCue){
        if ([url isEqual:currTrack]){
            indexPlaying = currTrackIndex;
        }
        currTrackIndex++;
    }
    if (indexPlaying+1 < cueLength){
        NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:indexPlaying+1];
        SPTrack *track =[[SPSession sharedSession]trackForURL:url];
        [main playnewTrack:track];
        
    }    
}
- (void)playprevTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSURL *currTrack = [[main.playbackManager currentTrack]spotifyURL];
    int currTrackIndex = 0;
    int indexPlaying = 0;
    for (NSURL *url in [Shared sharedInstance].masterCue){
        if ([url isEqual:currTrack]){
            indexPlaying = currTrackIndex;
        }
        currTrackIndex++;
    }
    if (indexPlaying-1 >= 0){
        NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:indexPlaying-1];
        SPTrack *track =[[SPSession sharedSession]trackForURL:url];
        [main playnewTrack:track];
        
        
    }    
}
- (void)playTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!main.playbackManager.isPlaying){
        if ([[Shared sharedInstance].masterCue count] > 0){
            NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:0];
            
            SPTrack *trackToPlay = [SPTrack trackForTrackURL:url inSession:[SPSession sharedSession]];
            [main.playbackManager playTrack:trackToPlay error:nil];
            
        }
            
    }
    
}

- (void)stopTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (main.playbackManager.isPlaying){
        [main.playbackManager stopAUGraph];
        [main.playbackManager setIsPlaying:NO];
    }
    
}

- (void)pauseTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (main.playbackManager.isPlaying){
        [[SPSession sharedSession]setPlaying:NO];
    }else{
        [[SPSession sharedSession]setPlaying:YES];
        [main.playbackManager setVolume:1];
    }

    
}

- (void)setTrackTitleAndArtist:(SPTrack *)track{
    NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
    
    self.artistLbl.text = artists;
    self.titleLbl.text = track.name;
    
}

-(void)showEffectOptionsPitch:(UILongPressGestureRecognizer *)gestureRecognizer{
   
    
    if(UIGestureRecognizerStateBegan == gestureRecognizer.state) {
        UIView *piece = [gestureRecognizer view];
        CGPoint pos = piece.frame.origin;
        
        UIView *effectOptionsView = [[UIView alloc]initWithFrame:CGRectMake(pos.x+60,pos.y-80, 200, 130)];
        effectOptionsView.backgroundColor = [UIColor clearColor];
        
        [self insertSubview:effectOptionsView atIndex:0];
        
        UIButton *pitch1 = [UIButton buttonWithType:UIButtonTypeCustom];
        pitch1.frame = CGRectMake(0, 30, 200, 40);// position in the parent view and set the size of the
        pitch1.backgroundColor = [UIColor whiteColor];
        [pitch1 setTitle:[NSString stringWithFormat:@"playbackrate"] forState:UIControlStateNormal];
        [pitch1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
       
        [pitch1 addTarget:self 
                   action:@selector(setTimePitchEffect:)
         forControlEvents:UIControlEventTouchDown];
        [pitch1 setTag:1000];
        
        [effectOptionsView addSubview:pitch1];
      //  [pitch1 release];
        
        UIButton *pitch2 = [UIButton buttonWithType:UIButtonTypeCustom];
        pitch2.frame = CGRectMake(0, 80, 200, 40);// position in the parent view and set the size of the
        pitch2.backgroundColor = [UIColor whiteColor];
        [pitch2 setTitle:[NSString stringWithFormat:@"playbackcents"] forState:UIControlStateNormal];
        [pitch2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [pitch2 addTarget:self 
                   action:@selector(setTimePitchEffect:)
         forControlEvents:UIControlEventTouchDown];
        
        [pitch2 setTag:1001];
        [effectOptionsView addSubview:pitch2];
    //    [pitch2 release]; 
        
        [self bringSubviewToFront:effectOptionsView];
        
        [effectOptionsView release];
        piece.backgroundColor = [UIColor whiteColor];
        
    
    }
    
    if(UIGestureRecognizerStateChanged == gestureRecognizer.state) {
    }
    
    if(UIGestureRecognizerStateEnded == gestureRecognizer.state) {
   
    
    }
    
}

- (void)setTimePitchEffect:(id)sender{
    UIButton *btn = (UIButton*)sender;
    
    self.selBtn = btn;
    
    btn.backgroundColor = [UIColor grayColor];
    
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(removeTimePitchPopup) userInfo:nil repeats:NO];
     
}

- (void)removeTimePitchPopup{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (self.selBtn.tag == 1000){
        [main.playbackManager resetVarispeedUnit:1001];
        [Shared sharedInstance].effectgridY = 400;
        [Shared sharedInstance].curVariSpeedEffect = 0;
    }
    else{
        [main.playbackManager resetVarispeedUnit:1000];
        [Shared sharedInstance].effectgridY = 600;
        [Shared sharedInstance].curVariSpeedEffect = 1;
        
    }
    UIView *parentView = [self.selBtn superview];
    [parentView removeFromSuperview];

}

- (void)setPlayduration:(double)length{
    
    NSLog(@"duration: %f",length);
    self.trackControlBG.frame = CGRectMake(20, 860, length, 50);
    
}

- (void)updatePlayduration:(double)val{
    
    self.trackControlFG.frame = CGRectMake(0, 5, val, 40);
    
}


- (void)dealloc{
    [self.artistLbl release];
    [self.titleLbl release];
    [self.selBtn release];
    [self.trackControlBG release];
    [self.trackControlFG release];
   
}

@end
