//
//  searchViewController.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "searchViewController.h"
#import "AppDelegate.h"

@implementation searchViewController

@synthesize search;
@synthesize searchField;

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
    UIView *test = [[UIView alloc]initWithFrame:CGRectMake(0, 400, 700, 300)];
    self.view = test;
   
    
    self.view.backgroundColor = [UIColor blackColor];
     
    self.searchField = [[UITextField alloc]initWithFrame:CGRectMake(130, 400, 300, 60)];
    self.searchField.borderStyle = UITextBorderStyleRoundedRect;
    self.searchField.textColor = [UIColor blackColor]; //text color
    self.searchField.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(39.0)];
    self.searchField.placeholder = @"search for music";  //place holder
    self.searchField.backgroundColor = [UIColor whiteColor]; //background color
    self.searchField.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:self.searchField];
    [searchField release];
  
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(480, 400, 150, 58);// position in the parent view and set the size of the
    //searchBtn.layer.backgroundColor = [[UIColor whiteColor]CGColor];
    [searchBtn setTitle:[NSString stringWithFormat:@"Search"] forState:UIControlStateNormal];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(39.0)];
    [searchBtn addTarget:self 
                  action:@selector(searchClicked:)
        forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:searchBtn];
    
    [self addObserver:self forKeyPath:@"search.tracks" options:0 context:nil];

    [super viewDidLoad];
                   
}

- (void)searchClicked:(UIButton *)btn{
    NSLog(@"clicked");
    
    [self.view endEditing:YES];
    
    if (![self.search searchInProgress]){
        
        if ([self.searchField.text length] > 0) {
            self.search = [SPSearch searchWithSearchQuery:self.searchField.text inSession:[SPSession sharedSession]];
            
            }
    }    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"search.tracks"]) {
        SPSearch *searchCallback = self.search;
        BOOL noResult = YES;
        if([searchCallback.tracks count] > 0){
            
            [self createSearchList:searchCallback];
            noResult = NO;
            
        }
        else if([searchCallback.albums count] > 0){
            
            [self createSearchList:searchCallback];
            noResult = NO;
            
        }
        else if([searchCallback.artists count] > 0){
            
            [self createSearchList:searchCallback];
            noResult = NO;
            
        }
        
      
    }
}
-(void)createSearchList:(SPSearch *)returnObj{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    main.playbackLabel.hidden = YES;
    main.playlistLabel.hidden = YES;
    main.searchLabel.hidden = YES;
    main.cueView.hidden = YES;
    
    NSMutableArray *albumarr;
    NSMutableArray *trackarr;
    NSMutableArray *artistsarr;
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    if (returnObj.albums > 0){
         albumarr = [[NSMutableArray alloc]initWithArray:returnObj.albums];
        [arr addObject:albumarr];
    }
    if (returnObj.tracks > 0){
        trackarr = [[NSMutableArray alloc]initWithArray:returnObj.tracks];
        [arr addObject:trackarr];
    }
    if (returnObj.artists > 0){
        artistsarr = [[NSMutableArray alloc]initWithArray:returnObj.artists];
        [arr addObject:artistsarr];
    }
    
    searchTableViewController *rootSearchView = [[searchTableViewController alloc]init];
    
    rootSearchView.detailArr = arr;
    rootSearchView.tableView.backgroundColor = [UIColor blackColor];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:rootSearchView];
    
   // navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:nil];
  
    [rootSearchView release];
    [navController release];
}




/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)dealloc{
    
    [self.searchField release];
    [self.search release];
    [self removeObserver:self forKeyPath:@"search.tracks"];
}

@end
