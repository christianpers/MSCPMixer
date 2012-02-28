//
//  secondChannelUIViewController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface secondChannelUIViewController : UIViewController <MPMediaPickerControllerDelegate> {
    
    
}

- (void)showMediaPicker;
- (void)createChannelTwoUI;
- (void)removeChannelTwoUI;

@end
