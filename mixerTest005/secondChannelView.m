//
//  secondChannelView.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "secondChannelView.h"
#import "AppDelegate.h"

@implementation secondChannelView


@synthesize controlView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)createChannelTwoUI{
    
    
    UIButton *addtrack = [UIButton buttonWithType:UIButtonTypeCustom];
    addtrack.frame = CGRectMake(50, self.bounds.size.height-100, 200, 40);// position in the parent view and set the size of the
    addtrack.backgroundColor = [UIColor blackColor];
    [addtrack setTitle:[NSString stringWithFormat:@"ADD TRACK"] forState:UIControlStateNormal];
    [addtrack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addtrack addTarget:self 
                 action:@selector(showMediaPicker)
       forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:addtrack];
    
    effectController *lopassChTwoController = [[effectController alloc]initWithFrame:CGRectMake(300, 30, 40, 40)];
    lopassChTwoController.backgroundColor = [UIColor clearColor];
    [self addSubview:lopassChTwoController];
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
    
       
    
    //setting up the controls 
    
    UIView *cView = [[UIView alloc]initWithFrame:CGRectMake(190, 140, 400, 50)];
    cView.backgroundColor = [UIColor clearColor];
    self.controlView = cView;
    [self addSubview:self.controlView];    
    
    [cView release];
    
    NSString* imagePathNext = [[NSBundle mainBundle] pathForResource:@"nextCh2" ofType:@"png"];
    NSString* imagePathPrev = [[NSBundle mainBundle] pathForResource:@"prevCh2" ofType:@"png"];
    NSString* imagePathStop = [[NSBundle mainBundle] pathForResource:@"stopCh2" ofType:@"png"];
    NSString* imagePathPause = [[NSBundle mainBundle] pathForResource:@"pauseCh2" ofType:@"png"];
    NSString* imagePathPlay = [[NSBundle mainBundle] pathForResource:@"playCh2" ofType:@"png"];
    
    UIImage *nextImg = [UIImage imageWithContentsOfFile:imagePathNext];
    UIImage *prevImg = [UIImage imageWithContentsOfFile:imagePathPrev];
    UIImage *stopImg = [UIImage imageWithContentsOfFile:imagePathStop];
    UIImage *pauseImg = [UIImage imageWithContentsOfFile:imagePathPause];
    UIImage *playImg = [UIImage imageWithContentsOfFile:imagePathPlay];
    
    UIButton *playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 3, 43, 43)];
    [playBtn setBackgroundImage:playImg forState:UIControlStateNormal];
    [self.controlView addSubview:playBtn];
    [playBtn addTarget:self 
                action:@selector(playTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [playBtn release];
    
    UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 3, 43, 43)];
    [stopBtn setBackgroundImage:stopImg forState:UIControlStateNormal];
    [self.controlView addSubview:stopBtn];
    [stopBtn addTarget:self 
                action:@selector(stopTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [stopBtn release];
    
    UIButton *pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(160, 3, 43, 43)];
    [pauseBtn setBackgroundImage:pauseImg forState:UIControlStateNormal];
    [self.controlView addSubview:pauseBtn];
    [pauseBtn addTarget:self 
                 action:@selector(pauseTrack:)
       forControlEvents:UIControlEventTouchDown];
    
    [pauseBtn release];
    
    UIButton *prevBtn = [[UIButton alloc]initWithFrame:CGRectMake(240, 3, 43, 43)];
    [prevBtn setBackgroundImage:prevImg forState:UIControlStateNormal];
    [self.controlView addSubview:prevBtn];
    [prevBtn addTarget:self 
                action:@selector(playprevTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [prevBtn release];
    
    UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(320, 3, 43, 43)];
    [nextBtn setBackgroundImage:nextImg forState:UIControlStateNormal];
    [self.controlView addSubview:nextBtn];
    [nextBtn addTarget:self 
                action:@selector(playnextTrack:)
      forControlEvents:UIControlEventTouchDown];
    
    [nextBtn release];
    
}

- (void)removeChannelTwoUI{
    
    for (UIView *view in self.subviews){
        if (view.tag != 10){
            [view removeFromSuperview];
            
        }
        
    }
}






@end
