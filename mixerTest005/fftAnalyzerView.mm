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
        num_bars = 0;
        
    }
    return self;
}

-(void)updateFFT:(float **)buffer :(int)frequencyBin{
    
    num_bars = 30;
    
    bin_size = floor(frequencyBin/num_bars);
    
    fftBuffer = *buffer;
   // fftBuffer = buffer;
    
    [self setNeedsDisplay];
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGSize fftViewSize = self.frame.size;
    for (int i = 0;i<num_bars;i++){
        float sum = 0;
        for (int j = 0;j<bin_size;j++){
            sum += fftBuffer[i*bin_size*j];
            
            float average = sum/bin_size;
            float bar_width = fftViewSize.width / num_bars;
            float scaled_average = (average / 256) * fftViewSize.height;
            
            CGRect rectangle = CGRectMake(i*bar_width, fftViewSize.height, bar_width - 2, -scaled_average);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
            CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
            CGContextFillRect(context, rectangle);
            
        }
        
    }
    
}


@end
