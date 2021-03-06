//
//  searchViewController.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "searchViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>


@implementation searchViewController

@synthesize searchField;
@synthesize model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    
    CGRect searchrect = CGRectMake(0, 0, winSize.width, winSize.height);
    self.view = [[UIView alloc] initWithFrame:searchrect];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    appStarted = NO;
   
                      
}

- (void)searchClicked:(UIButton *)btn{
    [model addObserver:self forKeyPath:@"arrayUpdated" options:NSKeyValueObservingOptionNew context:nil];
    
    NSLog(@"clicked");
    
    searchCount = 0;
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [btn.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    [self.view endEditing:YES];
    
    if ([self.searchField.text length] > 0) {
        //  self.search = [SPSearch searchWithSearchQuery:self.searchField.text inSession:[SPSession sharedSession]];
      //  if (![model searchInProgress]){
            [model setSearchString:self.searchField.text];
            SEL func = @selector(startNewSearch);
            [model doSearchOnNewThread:func];
     //   }
    }
       
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"arrayUpdated"]) {
        
        NSLog(@"testing");
        NSLog(@"arr length %d",[[model resultArray] count]);
        [self initTableView:model.resultArray];
    }
}

- (void)showNoResult{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                    message:nil
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [[alert autorelease] show];

    
}

- (void)initTableView:(NSMutableArray *)returnArr{
    [model removeObserver:self forKeyPath:@"arrayUpdated"];
    searchTableViewController *rootSearchView = [[searchTableViewController alloc]init];
    
    rootSearchView.detailArr = returnArr;
    rootSearchView.tableView.backgroundColor = [UIColor blackColor];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:rootSearchView];
    
    // navController.modalPresentationStyle = UIModalPresentationFormSheet;
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main.mainViewController presentViewController:navController animated:YES completion:nil];
    
    [rootSearchView release];
    [navController release];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    model = [[searchmodel alloc]init]; 
    
    NSString* mscpImgStr = [[NSBundle mainBundle] pathForResource:@"msco based" ofType:@"png"];
    UIImage *mscpImage = [UIImage imageWithContentsOfFile:mscpImgStr];
    
    searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mscpImg = [[UIImageView alloc]initWithImage:mscpImage];
    
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(130, 400, 340, 50)];
    searchBtn.frame = CGRectMake(490, 400, 120, 50);// position in the parent view and set the size of the
    mscpImg.frame = CGRectMake(40, 600, 342, 346);
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //  self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.textColor = [UIColor blackColor]; //text color
    self.searchField.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(30.0)];
    self.searchField.placeholder = @"Do some crate diggin..";  //place holder
    self.searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchField.backgroundColor = [UIColor whiteColor]; //background color
    self.searchField.textAlignment = UITextAlignmentCenter;
 //   self.searchField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.searchField];
    [searchField release];
    
    //searchBtn.layer.backgroundColor = [[UIColor whiteColor]CGColor];
    [searchBtn setTitle:[NSString stringWithFormat:@"Search"] forState:UIControlStateNormal];
    searchBtn.backgroundColor = [UIColor redColor];
    searchBtn.layer.cornerRadius = 1;
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(30.0)];
    [searchBtn addTarget:self 
                  action:@selector(searchClicked:)
        forControlEvents:UIControlEventTouchDown];
 //   searchBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:searchBtn];
    
   // [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];
   // [self addObserver:self forKeyPath:@"search.searchInProgress" options:0 context:nil];
    
    //  [super viewDidLoad];
    
 //   mscpImg.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:mscpImg];
    [mscpImg release];


}

- (void)setlandscapemode{
    NSLog(@"landscape ffs !!");
    
    self.searchField.frame = CGRectMake(300, 230, 340, 50);
    searchBtn.frame = CGRectMake(660, 230, 120, 50);// position in the parent view and set the size of the
    mscpImg.frame = CGRectMake(40, 400, 342, 346);
    
    
    
}
- (void)setportraitmode{
    self.searchField.frame = CGRectMake(130, 400, 340, 50);
    searchBtn.frame = CGRectMake(490, 400, 120, 50);// position in the parent view and set the size of the
    mscpImg.frame = CGRectMake(40, 600, 342, 346);
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    
//  if (!appStarted){
//        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
            
//            [self setlandscapemode];
//        }
//        appStarted = YES;
//    }
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (main.mainViewController.landscapeMode){
        [self setlandscapemode];
        
    }
    
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.searchField removeFromSuperview];
    [searchBtn removeFromSuperview];
    [mscpImg removeFromSuperview];
    [model release];
   
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
       
        
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
       
        
    }
    
}



-(void)dealloc{
    
    [self.searchField release];
    [model release];
 //   [self removeObserver:self forKeyPath:@"search.tracks"];
    
   
    [super dealloc];
}

@end
