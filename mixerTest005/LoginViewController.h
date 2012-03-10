//
//  LoginViewController.h
//  mixerTest003
//
//  Created by Christian Persson on 2011-11-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController {
    
    UITextField *usernameField;
	UITextField *passwordField;
	UIButton *loginButton;
	UIActivityIndicatorView *spinner;
    UISwitch *pass;
    
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UISwitch *pass;


- (IBAction)performLogin:(id)sender;
- (IBAction)removeCredentials:(id)sender;

@end
