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
#import "playbackView.h"
#import <QuartzCore/QuartzCore.h>

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
        self.layer.cornerRadius = 5;
        
    }
    return self;
}

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *piece = [gestureRecognizer view];
    UIView *parentView = [piece superview];
    parentSize = parentView.frame.size;
    
    CGPoint pos = piece.frame.origin;
    CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
    
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan){
        
        [self.gridView removeFromSuperview];
        [self drawEffectGrid:piece.tag];
        main.playbackLabel.hidden = YES;
        main.playlistLabel.hidden = YES;
        main.searchLabel.hidden = YES;
        main.cueController.view.hidden = YES;
        parentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.16];
       // parentView.layer.borderWidth = 4.0f;
        
        if (pos.x <= 0) {
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        }else if (pos.x >= parentView.bounds.size.width-43){
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        }else if (pos.y <= 0) {
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        }else if (pos.y >= parentView.bounds.size.height-43){
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        }
        
        
        if (piece.tag <= 5){
           // [[(playbackView *)[self superview] controlView] setHidden:YES];
           // [[(playbackView *)[self superview] artistLbl] setHidden:YES];
           // [[(playbackView *)[self superview] titleLbl] setHidden:YES];
            
            
        }
        else{
           // [[(secondChannelView *)[self superview] controlView] setHidden:YES];
            
        }
             
     }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        
        
        
        if((pos.x >= 0 && pos.x <= (parentView.bounds.size.width-43))&&(pos.y >= 0 && pos.y <= (parentView.bounds.size.height-43))){
            [self.gridView setNeedsDisplay];
            self.gridView.param1 = paramVal1;
            self.gridView.param2 = paramVal2;
            
            if (piece.tag <= 5){
                piece.backgroundColor = [UIColor whiteColor];
            }
            else{
                piece.backgroundColor = [UIColor blackColor];
                
            }
            
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
           // setY = [piece center].y + translation.y;
            setY = pos.y;
            setX = [piece center].x + translation.x;
            if(setY < parentSize.height/2){
                aboveMiddleY = YES;
            }
            else{
                aboveMiddleY = NO;
            }

        }
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded){
        if (piece.tag <= 5){
            piece.backgroundColor = [UIColor clearColor];
          //  [[(playbackView *)[self superview] artistLbl] setHidden:NO];
          //  [[(playbackView *)[self superview] titleLbl] setHidden:NO];
          //  [[(playbackView *)[self superview] controlView] setHidden:NO];
            
            
        }
        else{
            piece.backgroundColor = [UIColor clearColor];
            
        }
        [self.gridView removeFromSuperview];
        self.gridView = nil;
        
        main.playbackLabel.hidden = NO;
        main.playlistLabel.hidden = NO;
        main.searchLabel.hidden = NO;
        main.cueController.view.hidden = NO;
        parentView.backgroundColor = [UIColor clearColor];
     //   parentView.layer.borderWidth = 0.0f;
        
        
    }
    
    if ([main.playbackManager isaugraphRunning]){
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
                [self masterVolCh1];
                break;    
            case 6:
                [self lopassUnitChTwo];
                break;   
            case 7:
                [self masterVolCh2];
                break; 
            case 8:
                [self hipassUnitChTwo];
                break;
            case 9:
                [self variSpeedUnitChTwo];
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
        [main.playbackManager setPlaybackRate:paramVal1:1];
        
    }
    else{
        
        if (aboveMiddleY){
            paramVal1 = (((parentSize.height/2)-setY)/(parentSize.height/2))*2400;
        }else{
            paramVal1 = ((setY - (parentSize.height/2))/-(parentSize.height/2))*2400;
        }
        NSLog(@"param cents: %f",paramVal1);
        
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.playbackManager setPlaybackCents:paramVal1:1];
    }
    
}
- (void)variSpeedUnitChTwo{
    if ([Shared sharedInstance].curVariSpeedEffect == 0){
        paramVal1 = (setY/parentSize.height)*4;
        NSLog(@"param rate: %f",paramVal1);
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.playbackManager setPlaybackRate:paramVal1:2];
        
    }
    else{
        
        if (aboveMiddleY){
            paramVal1 = (((parentSize.height/2)-setY)/(parentSize.height/2))*2400;
        }else{
            paramVal1 = ((setY - (parentSize.height/2))/-(parentSize.height/2))*2400;
        }
        NSLog(@"param cents: %f",paramVal1);
        
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [main.playbackManager setPlaybackCents:paramVal1:2];
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
    paramVal1 = (setY/parentSize.height)*7000;
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
    [main.playbackManager sethipassEffectY:paramVal1:1];
    [main.playbackManager sethipassEffectX:paramVal2:1];
}

- (void)hipassUnitChTwo{
    paramVal1 = (setY/parentSize.height)*7000;
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
    [main.playbackManager sethipassEffectY:paramVal1:2];
    [main.playbackManager sethipassEffectX:paramVal2:2];
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

- (void)masterVolCh1{
    paramVal1 = (setY/parentSize.height);
    paramVal1 = 1 - paramVal1;
    NSLog(@"vol:%f",paramVal1);
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setMasterVolCh1:paramVal1];
    
}

- (void)masterVolCh2{
    paramVal1 = (setY/parentSize.height);
    paramVal1 = 1 - paramVal1;
    NSLog(@"vol:%f",paramVal1);
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.playbackManager setMasterVolCh2:paramVal1];
    
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
                y = (window.height/2)+21;
                
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
        case 7:
            /*
             default val cutoff freq 6900
             default val resonance 0.0
             */
            x = 0;
            y = 0;
            self.gridView.effectType = @"Volume";
            break;
        case 8:
            /*
             default val cutoff freq 6900
             default val resonance 0.0
             */
            x = 260;
            y = 330;
            self.gridView.effectType = @"Hipass";
            break;
        case 9:
            /*
             default val playbackrate 1.0
             default val playbackcents 0.0
             */
            if ([Shared sharedInstance].curVariSpeedEffect == 1){
                x = 0;
                y = (window.height/2)+21;
                
            }
            else{
                
                x = 0;
                y = 246;
            }
            self.gridView.effectType = @"TimePitch";
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
