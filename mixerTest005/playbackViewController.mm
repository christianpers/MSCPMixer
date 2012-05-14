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
@synthesize controlView;
@synthesize timepitchController, lopassController, hipassController, channelOneVolController, effectParentView;
@synthesize fftView;
@synthesize crossfadeKnob;
@synthesize playBtn, pauseBtn, playch2Btn, pausech2Btn;

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
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	// Do any additional setup after loading the view.
    CGSize parentSize = self.view.frame.size;
    
    NSString* bgImgStr = [[NSBundle mainBundle] pathForResource:@"mscp logo medium" ofType:@"png"];
    UIImage *bgImg = [UIImage imageWithContentsOfFile:bgImgStr];
    
    bgLogo = [[UIImageView alloc]initWithImage:bgImg];
    bgLogo.frame = CGRectMake(200, 140, 393, 319);
    [self.view addSubview:bgLogo];
    
    [bgLogo release];
    
    bgLogoRight = [[UIImageView alloc]initWithImage:bgImg];
    bgLogoRight.frame = CGRectMake(590, 140, 393, 319);
    bgLogoRight.hidden = YES;
    [self.view addSubview:bgLogoRight];
    [bgLogoRight release];
    
    timeRemainingCh1 = [[UILabel alloc]initWithFrame:CGRectMake(340, 360, 100, 30)];
    timeRemainingCh1.textColor = [UIColor whiteColor];
    timeRemainingCh1.textAlignment = UITextAlignmentCenter;
    timeRemainingCh1.backgroundColor = [UIColor clearColor];
    timeRemainingCh1.font =  [UIFont fontWithName:@"GothamHTF-BookItalic" size:(22.0)];
    [self.view addSubview:timeRemainingCh1];
    [timeRemainingCh1 release];
    
    
    effectParamCh1Nr1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 20)];
    effectParamCh1Nr1.textAlignment = UITextAlignmentLeft;
    effectParamCh1Nr1.textColor = [UIColor whiteColor];
    effectParamCh1Nr1.backgroundColor = [UIColor clearColor];
    effectParamCh1Nr1.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(16.0)];
    [self.view addSubview:effectParamCh1Nr1];
    
    effectParamCh1Nr2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 100, 20)];
    effectParamCh1Nr2.textAlignment = UITextAlignmentLeft;
    effectParamCh1Nr2.textColor = [UIColor whiteColor];
    effectParamCh1Nr2.backgroundColor = [UIColor clearColor];
    effectParamCh1Nr2.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(16.0)];
    [self.view addSubview:effectParamCh1Nr2];
    
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
    
    self.playBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, 13, btnsize, btnsize)];
    [self.playBtn setBackgroundImage:playImg forState:UIControlStateNormal];
    [self.controlView addSubview:self.playBtn];
    [self.playBtn addTarget:self 
                action:@selector(playTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [self.playBtn release];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(140, 13, btnsize, btnsize)];
    [stopBtn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlView addSubview:stopBtn];
    [stopBtn addTarget:self 
                action:@selector(stopTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [stopBtn release];
    
    self.pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, 13, btnsize, btnsize)];
    [self.pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlView addSubview:self.pauseBtn];
    self.pauseBtn.hidden = YES;
    [self.pauseBtn addTarget:self 
                 action:@selector(pauseTrack:)
       forControlEvents:UIControlEventTouchDown];
    
    [self.pauseBtn release];
    
    UIButton *prevBtn = [[UIButton alloc]initWithFrame:CGRectMake(220, 13, btnsize, btnsize)];
    [prevBtn setBackgroundImage:prevImg forState:UIControlStateNormal];
    [self.controlView addSubview:prevBtn];
    [prevBtn addTarget:self 
                action:@selector(playprevTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [prevBtn release];
    
    UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(300, 13, btnsize, btnsize)];
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
    
    
    UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setDefaultPitchController:)];
    [doubletap setNumberOfTapsRequired:2];
   // [doubletap setNumberOfTouchesRequired:2];
    
    self.timepitchController = [[effectController alloc]initWithFrame:CGRectMake(10, (self.view.frame.size.height/2)-80, 63, 63)];
    [self.timepitchController addGestureRecognizer:doubletap];
    
    [self.effectParentView addSubview:self.timepitchController];
    [self.timepitchController setTag:1];
    
    [doubletap release];
    
    NSString* tempoImgStr = [[NSBundle mainBundle] pathForResource:@"tempo" ofType:@"png"];
    UIImage *tempoImg = [UIImage imageWithContentsOfFile:tempoImgStr];
    
    self.timepitchController.backgroundColor = [UIColor colorWithPatternImage:tempoImg];
    
    
    self.lopassController = [[effectController alloc]initWithFrame:CGRectMake(216, 786, 63, 63)];
    self.lopassController.backgroundColor = [UIColor whiteColor];
    [self.effectParentView addSubview:self.lopassController];
    [self.lopassController setTag:2];
    
    NSString* lopassImgStr = [[NSBundle mainBundle] pathForResource:@"lopass" ofType:@"png"];
    UIImage *lopassImg = [UIImage imageWithContentsOfFile:lopassImgStr];
    
    self.lopassController.backgroundColor = [UIColor colorWithPatternImage:lopassImg];
  
    self.hipassController = [[effectController alloc]initWithFrame:CGRectMake(400, 10, 63, 63)];
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
    
   
    [self.view addSubview:self.controlView];
    
    /*
     ------------------
                        */
    
    
    //create mixermode channel 2 interface
    
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
    
    
    
    
    UIView *c2View = [[UIView alloc]initWithFrame:CGRectMake(690, 430, 150, 70)];
    c2View.backgroundColor = [UIColor clearColor];
    self.controlViewCh2 = c2View;
    self.controlViewCh2.hidden = YES;
    [c2View release];
    
    timeRemainingCh2 = [[UILabel alloc]initWithFrame:CGRectMake(740, 340, 100, 30)];
    timeRemainingCh2.textColor = [UIColor whiteColor];
    timeRemainingCh2.textAlignment = UITextAlignmentCenter;
    timeRemainingCh2.backgroundColor = [UIColor clearColor];
    timeRemainingCh2.font =  [UIFont fontWithName:@"GothamHTF-BookItalic" size:(22.0)];
    timeRemainingCh2.hidden = YES;
    [self.view addSubview:timeRemainingCh2];
    [timeRemainingCh2 release];
    
    
    UIButton *stopch2Btn = [[UIButton alloc]initWithFrame:CGRectMake(15, 13, 63, 63)];
    [stopch2Btn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlViewCh2 addSubview:stopch2Btn];
    [stopch2Btn addTarget:self 
                   action:@selector(stopTrackCh2:)
         forControlEvents:UIControlEventTouchDown];
    
    [stopch2Btn release];
    
    pausech2Btn = [[UIButton alloc]initWithFrame:CGRectMake(90, 13, 63, 63)];
    [pausech2Btn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlViewCh2 addSubview:pausech2Btn];
    [pausech2Btn addTarget:self 
                    action:@selector(pauseTrackCh2:)
          forControlEvents:UIControlEventTouchDown];
    
    [pausech2Btn release];
    
    playch2Btn = [[UIButton alloc]initWithFrame:CGRectMake(90, 13, btnsize, btnsize)];
    [playch2Btn setBackgroundImage:playImg forState:UIControlStateNormal];
    [self.controlViewCh2 addSubview:playch2Btn];
    playch2Btn.hidden = YES;
    [playch2Btn addTarget:self 
                action:@selector(pauseTrackCh2:)
      forControlEvents:UIControlEventTouchDown];
    
    [playch2Btn release];
    
    [self.view addSubview:self.controlViewCh2];
    
    
    self.effectParentViewCh2 = [[UIView alloc]initWithFrame:CGRectMake(570, 170, 400, 450)];
    self.effectParentViewCh2.backgroundColor = [UIColor clearColor];
    self.effectParentViewCh2.hidden = YES;
    [self.view addSubview:self.effectParentViewCh2];
    
    
    self.line = [[UIView alloc]initWithFrame:CGRectMake((1024/2)-1, 10, 2, 570)];
    self.line.backgroundColor = [UIColor whiteColor];
    self.line.hidden = YES;
    [self.view addSubview:self.line];
    
    self.lopassControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(200, 400, 63, 63)];
    self.lopassControllerCh2.backgroundColor = [UIColor colorWithPatternImage:lopassImg];
    [self.lopassControllerCh2 setTag:6];
    [self.effectParentViewCh2 addSubview:self.lopassControllerCh2];
    
    self.hipassControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(50, 0, 63, 63)];
    self.hipassControllerCh2.backgroundColor = [UIColor colorWithPatternImage:hipassImg];
    [self.hipassControllerCh2 setTag:8];
    [self.effectParentViewCh2 addSubview:self.hipassControllerCh2];
    
    UITapGestureRecognizer *doubletapCh2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(setDefaultPitchControllerCh2:)];
    [doubletapCh2 setNumberOfTapsRequired:2];
    
    self.timepitchControllerCh2 = [[effectController alloc]initWithFrame:CGRectMake(100, 225, 63, 63)];
    self.timepitchControllerCh2.backgroundColor = [UIColor colorWithPatternImage:tempoImg];
    [self.timepitchControllerCh2 setTag:9];
    [self.effectParentViewCh2 addSubview:self.timepitchControllerCh2];
    [self.timepitchControllerCh2 addGestureRecognizer:doubletapCh2];
    [doubletapCh2 release];
    
    self.channelTwoVolController = [[effectController alloc]initWithFrame:CGRectMake(170, 0, 63, 63)];
    self.channelTwoVolController.backgroundColor = [UIColor colorWithPatternImage:volImg];
    [self.channelTwoVolController setTag:7];
    [self.effectParentViewCh2 addSubview:self.channelTwoVolController];
    
    self.addtrack = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addtrack.frame = CGRectMake(810, 12, 200, 30);// position in the parent view and set the size of the
   // self.addtrack.backgroundColor = [UIColor blackColor];
    [self.addtrack setTitle:[NSString stringWithFormat:@"Add track +"] forState:UIControlStateNormal];
    [self.addtrack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addtrack.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(24.0)];
    
    [self.addtrack addTarget:self 
                 action:@selector(showMediaPicker)
       forControlEvents:UIControlEventTouchDown];
    self.addtrack.hidden = YES;
    [self.view addSubview:self.addtrack];
    
    
    effectParamCh2Nr1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 100, 20)];
    effectParamCh2Nr1.textAlignment = UITextAlignmentLeft;
    effectParamCh2Nr1.textColor = [UIColor whiteColor];
    effectParamCh2Nr1.backgroundColor = [UIColor clearColor];
    effectParamCh2Nr1.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(16.0)];
    [self.view addSubview:effectParamCh1Nr1];
    
    effectParamCh2Nr2 = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 100, 20)];
    effectParamCh2Nr2.textAlignment = UITextAlignmentLeft;
    effectParamCh2Nr2.textColor = [UIColor whiteColor];
    effectParamCh2Nr2.backgroundColor = [UIColor clearColor];
    effectParamCh2Nr2.font = [UIFont fontWithName:@"GothamHTF-BookItalic" size:(16.0)];
    [self.view addSubview:effectParamCh1Nr2];
    
    
   
    
    
    
    //**crossfade stuff**//
    
    NSString* crossfadeBgImgStr = [[NSBundle mainBundle] pathForResource:@"crossfade base" ofType:@"png"];
    UIImage *crossfadeBgImg = [UIImage imageWithContentsOfFile:crossfadeBgImgStr];
    
    crossfadeBg = [[UIImageView alloc]initWithImage:crossfadeBgImg];
    crossfadeBg.frame = CGRectMake(360, 650, 305, 46);
    crossfadeBg.hidden = YES;
    [self.view addSubview:crossfadeBg];
    [crossfadeBg release];
    
    UIPanGestureRecognizer *knobGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCrossfadeKnob:)];
    
    NSString* crossfadeKnobImgStr = [[NSBundle mainBundle] pathForResource:@"crossfade knob" ofType:@"png"];
    UIImage *crossfadeKnobImg = [UIImage imageWithContentsOfFile:crossfadeKnobImgStr];
    
    self.crossfadeKnob = [[UIImageView alloc]initWithImage:crossfadeKnobImg];
    self.crossfadeKnob.frame = CGRectMake(493, 612, 40, 57);
    self.crossfadeKnob.hidden = YES;
    self.crossfadeKnob.userInteractionEnabled = YES;
    [self.view addSubview:crossfadeKnob];
    [self.crossfadeKnob addGestureRecognizer:knobGr];
   
    [knobGr release];
    [crossfadeKnob release];
    
    crossfadevolch1 = .5;
    crossfadevolch2 = .5;
    
    appStarted = NO;
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self.artistLbl release];
    [self.titleLbl release];
    [self.selBtn release];
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
    [self.crossfadeKnob release];
    [effectParamCh1Nr1 release];
    [effectParamCh1Nr2 release];
    [effectParamCh2Nr1 release];
    [effectParamCh2Nr2 release];
    [playBtn removeFromSuperview];
    [pauseBtn removeFromSuperview];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewwillappear playback view");
  
  /*  if (!appStarted){
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            NSLog(@"landscape playback");
            [self setmixerModeOn];
            
        }     
        appStarted = YES;
    } */
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (main.mainViewController.landscapeMode){
        [self setmixerModeOn];
        
    }
    
    // [self.view addSubview:self.plMainView];
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    NSLog(@"viewdiddisappear playback view");
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }        
}

-(void)panCrossfadeKnob:(UIPanGestureRecognizer *)recognizer{
    NSLog(@"pan piece");
    UIView *piece = [recognizer view];
    
    CGPoint pos = piece.frame.origin;
    CGPoint translation = [recognizer translationInView:[piece superview]];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (pos.x <= 635) {
            [piece setCenter:CGPointMake([piece center].x + translation.x, 640)];
        }else if (pos.x >= 350){
            [piece setCenter:CGPointMake([piece center].x + translation.x, 640)];
        }
    }
    else {
        
        if((pos.x+translation.x >= 350 && pos.x+translation.x <= 635)){
            
            [piece setCenter:CGPointMake([piece center].x + translation.x, 640)];
            [recognizer setTranslation:CGPointZero inView:[piece superview]];
            NSLog(@"center: %f",[piece center].x);
            [self setcrossfadeCurrVol:[piece center].x];
        }
        
    }
}

- (void)setcrossfadeCurrVol:(float)currXval{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    float totDistance = 655 - 330;
    float currdiff = currXval - 350;
    float volch2 = currdiff/totDistance;
    float volch1 = 1 - volch2;
    if (volch1 <= 0.09){
        volch1 = 0.00001;
        volch2 = 1 - volch1;
    }
    else if (volch2 <= 0.09){
        volch2 = 0.00001;
        volch1 = 1 - volch2;
    }
    [main.playbackManager setMasterMixerPanning:volch1 :volch2];
    NSLog(@"ch1: %f ch2: %f",volch1, volch2);
    
    
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
    
    
    if (main.playbackManager.playbackIsPaused){
        [[SPSession sharedSession]setPlaying:YES];
        main.playbackManager.playbackIsPaused = NO;
        [main.mainViewController.tabController.cueController.tableView reloadData];
        [self toggleplayandpause:YES];
        
    }
    else if (!main.playbackManager.isPlaying){
        if ([[Shared sharedInstance].masterCue count] > 0){
            NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:0];
            
            [Shared sharedInstance].currTrackCueNum = 0;
            
            SPTrack *trackToPlay = [SPTrack trackForTrackURL:url inSession:[SPSession sharedSession]];
            [main.playbackManager playTrack:trackToPlay error:nil];
            
            [self toggleplayandpause:YES];
            
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
        [self toggleplayandpause:NO];
    }
    
}

- (void)pauseTrack:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!main.playbackManager.playbackIsPaused){
        
        if (main.playbackManager.isPlaying){
            main.playbackManager.playbackIsPaused = YES;
            [[SPSession sharedSession]setPlaying:NO];
             
            [self toggleplayandpause:NO];
        }
    }
 /*   else{
        [[SPSession sharedSession]setPlaying:YES];
        main.playbackManager.playbackIsPaused = NO;
        [main.mainViewController.tabController.cueController.tableView reloadData];
        
        [pause.layer removeAllAnimations];
        
    }*/
}


- (void)resetTrackTitleAndArtist{
    
    self.artistLbl.text = @"Artist";
    self.titleLbl.text = @"Title";
    timeRemainingCh1.text = @"";
}

- (void)setTrackTitleAndArtist:(SPTrack *)track{
    NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
    
    self.artistLbl.text = artists;
    self.titleLbl.text = track.name;
    
}

-(void)setDefaultPitchController:(UITapGestureRecognizer *)gestureRecognizer{
    
   NSLog(@"test ch1");
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIView *piece = [gestureRecognizer view];
    
    if (main.mainViewController.landscapeMode){
        piece.frame = CGRectMake(12,224, 63, 63);
    }
    else{
        piece.frame = CGRectMake(60,422, 63, 63);
    }
    
    
    [main.playbackManager setPlaybackCents:0:1];
    
}


-(void)setDefaultPitchControllerCh2:(UITapGestureRecognizer *)gestureRecognizer{
    
    NSLog(@"test ch2");
    UIView *piece = [gestureRecognizer view];
    piece.frame = CGRectMake(46,225, 63, 63);
    
 
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setPlaybackCents:0:2];
}



- (void)setPlayduration:(double)length{
    
    NSTimeInterval interval = length;    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSLog(@"mm:ss %@", formattedDate);
    timeRemainingCh1.text = [NSString stringWithFormat:@"-%@",formattedDate];
    
}

- (void)setPlaydurationCh2:(double)length{
    
    currenttrackCh2Duration = length;
    NSTimeInterval interval = length;    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    NSLog(@"mm:ss %@", formattedDate);
    timeRemainingCh2.text = [NSString stringWithFormat:@"-%@",formattedDate];
    
}

- (void)updatePlayduration:(double)val{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSTimeInterval remainTime = main.playbackManager.currentTrack.duration - val;
    NSTimeInterval interval = remainTime;    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
  //  NSLog(@"mm:ss %@", formattedDate);
    timeRemainingCh1.text = [NSString stringWithFormat:@"-%@",formattedDate];
  //  timeRemainingCh1.text = [NSString stringWithFormat:@"-%f.%f",minutes,seconds];
    
}

- (void)updatePlaydurationCh2:(double)val{
    
    NSTimeInterval remainTime = currenttrackCh2Duration - val;
    NSTimeInterval interval = remainTime;    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"mm:ss"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    //  NSLog(@"mm:ss %@", formattedDate);
    timeRemainingCh2.text = [NSString stringWithFormat:@"-%@",formattedDate];
    //  timeRemainingCh1.text = [NSString stringWithFormat:@"-%f.%f",minutes,seconds];
    
}

- (void)toggleplayandpause:(BOOL)hidden{
    
    if (hidden){
        self.playBtn.hidden = YES;
        self.pauseBtn.hidden = NO;
    }else {
        self.playBtn.hidden = NO;
        self.pauseBtn.hidden = YES;
    }
}



- (void)setmixerModeOn{
    
   // self.view.backgroundColor = [UIColor blackColor];
    self.controlView.center = CGPointMake(250, 470);
    self.artistLbl.center = CGPointMake(250, 215);
    self.titleLbl.center = CGPointMake(250, 275);
     
    timeRemainingCh1.frame = CGRectMake(200, 350, 100, 30);
    timeRemainingCh2.hidden = NO;
    
    self.effectParentViewCh2.hidden = NO;
    self.line.hidden = NO;
    self.addtrack.hidden = NO;
    self.controlViewCh2.hidden = NO;
    self.artistlblCh2.hidden = NO;
    self.titlelblCh2.hidden = NO;
    
    crossfadeBg.hidden = NO;
    crossfadeKnob.hidden = NO;
    
    self.effectParentView.frame = CGRectMake(50, 170, 400, 450);
    NSLog(@"mixer mode done");
    
    bgLogo.frame = CGRectMake(70, 140, 393, 319);
    bgLogoRight.hidden = NO;
}

- (void)setonechannelmodeOn{
    self.controlView.center = CGPointMake(380, 470);
    self.artistLbl.center = CGPointMake(380, 215);
    self.titleLbl.center = CGPointMake(380, 275);
    timeRemainingCh1.frame = CGRectMake(340, 360, 100, 30);
    timeRemainingCh2.hidden = YES;
    
    self.effectParentViewCh2.hidden = YES;
    self.line.hidden = YES;
    self.addtrack.hidden = YES;
    self.controlViewCh2.hidden = YES;
    self.artistlblCh2.hidden = YES;
    self.titlelblCh2.hidden = YES;
    
    crossfadeBg.hidden = YES;
    crossfadeKnob.hidden = YES;
    
    self.effectParentView.frame = CGRectMake(50, 40, 650, 930);
    
    bgLogo.frame = CGRectMake(200, 200, 393, 319);
    bgLogoRight.hidden = YES;
}


//channel 2 functions below

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[mediaPicker dismissModalViewControllerAnimated:YES];
    
    [self freeAudio];
    
    [self initDataVar];
    
    for (int i=0; i<datasize_; ++i){
		data_[i]= 0.0; //zero out contents of buffer
	}	
  
    if (main.playbackManager.graph == NULL){
        NSError *error = nil;
        if (![main.playbackManager setupAudioGraphWithAudioFormat:&error]) {
            
        }  
        //initialise the audio player
    }
    [main.playbackManager connectSecChannelCallback];
    [main.playbackManager connectSecMastermixerBus];
    
    [main.playbackManager toggleChannelTwoPlayingStatus:YES];
    
    pausech2Btn.hidden = NO;
    playch2Btn.hidden = YES;
    
  	for (MPMediaItem* item in mediaItemCollection.items) {
		//NSString *titletest = [item valueForProperty:MPMediaItemPropertyTitle];
		//NSString *artisttest = [item valueForProperty:MPMediaItemPropertyArtist];
        
		glTitle = [item valueForProperty:MPMediaItemPropertyTitle];
		glArtist = [item valueForProperty:MPMediaItemPropertyArtist];
		NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration]; 
		//NSTimeInterval is a double
        self.titlelblCh2.text = glTitle;
        self.artistlblCh2.text = glArtist;
		duration_ = [dur doubleValue]; 
        
        [self setPlaydurationCh2:duration_];
		
		//MPMediaItemPropertyArtist
		glAssetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		if (nil == glAssetURL) {
			/**
			 * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
			 * in question is protected by DRM. (old m4p files)
			 */
            [self freeAudio];
			return;
		}
        NSLog(@"title: %@",glTitle);
               
    	[self exportAssetAtURL:glAssetURL withTitle:glTitle withArtist:glArtist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    
	[mediaPicker dismissModalViewControllerAnimated:YES];
    
    importingflag_=0; 
	
}



- (void)showMediaPicker {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	mediaPickerController* mediaPicker = [[[mediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
    mediaPicker.view.frame = CGRectMake(0, 0, 1024, 768);
   // mediaPicker.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[main.mainViewController presentModalViewController:mediaPicker animated:YES];
    
    
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
                //        [self initDataVar];
                //        [self freeAudio];
                        [main.playbackManager cantRead];
                        
                        [main.playbackManager toggleChannelTwoPlayingStatus:NO];
						//in case user presses restart button! 
						//break;
						
					}
					
				} else {
					
               //     [self initDataVar];
					actuallyfinished=1;
              //      [self freeAudio];
                    [main.playbackManager cantRead];
                   
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
    
	
	//  create here, not fully started yet
    //	audio = [[AudioDeviceManager alloc] init];
    //	[audio retain]; 
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	[main.playbackManager setUpData:data_ pos:&readpos_ size:datasize_]; //allocate buffers
    
    
    //setting up the controls 
    
}

- (void)pauseTrackCh2:(id)sender{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (isPaused){
        isPaused = NO;
        [main.playbackManager canRead];
        pausech2Btn.hidden = NO;
        playch2Btn.hidden = YES;
        
        
    }else{
        isPaused = YES;
        [main.playbackManager cantRead];
        pausech2Btn.hidden = YES;
        playch2Btn.hidden = NO;
    }
    
}

-(void)stopTrackCh2:(id)sender{
    UIButton *stop = (UIButton *)sender;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //update track and artist ui
    self.titlelblCh2.text = @"Title";
    self.artistlblCh2.text = @"Artist";
    timeRemainingCh2.text = @"";
    
    pausech2Btn.hidden = YES;
    playch2Btn.hidden = NO;
    
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
    //[main.playbackManager removeSecMastermixerBus];
    
    [main.playbackManager toggleChannelTwoPlayingStatus:NO];
    
    
}

- (void)freeAudio {
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    memset(data_, 0, datasize_);
    
    [main.playbackManager cantRead];
    [main.playbackManager removeSecChannelCallback];
    
  //  [main.playbackManager closeDownChannelTwo];
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
