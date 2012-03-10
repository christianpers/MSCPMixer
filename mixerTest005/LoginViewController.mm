//
//  LoginViewController.m
//  mixerTest003
//
//  Created by Christian Persson on 2011-11-07.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "CocoaLibSpotify.h"
#import "Shared.h"

@implementation LoginViewController
@synthesize usernameField;
@synthesize passwordField;
@synthesize loginButton;
@synthesize spinner;
@synthesize pass;


-(id)init {
	 return [self initWithNibName:@"LoginViewController_iPad" bundle:nil];
}
 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
       
        
    }
    return self;
}

- (IBAction)performLogin:(id)sender {
    
  	if (self.usernameField.text.length == 0 || self.passwordField.text.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
														message:@"Please enter your username and password"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[[alert autorelease] show];
        
		return;
	}
    
	[[NSUserDefaults standardUserDefaults] setValue:usernameField.text forKey:@"username"];
    
    
    BOOL remCredentials = self.pass.on;
    
    NSLog(@"%d",remCredentials);
	
	[[SPSession sharedSession] attemptLoginWithUserName:self.usernameField.text
											   password:self.passwordField.text
									rememberCredentials:remCredentials];
	
	self.usernameField.enabled = NO;
	self.passwordField.enabled = NO;
	self.loginButton.enabled = NO;
	self.spinner.hidden = NO;
	
}

- (IBAction)removeCredentials:(id)sender{
    
    SPSession *sess = [SPSession sharedSession];
    
    NSString *storedUser = [sess storedCredentialsUserName];
    NSLog(@"user stored: %@",storedUser);
    [[SPSession sharedSession] forgetStoredCredentials];
    self.usernameField.text = @"";
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
    
	// Invoked by SPSession after a failed login.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[[alert autorelease] show];
	
	self.usernameField.enabled = YES;
	self.passwordField.enabled = YES;
	self.loginButton.enabled = YES;
	self.spinner.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSError *error = nil;
    
  	self.usernameField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
   // self.pass.on = NO;
    if (self.pass.on && ![Shared sharedInstance].hasLoggedin && ![Shared sharedInstance].relogin){
       
       [[SPSession sharedSession] attemptLoginWithStoredCredentials:(NSError **)error];
       // NSLog(@"%@",tryLogin);
    }else{
        
        [Shared sharedInstance].hasLoggedin = false;
    }
    
    
}

- (void)viewDidUnload
{
    [self setUsernameField:nil];
	[self setPasswordField:nil];
	[self setLoginButton:nil];
	[self setSpinner:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[usernameField release];
	[passwordField release];
	[loginButton release];
	[spinner release];
    [pass release];
	[super dealloc];
}

@end
