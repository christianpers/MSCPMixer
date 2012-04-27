//
//  playbackViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "playbackViewController.h"
#import "Shared.h"
#import "AppDelegate.h"
#import <AVFoundation/AVAsset.h>
#import <QuartzCore/QuartzCore.h>


@implementation playbackViewController

@synthesize artistLbl, titleLbl, selBtn;
@synthesize trackControlBG, trackControlFG, controlView;
@synthesize timepitchController, lopassController, hipassController, channelOneVolController, effectParentView;
@synthesize fftView;

@synthesize line;
@synthesize timepitchControllerCh2,lopassControllerCh2, hipassControllerCh2,controlViewCh2, channelTwoVolController;
@synthesize effectParentViewCh2, addtrack, artistlblCh2, titlelblCh2;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
   
    CGRect plbackrect = CGRectMake(0, 0, winSize.width, winSize.height);
    self.view = [[UIView alloc] initWithFrame:plbackrect];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    /*
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    
    UIView *playbackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    self.view = playbackView;
    self.view.backgroundColor = [UIColor blackColor];
    
    [playbackView release];
    */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGSize parentSize = self.view.frame.size;
 
    //fft shieed
    self.fftView = [[fftAnalyzerView alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    //    self.fftView.backgroundColor = [UIColor whiteColor];
    //  [self addSubview:self.fftView];
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[main.playbackManager setFFTView:self.fftView];
    
    self.artistLbl = [[UILabel alloc]initWithFrame:CGRectMake((parentSize.width/2)-(300/2),200,300,30)];
    self.artistLbl.textAlignment =  UITextAlignmentCenter;
    self.artistLbl.textColor = [UIColor whiteColor];
    self.artistLbl.backgroundColor = [UIColor clearColor];
    self.artistLbl.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(26.0)];
    self.artistLbl.text = @"Artist";
    
    [self.view addSubview:self.artistLbl];
    
    self.titleLbl = [[UILabel alloc]initWithFrame:CGRectMake((parentSize.width/2)-(300/2),260,300,30)];
    self.titleLbl.textAlignment =  UITextAlignmentCenter;
    self.titleLbl.textColor = [UIColor whiteColor];
    self.titleLbl.backgroundColor = [UIColor clearColor];
    self.titleLbl.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(26.0)];
    self.titleLbl.text = @"Title";
    
    [self.view addSubview:self.titleLbl];
    
    
    UIView *cView = [[UIView alloc]initWithFrame:CGRectMake((parentSize.width/2)-(400/2), 430, 400, 70)];
    cView.backgroundColor = [UIColor clearColor];
    self.controlView = cView;
    [self.view addSubview:self.controlView];
    [cView release];
    
    NSString* imagePathNext = [[NSBundle mainBundle] pathForResource:@"skip forward" ofType:@"png"];
    NSString* imagePathPrev = [[NSBundle mainBundle] pathForResource:@"skip back" ofType:@"png"];
    NSString* imagePathStop = [[NSBundle mainBundle] pathForResource:@"stop" ofType:@"png"];
    NSString* imagePathPause = [[NSBundle mainBundle] pathForResource:@"pause" ofType:@"png"];
    NSString* imagePathPlay = [[NSBundle mainBundle] pathForResource:@"play" ofType:@"png"];
    
    UIImage *nextImg = [UIImage imageWithContentsOfFile:imagePathNext];
    UIImage *prevImg = [UIImage imageWithContentsOfFile:imagePathPrev];
    UIImage *stopImg = [UIImage imageWithContentsOfFile:imagePathStop];
    UIImage *pauseImg = [UIImage imageWithContentsOfFile:imagePathPause];
    UIImage *playImg = [UIImage imageWithContentsOfFile:imagePathPlay];
    
    int btnsize = 63;
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 13, btnsize, btnsize)];
    [playBtn setBackgroundImage:playImg forState:UIControlStateNormal];
    [self.controlView addSubview:playBtn];
    [playBtn addTarget:self 
                action:@selector(playTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [playBtn release];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 13, btnsize, btnsize)];
    [stopBtn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlView addSubview:stopBtn];
    [stopBtn addTarget:self 
                action:@selector(stopTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [stopBtn release];
    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(180, 13, btnsize, btnsize)];
    [pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlView addSubview:pauseBtn];
    [pauseBtn addTarget:self 
                 action:@selector(pauseTrack:)
       forControlEvents:UIControlEventTouchDown];
    
    [pauseBtn release];
    
    UIButton *prevBtn = [[UIButton alloc]initWithFrame:CGRectMake(260, 13, btnsize, btnsize)];
    [prevBtn setBackgroundImage:prevImg forState:UIControlStateNormal];
    [self.controlView addSubview:prevBtn];
    [prevBtn addTarget:self 
                action:@selector(playprevTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [prevBtn release];
    
    UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(340, 13, btnsize, btnsize)];
    [nextBtn setBackgroundImage:nextImg forState:UIControlStateNormal];
    [self.controlView addSubview:nextBtn];
    [nextBtn addTarget:self 
                action:@selector(playnextTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [nextBtn release];
    
    self.effectParentView = [[UIView alloc]initWithFrame:CGRectMake(50, 60, parentSize.width-100, parentSize.height-180)];
    self.effectParentView.backgroundColor = [UIColor clearColor];
    self.effectParentView.layer.borderColor = [[UIColor whiteColor] CGColor];
    // self.effectParentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.effectParentView];
    
    
    self.timepitchController = [[effectController alloc]initWithFrame:CGRectMake(10, (self.view.frame.size.height/2)-20, 63, 63)];
    self.timepitchController.backgroundColor = [UIColor whiteColor];
    [self.effectParentView addSubview:self.timepitchController];
    [self.timepitchController setTag:1];
    
    NSString* tempoImgStr = [[NSBundle mainBundle] pathForResource:@"tempo" ofType:@"png"];
    UIImage *tempoImg = [UIImage imageWithContentsOfFile:tempoImgStr];
    
    self.timepitchController.backgroundColor = [UIColor colorWithPatternImage:tempoImg];
    
    
    self.lopassController = [[effectController alloc]initWithFrame:CGRectMake(216, 230, 63, 63)];
    self.lopassController.backgroundColor = [UIColor whiteColor];
    [self.effectParentView addSubview:self.lopassController];
    [self.lopassController setTag:2];
    
    NSString* lopassImgStr = [[NSBundle mainBundle] pathForResource:@"lopass" ofType:@"png"];
    UIImage *lopassImg = [UIImage imageWithContentsOfFile:lopassImgStr];
    
    self.lopassController.backgroundColor = [UIColor colorWithPatternImage:lopassImg];
  
    self.hipassController = [[effectController alloc]initWithFrame:CGRectMake(300, 0, 63, 63)];
    self.hipassController.backgroundColor = [UIColor whiteColor];
    [self.effectParentView addSubview:self.hipassController];
    [self.hipassController setTag:3];
    
    NSString* hipassImgStr = [[NSBundle mainBundle] pathForResource:@"hipass" ofType:@"png"];
    UIImage *hipassImg = [UIImage imageWithContentsOfFile:hipassImgStr];
    
    self.hipassController.backgroundColor = [UIColor colorWithPatternImage:hipassImg];
    
   
    self.channelOneVolController = [[effectController alloc]initWithFrame:CGRectMake(200, 10, 63, 63)];
    self.channelOneVolController.backgroundColor = [UIColor whiteColor];
    [self.effectParentView addSubview:self.channelOneVolController];
    [self.channelOneVolController setTag:5]; 
    
    NSString* volImgStr = [[NSBundle mainBundle] pathForResource:@"vol" ofType:@"png"];
    UIImage *volImg = [UIImage imageWithContentsOfFile:volImgStr];
    
    self.channelOneVolController.backgroundColor = [UIColor colorWithPatternImage:volImg];
   
    self.trackControlBG = [[UIView alloc]initWithFrame:CGRectMake(100, 860, 0, 50)];
    self.trackControlBG.backgroundColor = [UIColor whiteColor];
    
    self.trackControlFG = [[UIView alloc]initWithFrame:CGRectMake(0, 5, 0, 40)];
    [self.trackControlBG addSubview:trackControlFG];
    self.trackControlFG.backgroundColor = [UIColor blackColor];
    
    
    UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(trackdurationSwipe:)];
    [self.trackControlBG addGestureRecognizer:pgr];
    [pgr release];
    
    
    main.playbackManager.playbackIsPaused = NO;
    
    NSString* secchImgStr = [[NSBundle mainBundle] pathForResource:@"itunes channel" ofType:@"png"];
    UIImage *secchImg = [UIImage imageWithContentsOfFile:secchImgStr];
    
    UIButton *secchannelBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width/2)-(175/2), self.view.frame.size.height-88, 175, 51)];
    [secchannelBtn setBackgroundImage:secchImg forState:UIControlStateNormal];
 //   [self.view addSubview:secchannelBtn];
    
    [secchannelBtn addTarget:self 
                      action:@selector(activateMixerView)
            forControlEvents:UIControlEventTouchDown];
    
    [secchannelBtn release];
    
   
    
    /*
     ------------------
                        */
    
    
    //create mixermode channel 2 interface
    UIView *c2View = [[UIView alloc]initWithFrame:CGRectMake(690, 430, 150, 70)];
    c2View.backgroundColor = [UIColor clearColor];
    self.controlViewCh2 = c2View;
    [self.view addSubview:self.controlViewCh2];
    self.controlViewCh2.hidden = YES;
    [c2View release];
    
    
    UIButton *stopch2Btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 13, 63, 63)];
    [stopch2Btn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlViewCh2 addSubview:stopch2Btn];
    [stopch2Btn addTarget:self 
                   action:@selector(stopTrackCh2:)
         forControlEvents:UIControlEventTouchDown];
    
    [stopch2Btn release];
    
    UIButton *pausech2Btn = [[UIButton alloc]initWithFrame:CGRectMake(90, 13, 63, 63)];
    [pausech2Btn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlViewCh2 addSubview:pausech2Btn];
    [pausech2Btn addTarget:self 
                    action:@selector(pauseTrackCh2:)
          forControlEvents:UIControlEventTouchDown];
    
    [pausech2Btn release];
    
    
    self.effectParentViewCh2 = [[UIView alloc]initWithFrame:CGRectMake(590, 20, 350, 600)];
    self.effectParentViewCh2.backgroundColor = [UIColor clearColor];
    self.effectParentViewCh2.hidden = YES;
    [self.view addSubview:self.effectParentViewCh2];
    
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake((1024/2)-1, 10, 2, 700)];
    self.line.backgroundColor = [UIColor whiteColor];
    self.line.hidden = YES;
    [self.view addSubview:self.line];
    
    self.lopassControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(200, 500, 63, 63)];
    self.lopassControllerCh2.backgroundColor = [UIColor colorWithPatternImage:lopassImg];
    [self.lopassControllerCh2 setTag:6];
    [self.effectParentViewCh2 addSubview:self.lopassControllerCh2];
    
    self.hipassControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(300, 10, 63, 63)];
    self.hipassControllerCh2.backgroundColor = [UIColor colorWithPatternImage:hipassImg];
    [self.hipassControllerCh2 setTag:8];
    [self.effectParentViewCh2 addSubview:self.hipassControllerCh2];
    
    self.timepitchControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(100, 350, 63, 63)];
    self.timepitchControllerCh2.backgroundColor = [UIColor colorWithPatternImage:tempoImg];
    [self.timepitchControllerCh2 setTag:9];
    [self.effectParentViewCh2 addSubview:self.timepitchControllerCh2];
    
    self.channelTwoVolController = [[effectController alloc]initWithFrame:CGRectMake(200, 10, 63, 63)];
    self.channelTwoVolController.backgroundColor = [UIColor colorWithPatternImage:volImg];
    [self.channelTwoVolController setTag:7];
    [self.effectParentViewCh2 addSubview:self.channelTwoVolController];
    
    self.addtrack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addtrack.frame = CGRectMake(810, 22, 200, 30);// position in the parent view and set the size of the
   // self.addtrack.backgroundColor = [UIColor blackColor];
    [self.addtrack setTitle:[NSString stringWithFormat:@"Add track +"] forState:UIControlStateNormal];
    [self.addtrack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addtrack.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(24.0)];
    
    [self.addtrack addTarget:self 
                 action:@selector(showMediaPicker)
       forControlEvents:UIControlEventTouchDown];
    self.addtrack.hidden = YES;
    [self.view addSubview:self.addtrack];
    
    
    
    self.artistlblCh2 = [[UILabel alloc]initWithFrame:CGRectMake(620, 205, 300, 30)];
    self.artistlblCh2.textColor = [UIColor whiteColor];
    self.artistlblCh2.textAlignment = UITextAlignmentCenter;
    self.artistlblCh2.backgroundColor = [UIColor clearColor];
    self.artistlblCh2.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(26.0)];
    self.artistlblCh2.text = @"Artist";
    self.artistlblCh2.hidden = YES;
    
    [self.view addSubview:self.artistlblCh2];
    
    self.titlelblCh2 = [[UILabel alloc]initWithFrame:CGRectMake(620,260,300,30)];
    self.titlelblCh2.textAlignment =  UITextAlignmentCenter;
    self.titlelblCh2.textColor = [UIColor whiteColor];
    self.titlelblCh2.backgroundColor = [UIColor clearColor];
    self.titlelblCh2.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(26.0)];
    self.titlelblCh2.text = @"Title";
    self.titlelblCh2.hidden = YES;
    
    [self.view addSubview:self.titlelblCh2];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self.artistLbl release];
    [self.titleLbl release];
    [self.selBtn release];
    [self.trackControlBG release];
    [self.trackControlFG release];
    [self.controlView release];
    [self.timepitchController release];
    [self.lopassController release];
    [self.hipassController release];
    [self.channelOneVolController release];
    [self.effectParentView release];
    [self.fftView release];
    [self.line release];
    [self.artistlblCh2 release];
    [self.titlelblCh2 release];
    [self.timepitchControllerCh2 release];
    [self.hipassControllerCh2 release];
    [self.lopassControllerCh2 release];
    [self.effectParentViewCh2 release];
    [self.controlViewCh2 release];
    [self.addtrack release];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }        
}

- (void)trackdurationSwipe:(UIPanGestureRecognizer *)gesture{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint panval;
        panval = [gesture translationInView:self.view];
        
        [main setTrackPosition:(panval.x/10)];
        
    }
}

- (void)callmainplaytrack:(SPTrack *)track{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
    [main playnewTrack:track];
    
}

-(void)callfadeInMusicCh1{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
    [main.playbackManager fadeInMusicCh1];
    
}


- (void)playnextTrack:(id)sender{
    UIButton *next = (UIButton *)sender;
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [next.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
    int indexPlaying = [Shared sharedInstance].currTrackCueNum;
    int cueLength = [[Shared sharedInstance].masterCue count];
   
    if (indexPlaying+1 < cueLength){
        [Shared sharedInstance].currTrackCueNum++;
        NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:indexPlaying+1];
        SPTrack *track =[[SPSession sharedSession]trackForURL:url];
        [main.playbackManager fadeOutMusicCh1];
        [self performSelector:@selector(callmainplaytrack:) withObject:track afterDelay:.6];
        [self performSelector:@selector(callfadeInMusicCh1) withObject:nil afterDelay:.8];
        
    }    
}
- (void)playprevTrack:(id)sender{
    UIButton *prev = (UIButton *)sender;
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [prev.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int indexPlaying = [Shared sharedInstance].currTrackCueNum;
 
    if (indexPlaying-1 >= 0){
        [Shared sharedInstance].currTrackCueNum -= 1;
        NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:indexPlaying-1];
        SPTrack *track =[[SPSession sharedSession]trackForURL:url];
        [main.playbackManager fadeOutMusicCh1];
        [self performSelector:@selector(callmainplaytrack:) withObject:track afterDelay:.6];
        [self performSelector:@selector(callfadeInMusicCh1) withObject:nil afterDelay:.8];
    }    
}
- (void)playTrack:(id)sender{
    UIButton *play = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [play.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    if (!main.playbackManager.isPlaying){
        if ([[Shared sharedInstance].masterCue count] > 0){
            NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:0];
            
            [Shared sharedInstance].currTrackCueNum = 0;
            
            SPTrack *trackToPlay = [SPTrack trackForTrackURL:url inSession:[SPSession sharedSession]];
            [main.playbackManager playTrack:trackToPlay error:nil];
            
        }
        
    }
    
}

- (void)stopTrack:(id)sender{
    UIButton *stop = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [stop.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    if (main.playbackManager.isPlaying){
        // [main.playbackManager stopAUGraph];
        [main.playbackManager setIsPlaying:NO];
        [self resetTrackTitleAndArtist];
    }
    
}

- (void)pauseTrack:(id)sender{
    UIButton *pause = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!main.playbackManager.playbackIsPaused){
        
        if (main.playbackManager.isPlaying){
            main.playbackManager.playbackIsPaused = YES;
            [[SPSession sharedSession]setPlaying:NO];
            
            CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
            fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
            fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
            fadeAnimation.duration=.7;
            fadeAnimation.repeatCount=INFINITY;
            fadeAnimation.autoreverses=YES;
            
            [pause.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
        }
    }
    else{
        [[SPSession sharedSession]setPlaying:YES];
        main.playbackManager.playbackIsPaused = NO;
        [main.cueController.tableView reloadData];
        
        [pause.layer removeAllAnimations];
        
        
    }
    
    
    
}

- (void)resetTrackTitleAndArtist{
    
    self.artistLbl.text = @"Artist";
    self.titleLbl.text = @"Title";
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
        
        [self.view insertSubview:effectOptionsView atIndex:0];
        
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
        
        [self.view bringSubviewToFront:effectOptionsView];
        
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


- (void)setmixerModeOn{
    
   // self.view.backgroundColor = [UIColor blackColor];
    self.controlView.center = CGPointMake(250, 470);
    self.artistLbl.center = CGPointMake(250, 215);
    self.titleLbl.center = CGPointMake(250, 275);
    
    self.effectParentViewCh2.hidden = NO;
    self.line.hidden = NO;
    self.addtrack.hidden = NO;
    self.controlViewCh2.hidden = NO;
    self.artistlblCh2.hidden = NO;
    self.titlelblCh2.hidden = NO;
    
    self.effectParentView.frame = CGRectMake(20, 20, 440, 600);
    
}

- (void)setonechannelmodeOn{
    self.controlView.center = CGPointMake(380, 470);
    self.artistLbl.center = CGPointMake(380, 215);
    self.titleLbl.center = CGPointMake(380, 275);
  //  self.view.backgroundColor = [UIColor blackColor];
    
    self.effectParentViewCh2.hidden = YES;
    self.line.hidden = YES;
    self.addtrack.hidden = YES;
    self.controlViewCh2.hidden = YES;
    self.artistlblCh2.hidden = YES;
    self.titlelblCh2.hidden = YES;
    
    
    self.effectParentView.frame = CGRectMake(50, 40, 650, 930);
    
    
}


//channel 2 functions below

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[mediaPicker dismissModalViewControllerAnimated:YES];
    
    
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
                             main.cueController.view.hidden = NO;
                             main.airplayIcon.hidden = NO;
                             main.userTxtBtn.hidden = NO;
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
    
	[mediaPicker dismissModalViewControllerAnimated:YES];
    
    [UIView animateWithDuration:1
                     animations:^{
                         //     self.tableView.alpha = 1;
                         //     self.tableView.hidden = YES;
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
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
    mediaPicker.view.frame = CGRectMake(0, 0, 1024, 768);
    mediaPicker.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[main.mainViewController presentModalViewController:mediaPicker animated:YES];
    
    
    main.cueController.view.hidden = YES;
    main.airplayIcon.hidden = YES;
    main.userTxtBtn.hidden = YES;
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    [everything setGroupingType: MPMediaGroupingAlbum];
    
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

- (void)pauseTrackCh2:(id)sender{
    UIButton *pause = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (isPaused){
        isPaused = NO;
        [main.playbackManager canRead];
        
        [pause.layer removeAllAnimations];
    }else{
        isPaused = YES;
        [main.playbackManager cantRead];
        
        CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
        fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
        fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
        fadeAnimation.duration=.7;
        fadeAnimation.repeatCount=INFINITY;
        fadeAnimation.autoreverses=YES;
        
        [pause.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    }
    
}

-(void)stopTrackCh2:(id)sender{
    UIButton *stop = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [stop.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    [main.playbackManager cantRead];
    
    [self freeAudio];
    
    [self initDataVar];
    
    //[main.playbackManager removeSecChannelCallback];
    [main.playbackManager removeSecMastermixerBus];
    
    [main.playbackManager toggleChannelTwoPlayingStatus:NO];
    
    
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




@end
