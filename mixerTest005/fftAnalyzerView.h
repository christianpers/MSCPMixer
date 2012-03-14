//
//  fftAnalyzerView.h
//  mixerTest005
//
//  Created by Christian on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <AudioToolbox/AudioToolbox.h>

@interface fftAnalyzerView : UIView{
    
    float *fftBuffer;
    int num_bars;
    int bin_size;
}

- (void)updateFFT :(float **)buffer :(int)frequencyBin;


@end
