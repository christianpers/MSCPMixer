//
//  effectgridView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Shared.h"
#import "effectgridView.h"

@implementation effectgridView

@synthesize param1, param2;
@synthesize param1Lbl, param2Lbl;
@synthesize effectType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGSize size = self.frame.size;
        self.param1Lbl = [[UILabel alloc] initWithFrame:CGRectZero];
        self.param1Lbl.backgroundColor = [UIColor clearColor];
        //     headerLabel.opaque = NO;
        self.param1Lbl.textColor = [UIColor whiteColor];
       // param1.highlightedTextColor = [UIColor whiteColor];
        self.param1Lbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(23.0)];
        self.param1Lbl.frame = CGRectMake(size.width-260, 240, 260, 30.0);
        [self addSubview:self.param1Lbl];
        
        self.param2Lbl = [[UILabel alloc] initWithFrame:CGRectZero];
        self.param2Lbl.backgroundColor = [UIColor clearColor];
        //     headerLabel.opaque = NO;
        self.param2Lbl.textColor = [UIColor whiteColor];
        // param1.highlightedTextColor = [UIColor whiteColor];
        self.param2Lbl.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(23.0)];
        self.param2Lbl.frame = CGRectMake(size.width-260, 280, 260, 30.0);
        [self addSubview:self.param2Lbl];
        
    }
    return self;
}

- (void)updateparamVal{
    
    if ([self.effectType isEqualToString:@"TimePitch"]){
        if ([Shared sharedInstance].curVariSpeedEffect == 0){
            self.param1Lbl.text = [NSString stringWithFormat:@"Playback rate: %.1lf",self.param1];
        }else{
            self.param1Lbl.text = [NSString stringWithFormat:@"Playback cents: %.1lf",self.param1];
        }
      //  self.param2Lbl.text = [NSString stringWithFormat:@"Resonance: %.1lf",self.param2];
    }
    else if ([self.effectType isEqualToString:@"Lopass"]){
        self.param1Lbl.text = [NSString stringWithFormat:@"Cutoff freq: %.1lf",self.param1];
        self.param2Lbl.text = [NSString stringWithFormat:@"Resonance: %.1lf",self.param2];
    }
    else if ([self.effectType isEqualToString:@"Hipass"]){
        self.param1Lbl.text = [NSString stringWithFormat:@"Cutoff freq: %.1lf",self.param1];
        self.param2Lbl.text = [NSString stringWithFormat:@"Resonance: %.1lf",self.param2];
    }
    else if ([self.effectType isEqualToString:@"Reverb"]){
        self.param1Lbl.text = [NSString stringWithFormat:@"Dry/Wet: %.1lf",self.param2];
        self.param2Lbl.text = [NSString stringWithFormat:@"Gain: %.1lf",self.param1];
    }
    else if ([self.effectType isEqualToString:@"Volume"]){
        self.param1Lbl.text = [NSString stringWithFormat:@"Volume: %.1lf",self.param1];
    //    self.param2Lbl.text = [NSString stringWithFormat:@"Gain: %.1lf",self.param2];
    }
       
   
    
    
    
}

- (void)drawRect:(CGRect)rect
{
    
    [self updateparamVal];
    int x = [Shared sharedInstance].effectgridX;
    int y = [Shared sharedInstance].effectgridY;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 4.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {1, 1, 1.0, 1.0};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    if (x > 0){
        CGContextMoveToPoint(context, x, 0);
        CGContextAddLineToPoint(context, x,self.frame.size.height);
        
        CGContextStrokePath(context);
        
    }
    if (y > 0){
        CGContextMoveToPoint(context, 0, y);
        CGContextAddLineToPoint(context, self.frame.size.width,y);
        
        CGContextStrokePath(context);
        
    }
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

- (void)dealloc{
    [param1Lbl release];
    [param2Lbl release];
    
}


@end
