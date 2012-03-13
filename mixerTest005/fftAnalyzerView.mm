//
//  fftAnalyzerView.m
//  mixerTest005
//
//  Created by Christian on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "fftAnalyzerView.h"
#import "AppDelegate.h"

@implementation fftAnalyzerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
    }
    return self;
}

-(void)updateFFT:(float *)buffer{
    
  //NSLog(@"update fft");
   // memcpy(fftBuffer, buffer, buffer)
    fftBuffer = buffer;
    [self setNeedsDisplay];
    
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect rectangle = CGRectMake(0, 0, 10, 50);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(context, rectangle);
}


@end
