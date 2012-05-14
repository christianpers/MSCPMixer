//
//  playlistViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "playlistViewController.h"
#import "Shared.h"
#import "plTableView.h"
#import "AppDelegate.h"

@implementation playlistViewController

@synthesize plMainView;
@synthesize plViewController = _plViewController;

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
    self.plViewController = [[UIViewController alloc]init];
    
    NSLog(@"loadview playlistview");
    
    
    starredTracksArray = [[NSMutableArray alloc] init];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    self.plMainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, winSize.width,winSize.height)];
    self.plMainView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    self.plMainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = self.plMainView;
    
   
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    NSLog(@"viewdidload playlistview");
    playlistsLoaded = NO;
    [self createloadingview];
    
    
    
    
   
    
}

- (void)createloadingview{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    int widthL, heightL;
    if (main.mainViewController.landscapeMode) {
        widthL = 1024;
        heightL = 768;
    }else {
        widthL = 768;
        heightL = 1024;
        
    }
    
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, widthL, heightL)];
    loadingView.backgroundColor = [UIColor blackColor];
    
    UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    av.frame=CGRectMake((widthL/2)-(85/2), (heightL/2)-(85/2), 85, 85);
    av.tag  = 1;
    [loadingView addSubview:av];
    [av startAnimating];
    
    
    [self.view addSubview:loadingView];
}

- (void)loadplaylists{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
 
    NSLog(@"imagecontainer length: %d",[main.imageContainer count]);
    NSMutableArray *dataContainer = [[NSMutableArray alloc]initWithArray:main.imageContainer];
    for (NSMutableArray *data in dataContainer){
        
        NSInteger plNumber = [(NSNumber *)[data objectAtIndex:0] integerValue];
        NSString *plName = (NSString *)[data objectAtIndex:1];
        UIImage *plImage = (UIImage *)[data objectAtIndex:2];
        
        if (x >= parentWidth){
            x=margin;
            rowCount++;
            y=(height*rowCount)+(rowCount*margin);
        }
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame = CGRectMake(x, y, width, height);// position in the parent view and set the size of the
        [myButton setTag:plNumber];
        [myButton setBackgroundImage:plImage forState:UIControlStateNormal];
        
        [myButton addTarget:self 
                     action:@selector(plClicked:)
           forControlEvents:UIControlEventTouchDown];
        
        CGSize size = myButton.frame.size;
        
        //create the label for the playlist
        UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width, 30)]autorelease];
        plTitle.textAlignment =  UITextAlignmentCenter;
        plTitle.textColor = [UIColor blackColor];
        plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
        plTitle.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(16.0)];
        plTitle.text = [NSString stringWithFormat: @"%@",plName];
        [myButton addSubview:plTitle];
        
        [self.plMainView addSubview:myButton];
        
        x = x+width+margin;
        
    }
}

- (void) doLoadingOnNewThread {
	[NSThread detachNewThreadSelector:@selector(startTheProcess) toTarget:self withObject:nil];
}
- (void) startTheProcess {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (createStarredBox){
        [self createStarredTracksPlaylist:[[SPSession sharedSession] userPlaylists]];
        
    }
    [self loadplaylists];
    [loadingView removeFromSuperview];
    
	[pool release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [_plViewController release];
    [starredTracksArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        [main.mainViewController activateLandscapeMode];
    }else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [main.mainViewController activatePortraitMode];
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"viewwillappear playlist view");
    orientationIsLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    if ([main.imageContainer count] > 0){
        if(!playlistsLoaded){
            [self initGridParams];
            [self doLoadingOnNewThread];
            playlistsLoaded = YES;
        }
    }
 
}

- (void)setplaylistsloaded:(BOOL)val{
    
    playlistsLoaded = val;
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    NSLog(@"viewdiddisappear playlist view");
    
}



- (void)initGridParams{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[[[SPSession sharedSession] starredPlaylist] items] count] > 0){
        createStarredBox = YES;
    
    }else{
        createStarredBox = NO;
    } 
    
    plCounter = 0;
    margin = 6;
    nrOfPl = 0;
    rows = 0;
    rowCount = 0;
    columns = 0;
    parentWidth = 3200;
    parentHeight = 3200;
    
    
    int nrofViewChilds = [[self.plMainView subviews]count];
    NSLog(@"bitch: %d",nrofViewChilds);
    
    plContainer = [[SPSession sharedSession] userPlaylists];
    
    //nrOfPl = [[plContainer playlists] count];
    nrOfPl = [main.imageContainer count];
    NSLog(@"nrofPl:%f",nrOfPl);
    
    //adding the starred tracks to get correct numbahs
    rows = ceil(sqrt(nrOfPl+1));
    rowCount = 0;
    columns = ceil((nrOfPl+1)/rows);
    NSLog(@"rows:%f",rows);
    NSLog(@"columns:%f",columns);
    
    height = 180;
    width = 180;
    
  //  rows++;
    NSLog(@"rows:%f",rows);
    
    
    parentWidth = columns*width+(margin*columns)+margin;
    parentHeight = rows*height+(margin*rows)+margin;
    
    y = 0;
    if (createStarredBox){
        x = width + (margin*2);
        
    }else{
        x = margin;
        
    }
    
    NSLog(@"height:%f, width:%f",height,width);
    
    self.plMainView.contentSize = CGSizeMake(parentWidth, parentHeight);
    self.plMainView.scrollEnabled = YES;
    
}



-(void)createStarredTracksPlaylist:(SPPlaylistContainer *)playlistContainer{
    
    SPPlaylist *starred = [[SPSession sharedSession]starredPlaylist];
    
    for (SPPlaylistItem *item in starred.items){
        SPTrack *track = [[SPSession sharedSession]trackForURL:item.itemURL];
        if (track.starred && track.availability == 1){
            [starredTracksArray addObject:item.itemURL];
        }
    }
    
    UIButton *starredButton = [UIButton buttonWithType:UIButtonTypeCustom];
    starredButton.frame = CGRectMake(margin, 0, width, height);// position in the parent view and set the size of the
    // myButton.layer.borderWidth = 2;
    starredButton.backgroundColor = [UIColor grayColor];
    
    [starredButton addTarget:self 
                 action:@selector(starredClicked)
       forControlEvents:UIControlEventTouchDown];
    
    NSString* imagepathStar = [[NSBundle mainBundle] pathForResource:@"starbg" ofType:@"jpg"];
    
    UIImage *starImg = [UIImage imageWithContentsOfFile:imagepathStar];
    
    [starredButton setBackgroundImage:starImg forState:UIControlStateNormal];
    
    CGSize size = starredButton.frame.size;
    
    UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width, 30)]autorelease];
    plTitle.textAlignment =  UITextAlignmentCenter;
    plTitle.textColor = [UIColor blackColor];
    plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    plTitle.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(16.0)];
    plTitle.text = [NSString stringWithFormat: @"Starred tracks"];
    [starredButton addSubview:plTitle];
    
    [self.plMainView addSubview:starredButton];
    
    
}
-(void)starredClicked{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *plbgView;
    int bgwidth, bgheight;
    int boxHeight, boxWidth;
    int labelX, labelY;
    
    orientationIsLandscape = [main.mainViewController landscapeMode];
    
    if (orientationIsLandscape){
        bgwidth = 1024;
        bgheight = 768;
        boxWidth = 750;
        boxHeight = 600;
        labelX = 140;
        labelY = 40;
        
    }else {
        bgwidth = 768;
        bgheight = 1024;
        boxHeight = 750;
        boxWidth = 600;
        labelX = 90;
        labelY = 90;
    }
    
    [main.mainViewController toggleGUIhidden:YES];
    
    CGPoint offsetPnt = self.plMainView.contentOffset;
    
    UITapGestureRecognizer *bgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeplBg:)];
    bgTouch.numberOfTapsRequired = 1;
    
    plbgView =[[UIView alloc] initWithFrame: CGRectMake(offsetPnt.x, offsetPnt.y, bgwidth, bgheight)];
    
    plbgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.79];   
    [plbgView addGestureRecognizer:bgTouch]; 
    
    [bgTouch release];    
    
    UIView *plView=[[UIView alloc] initWithFrame: CGRectMake((bgwidth/2)-(boxWidth/2)+offsetPnt.x,
                                                             (bgheight/2)-(boxHeight/2)+offsetPnt.y,
                                                             boxWidth,boxHeight)];
    
    plView.backgroundColor = [UIColor clearColor];
    self.plViewController.view = plView;
    [self.view addSubview:plbgView];    
    [self.view addSubview:self.plViewController.view];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, bgwidth-100, 50) ];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:245/255.f
                                            green:247/255.f
                                             blue:227/255.f    
                                            alpha:1];
    headerLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(28.0)];
    [headerLabel setAdjustsFontSizeToFitWidth:YES];
    [plbgView addSubview:headerLabel];
   
    headerLabel.text = @"Starred tracks";
    
    plTableView *plSongTable = [[plTableView alloc]initWithFrame:CGRectMake(0, 10, boxWidth, boxHeight) andDataArray:starredTracksArray];
    plSongTable.backgroundColor = [UIColor clearColor];
    [self.plViewController.view addSubview:plSongTable];
    [self.plMainView setScrollEnabled:NO];
    
    [plSongTable release];
    [plbgView release];    
    [plView release];
    [headerLabel release];
    
    
}


-(void)plClicked:(id)sender{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int bgwidth, bgheight;
    int boxHeight, boxWidth;
    int labelX, labelY;
    
    orientationIsLandscape = [main.mainViewController landscapeMode];
    
    if (orientationIsLandscape){
        bgwidth = 1024;
        bgheight = 768;
        boxWidth = 750;
        boxHeight = 600;
        labelX = 140;
        labelY = 40;
    }else {
        bgwidth = 768;
        bgheight = 1024;
        boxHeight = 750;
        boxWidth = 600;
        labelX = 90;
        labelY = 90;
    }

    
    [main.mainViewController toggleGUIhidden:YES];
    
    UIButton *btn = (UIButton*)sender;
    NSLog(@"btn tag: %d",btn.tag);
    CGPoint offsetPnt = self.plMainView.contentOffset;
    
    UITapGestureRecognizer *bgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeplBg:)];
    bgTouch.numberOfTapsRequired = 1;
    
    UIView *plbgView =[[UIView alloc] initWithFrame: CGRectMake(offsetPnt.x, offsetPnt.y, bgwidth, bgheight)];
    plbgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.86];   
    [plbgView addGestureRecognizer:bgTouch]; 
    
    [bgTouch release];    
    
    UIView *plView=[[UIView alloc] initWithFrame: CGRectMake((bgwidth/2)-(boxWidth/2)+offsetPnt.x,
                                                             (bgheight/2)-(boxHeight/2)+offsetPnt.y,
                                                             boxWidth,boxHeight)];
    
    plView.backgroundColor = [UIColor clearColor];
    
    self.plViewController.view = plView;
    
    [self.view addSubview:plbgView];    
    [self.view addSubview:self.plViewController.view];
    
    [Shared sharedInstance].curClickedPl = btn.tag;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, bgwidth-100, 50) ];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithRed:245/255.f
                                            green:247/255.f
                                             blue:227/255.f    
                                            alpha:1];
    headerLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(28.0)];
    [headerLabel setAdjustsFontSizeToFitWidth:YES];
    [plbgView addSubview:headerLabel];
    
    SPPlaylist *plToShow = [plContainer.playlists objectAtIndex:btn.tag];
    
    NSMutableArray *plContainerArray = [[NSMutableArray alloc] init];
    
    if ([plToShow isKindOfClass:[SPPlaylistFolder class]]){
        SPPlaylistFolder *plFolder = [plContainer.playlists objectAtIndex:btn.tag];
        
        headerLabel.text = [NSString stringWithFormat: @"%@", plFolder.name];
        
        for (int i=0;i<[plFolder.playlists count];i++){
            plToShow = [plFolder.playlists objectAtIndex:i];
            NSMutableArray *plList = [[NSMutableArray alloc]init];
            
            for (int i=0;i<[plToShow.items count];i++){
                
                SPPlaylistItem *plItem = [plToShow.items objectAtIndex:i];
            //    NSString *str = [self getTrackStr:plItem];
                NSURL *url = plItem.itemURL;
                [plList addObject:url];
                
            }
            [plContainerArray addObject:plList];
            [plList release];
        }
    }
    else{
        headerLabel.text = [NSString stringWithFormat: @"%@", plToShow.name];
        
        for (int i=0;i<[plToShow.items count];i++){
            SPPlaylistItem *plItem = [plToShow.items objectAtIndex:i];
            //NSString *str = [self getTrackStr:plItem];
            NSURL *url = plItem.itemURL;
            [plContainerArray addObject:url];
            
        }
    }
    
    plTableView *plSongTable = [[plTableView alloc]initWithFrame:CGRectMake(0, 10, boxWidth, boxHeight) andDataArray:plContainerArray];
    plSongTable.backgroundColor = [UIColor clearColor];
    
    [self.plViewController.view addSubview:plSongTable];
    
    [self.plMainView setScrollEnabled:NO];
    
    [plContainerArray release];
    [plbgView release];    
    [plView release];
    [headerLabel release];
    [plSongTable release];
    
}

-(NSString *)getTrackStr:(SPPlaylistItem *)plItem{
    
    NSURL *trackurl = plItem.itemURL;
    SPTrack *plTrack = [[SPSession sharedSession] trackForURL:trackurl];
    NSString *artists = [[plTrack.artists valueForKey:@"name"] componentsJoinedByString:@","];
    NSString *title = plTrack.name;
    NSString *finalStr = [NSString stringWithFormat:@"%@ - %@",artists,title];
    
    return finalStr;  
}

-(void)removeplBg:(UITapGestureRecognizer *)tap{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *view = [tap view];
    
    for (UIView *subview in [self.plViewController.view subviews]) 
    {
        [subview removeFromSuperview];
    }
    
    [self.plViewController.view removeFromSuperview];
    [view removeFromSuperview];
    
    [self.plMainView setScrollEnabled:YES];
    
    [main.mainViewController toggleGUIhidden:NO];
    
}




@end
