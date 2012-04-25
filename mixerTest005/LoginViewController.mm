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

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

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
        UILabel *hello = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-(150/2), 70, 150, 30)];
        hello.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(39.0)];
        hello.textColor = [UIColor whiteColor];
        hello.textAlignment = UITextAlignmentCenter;
        hello.backgroundColor = [UIColor clearColor];
        hello.text = @"Hello!";
        [self.view addSubview:hello];
        [hello release];
        
        UILabel *spotify = [[UILabel alloc] initWithFrame:CGRectMake(120, 175, 600, 30)];
        spotify.font = [UIFont fontWithName:@"GothamHTF-Book" size:(26.0)];
        spotify.textColor = [UIColor whiteColor];
        spotify.backgroundColor = [UIColor clearColor];
        spotify.text = @"Login with your Spotify premium account";
        [self.view addSubview:spotify];
        [spotify release];
        
        UILabel *remember = [[UILabel alloc] initWithFrame:CGRectMake(118, 410, 200, 23)];
        remember.font = [UIFont fontWithName:@"GothamHTF-Book" size:(22.0)];
        remember.textColor = [UIColor whiteColor];
        remember.text = @"Remember me?";
        remember.backgroundColor = [UIColor clearColor];
        [self.view addSubview:remember];
        [remember release];
        
        
        UILabel *mscpText = [[UILabel alloc] initWithFrame:CGRectMake(610, 140, 260, 40)];
        mscpText.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(22.0)];
        mscpText.textColor = [UIColor whiteColor];
        mscpText.text = @"MSCP Industries 2012";
        mscpText.backgroundColor = [UIColor clearColor];
        [self.view addSubview:mscpText];
        mscpText.transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
        [mscpText release];
        
        UIButton *login = [[UIButton alloc]initWithFrame:CGRectMake(574, 410, 100, 40)];
        login.backgroundColor = [UIColor redColor];
        [login setTitle:[NSString stringWithFormat:@"Login"] forState:UIControlStateNormal];
        [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        login.titleLabel.textAlignment = UITextAlignmentCenter;
        login.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(24.0)];
        [login addTarget:self 
                 action:@selector(performLogin:)
       forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:login];
        
        [login release];
        
        UIButton *clearCredentials = [[UIButton alloc]initWithFrame:CGRectMake(650, 870, 170, 35)];
        clearCredentials.backgroundColor = [UIColor redColor];
        [clearCredentials setTitle:[NSString stringWithFormat:@"clear saved credentials"] forState:UIControlStateNormal];
        [clearCredentials setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        clearCredentials.titleLabel.textAlignment = UITextAlignmentCenter;
        clearCredentials.titleLabel.font =  [UIFont fontWithName:@"GothamHTF-Medium" size:(14.0)];
        [clearCredentials addTarget:self 
                  action:@selector(removeCredentials:)
        forControlEvents:UIControlEventTouchDown];
        clearCredentials.transform = CGAffineTransformMakeRotation(DegreesToRadians(270));
        [self.view addSubview:clearCredentials];
        [clearCredentials release];
        
        self.usernameField = [[UITextField alloc]initWithFrame:CGRectMake(118, 220, 556, 46)];
        self.usernameField.font = [UIFont fontWithName:@"GothamHTF-Book" size:(28.0)];
        self.usernameField.textColor = [UIColor blackColor];
        self.usernameField.text = @"Username";
        self.usernameField.backgroundColor = [UIColor whiteColor];
        self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.view addSubview:self.usernameField];
        
        self.passwordField = [[UITextField alloc]initWithFrame:CGRectMake(118, 340, 556, 46)];
        self.passwordField.font = [UIFont fontWithName:@"GothamHTF-Book" size:(28.0)];
        self.passwordField.textColor = [UIColor blackColor];
        self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.passwordField.secureTextEntry = YES;
        self.passwordField.text = @"Password";
        self.passwordField.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.passwordField];
        
        
        
      //  self.loginText.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
      //  self.loginButton.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(26.0)];
        
      //  self.mscpText.frame = CGRectMake(self.view.frame.size.width-40, 200, 40, 180);
        
        
       
        
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
    self.passwordField.text = @"";
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
    
    self.spinner.hidden = YES;
    
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
