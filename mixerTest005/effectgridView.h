//
//  effectgridView.h
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-05.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface effectgridView : UIView{
    
    float param1, param2;
    UILabel *param1Lbl;
    UILabel *param2Lbl;
    NSString *effectType;
}

@property (assign) float param1;
@property (assign) float param2;
@property (nonatomic, retain) UILabel *param1Lbl;
@property (nonatomic, retain) UILabel *param2Lbl;
@property (nonatomic, retain) NSString *effectType;


- (void)updateparamVal;
@end
