//
//  tabbarController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cueViewController.h"

@interface tabbarController : UITabBarController{
    
    UIButton *playlistBtn;
    UIButton *playbackBtn;
    UIButton *searchBtn;
    UIView  *menuBg;
    UIImageView *activeImg;
    cueViewController *cueController;
}

@property (nonatomic, retain) cueViewController *cueController;

-(void) hideTabBar;
-(void) addCustomElements;
-(void) selectTab:(int)tabID;

@end
