//
//  effectController.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "effectController.h"
#import "Shared.h"
#import "AppDelegate.h"

@implementation effectController

@synthesize gridView;

BOOL aboveMiddleY = NO;
AudioUnitParameterValue paramVal1;
AudioUnitParameterValue paramVal2;
float setY;
float setX;
CGSize parentSize;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIPanGestureRecognizer *effectSwipe = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPiece:)];
        [self addGestureRecognizer:effectSwipe]; 
        [effectSwipe release];
    }
    return self;
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    UIView *parentView = [piece superview];
    parentSize = parentView.frame.size;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        
        [self drawEffectGrid:piece.tag];
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        main.playbackLabel.hidden = YES;
        main.playlistLabel.hidden = YES;
        main.searchLabel.hidden = YES;
        main.cueView.hidden = YES;
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        [self.gridView setNeedsDisplay];
        self.gridView.param1 = paramVal1;
        self.gridView.param2 = paramVal2;
        
        piece.backgroundColor = [UIColor purpleColor];
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        setY = [piece center].y+translation.y;
        setX = [piece center].x + translation.x;
        if(setY < parentSize.height/2){
            aboveMiddleY = YES;
        }
        else{
            aboveMiddleY = NO;
        }
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        piece.backgroundColor = [UIColor whiteColor];
        [self.gridView removeFromSuperview];
        self.gridView = nil;
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        main.playbackLabel.hidden = NO;
        main.playlistLabel.hidden = NO;
        main.searchLabel.hidden = NO;
        main.cueView.hidden = NO;
    }
    
    if ([SPSession sharedSession].playing){
        switch (piece.tag) {
            case 1:
                [self variSpeedUnit];
                break;
            case 2:
                [self lopassUnit];
                break;
            case 3:
                [self hipassUnit];
                break;
            case 4:
                [self reverbUnit];
                break;
            case 5:
                [self masterVol];
                break;    
            case 6:
                [self lopassUnitChTwo];
                break;   
            default:
                break;
        }
    }
   
}

- (void)variSpeedUnit{
    if ([Shared sharedInstance].curVariSpeedEffect == 0){
        paramVal1 = (setY/parentSize.height)*4;
        NSLog(@"param rate: %f",paramVal1);
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.playbackManager setPlaybackRate:paramVal1];
        
    }
    else{
        
        if (aboveMiddleY){
            paramVal1 = (((parentSize.height/2)-setY)/(parentSize.height/2))*2400;
        }else{
            paramVal1 = ((setY - (parentSize.height/2))/-(parentSize.height/2))*2400;
        }
        NSLog(@"param cents: %f",paramVal1);
        
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.playbackManager setPlaybackCents:paramVal1];
    }
    
}
- (void)lopassUnit{
    paramVal1 = (setY/parentSize.height)*22000;
    float twoThirds = (parentSize.width/3)*2;
    if (setX < (parentSize.width/3)){
        paramVal2 = (((parentSize.width/3)-setX)/-(parentSize.width/3))*20;
        NSLog(@"positive side");
    }
    else{
        paramVal2 = (((setX*2)-(twoThirds))/(twoThirds))*20;
        NSLog(@"negative side");
    }
    NSLog(@"freq: %f, resonance: %f",paramVal1, paramVal2);
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setlopassEffectY:paramVal1:1];
    [main.playbackManager setlopassEffectX:paramVal2:1];
    
}

- (void)hipassUnit{
    paramVal1 = (setY/parentSize.height)*22000;
    float twoThirds = (parentSize.width/3)*2;
    if (setX < (parentSize.width/3)){
        paramVal2 = (((parentSize.width/3)-setX)/-(parentSize.width/3))*20;
        NSLog(@"positive side");
    }
    else{
        paramVal2 = (((setX*2)-(twoThirds))/(twoThirds))*20;
        NSLog(@"negative side");
    }
    NSLog(@"paramval2:%f",paramVal2);
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager sethipassEffectY:paramVal1];
    [main.playbackManager sethipassEffectX:paramVal2];
}

- (void)reverbUnit{
    if (aboveMiddleY){
        paramVal1 = (((parentSize.height/2)-setY)/(parentSize.height/2))*20;
    }else{
        paramVal1 = ((setY - (parentSize.height/2))/-(parentSize.height/2))*20;
    }
    
    paramVal2 = (setX/parentSize.width)*100;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setReverbX:paramVal1];
    
    NSLog(@"param1: %f, param2: %f",paramVal1, paramVal2);
    
}

- (void)masterVol{
    paramVal1 = (setY/parentSize.height);
    paramVal1 = 1 - paramVal1;
    NSLog(@"vol:%f",paramVal1);
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setMasterVol:paramVal1];
    
}
- (void)lopassUnitChTwo{
    paramVal1 = (setY/parentSize.height)*22000;
    float twoThirds = (parentSize.width/3)*2;
    if (setX < (parentSize.width/3)){
        paramVal2 = (((parentSize.width/3)-setX)/-(parentSize.width/3))*20;
        NSLog(@"positive side");
    }
    else{
        paramVal2 = (((setX*2)-(twoThirds))/(twoThirds))*20;
        NSLog(@"negative side");
    }
    NSLog(@"freq: %f, resonance: %f",paramVal1, paramVal2);
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setlopassEffectY:paramVal1:2];
    [main.playbackManager setlopassEffectX:paramVal2:2];
    
}


- (void)drawEffectGrid:(int)tag{
    
    int x = 0;
    int y = 0;
    UIView *parentView = [self superview];
    CGSize window = parentView.frame.size;
    
    self.gridView = [[effectgridView alloc]initWithFrame:CGRectMake(0, 0, window.width, window.height)];
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.param1 = paramVal1;
    self.gridView.param2 = paramVal2;
    NSLog(@"paramval1: %f, paramval2: %f",paramVal1, paramVal2);
    [parentView addSubview:self.gridView];
    
    
    switch (tag) {
        case 1:
            /*
             default val playbackrate 1.0
             default val playbackcents 0.0
             */
            if ([Shared sharedInstance].curVariSpeedEffect == 1){
                x = 0;
                y = window.height/2;
                
            }
            else{
                
                x = 0;
                y = 246;
            }
            self.gridView.effectType = @"TimePitch";
            break;
        case 2:
            /*
             default val cutoff freq 6900
             default val resonance 0.0
             */
            x = 260;
            y = 330;
            self.gridView.effectType = @"Lopass";
            break;
        case 3:
            /*
             default val cutoff freq 6900
             default val resonance 0.0
             */
            x = 260;
            y = 330;
            self.gridView.effectType = @"Hipass";
            break;
        case 4:
            /*
             default val drywet 100
             default val gain 0.0
             */
            x = 760;
            y = 510;
            self.gridView.effectType = @"Reverb";
            break;
        case 5:
            x = 0;
            y = 0;
            self.gridView.effectType = @"Volume";
            break;
        case 6:
            /*
             default val cutoff freq 6900
             default val resonance 0.0
             */
            x = 260;
            y = 330;
            self.gridView.effectType = @"Lopass";
            break;
        default:
            break;
    }
    
    [Shared sharedInstance].effectgridX = x;
    [Shared sharedInstance].effectgridY = y;
    
    [self.gridView setNeedsDisplay];
    
    
}

- (void)dealloc{
    
    [gridView release];
}


@end
