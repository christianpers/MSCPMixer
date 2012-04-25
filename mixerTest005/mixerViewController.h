//
//  mixerViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "effectController.h"
#import "CocoaLibSpotify.h"


@interface mixerViewController : UIViewController{
    
    effectController *timepitchController;
    effectController *lopassController;
    effectController *hipassController;
    effectController *channelOneVolController;
    
}

@property(nonatomic, retain) effectController *timepitchController;
@property(nonatomic, retain) effectController *lopassController;
@property(nonatomic, retain) effectController *hipassController;
@property(nonatomic, retain) effectController *channelOneVolController;

@end
