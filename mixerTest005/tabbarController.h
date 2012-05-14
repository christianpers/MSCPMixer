//
//  tabbarController.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-04-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cueViewController.h"
#import "logoutViewController.h"

@interface tabbarController : UITabBarController <UITabBarControllerDelegate>{
    
    UIButton *playlistBtn;
    UIButton *playbackBtn;
    UIButton *searchBtn;
    UIView  *menuBg;
    UIImageView *activeImg;
    cueViewController *cueController;
    BOOL appStarted;
    UIView *airplayIcon;
    UIButton *userTxtBtn;
    logoutViewController *logoutVController;
    
}

@property (nonatomic, retain) cueViewController *cueController;
@property (nonatomic, retain) UIView *menuBg;

-(void) hideTabBar;
-(void) addCustomElements;
-(void) selectTab:(int)tabID;
-(void)removeLogoutView;

@end
