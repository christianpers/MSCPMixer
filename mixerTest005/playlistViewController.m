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

@implementation playlistViewController

@synthesize plMainView;
@synthesize plContainer = _plContainer;
@synthesize loadPlaylist = _loadPlaylist;
@synthesize trackimg = _trackimg;
@synthesize plViewController = _plViewController;
@synthesize tempImg = _tempImg;
@synthesize plCallback = _plCallback;
@synthesize loadItem = _loadItem;
@synthesize plCallb = _plCallb;
@synthesize itemCallback = _itemCallback;




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
    missedPlArray = [[NSMutableArray alloc] init];
    starredTracksArray = [[NSMutableArray alloc] init];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    self.plMainView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, winSize.width,winSize.height)];
    self.view = self.plMainView;
    
  
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self initGridParams];
    if (createStarredBox){
        
        [self createStarredTracksPlaylist:[[SPSession sharedSession] userPlaylists]];
        
    }
    [self addObserver:self forKeyPath:@"self.loadPlaylist.items" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.trackimg.album.cover.image" options:0 context:nil];
    [self loadPlaylistView:[[SPSession sharedSession] userPlaylists]];
    [self checkPlLoad:[[SPSession sharedSession] userPlaylists]];
    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self removeObservers];
    [_plContainer release];
    [_loadPlaylist release];
    [_trackimg release];
    [_plViewController release];
    [_tempImg release];
    [_plCallback release];
    [_loadItem release];
    [missedPlArray release];
    [starredTracksArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewwillappear");
       
    // [self.view addSubview:self.plMainView];
   
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    NSLog(@"viewdiddisappear");
    
}



- (void)initGridParams{
    
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
    
    tagAdd = 10;
    
    
    int nrofViewChilds = [[self.plMainView subviews]count];
    NSLog(@"bitch: %d",nrofViewChilds);
    
    plContainer = [[SPSession sharedSession] userPlaylists];
    
    nrOfPl = [[plContainer playlists] count];
    NSLog(@"nrofPl:%d",nrOfPl);
    
    rows = floor(sqrt(nrOfPl));
    rowCount = 0;
    columns = nrOfPl/rows;
    NSLog(@"rows:%d",rows);
    NSLog(@"columns:%d",columns);
    
    parentHeight = 3200;
    parentWidth = 3200;
    
    height = parentHeight/rows;
    width = parentWidth/columns;
    
    y = 0;
    if (createStarredBox){
        x = width + 11;
        
    }else{
        x = 5;
        
    }
    
    NSLog(@"height:%f, width:%f",height,width);
    
    //  parentWidth = (width * columns)+(margin * columns);
    //  parentHeight = (height * (rows+1))+(margin * rows);
    self.plMainView.contentSize = CGSizeMake(parentWidth+(margin*columns), parentHeight+(rows*margin)+height);
    self.plMainView.scrollEnabled = YES;
    
    // self.loadPlaylist = nil;
    // self.trackimg = nil;
    // self.plCallback = nil;
    // self.tempImg = nil;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.trackimg.album.cover.image"]) {
        self.tempImg = self.trackimg.album.cover.image;
        
        if (self.trackimg.album.cover.isLoaded){
            NSLog(@"loaded image nr: %d",plCounter);
            
            [self createnewplBox:self.tempImg];
            if (plCounter < nrOfPl){
                [self checkPlLoad:plContainer];    
            }
        }
	}
    else if ([keyPath isEqualToString:@"self.loadPlaylist.items"]){
        //  self.plCallback = self.loadPlaylist.items;
        self.plCallb = self.loadPlaylist;
        if(self.loadPlaylist.isLoaded)
            
            [self setLoadedTrack:self.loadPlaylist];
    }
}

-(void)removeObservers{
    [self removeObserver:self forKeyPath:@"self.trackimg.album.cover.image"];
    [self removeObserver:self forKeyPath:@"self.loadPlaylist.items"];
    
}

-(void)setMissedPlaylists{
    
    SPPlaylistItem *item;
    SPTrack *track;
    UIImage *img;
    int availtrackIndex = 0;
    
    //   int plNum = [[missedPlArray objectAtIndex:0] intValue];
    int num = [missedPlArray count];
    
    NSEnumerator * enumerator = [missedPlArray objectEnumerator];
    id element;
    int i = 0;
    
    while(element = [enumerator nextObject])
    {
        // Do your thing with the object.
        int plNum = [[missedPlArray objectAtIndex:i] intValue];
        SPPlaylist *playlistDetail = [plContainer.playlists objectAtIndex:plNum];
        for (SPPlaylistItem *itemloop in playlistDetail.items){
            if (itemloop.itemURLType == SP_LINKTYPE_TRACK){
                
                track = [SPTrack trackForTrackURL:itemloop.itemURL inSession:[SPSession sharedSession]];
                int av = track.availability;
                
                if (track.availability == 1){
                    img = track.album.cover.image;
                    
                    UIButton *btn = (UIButton *)[self.plMainView viewWithTag:plNum+tagAdd];
                    [btn setBackgroundImage:img forState:UIControlStateNormal];
                    
                    NSLog(@"subviews: %d",[[btn subviews] count]);
                    for (UIView *view in [btn subviews]){
                        [view removeFromSuperview];
                        
                    }
                    
                    //[btn setTitle:[NSString stringWithFormat:@"%@",playlist.name] forState:UIControlStateNormal];
                    //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
                    CGPoint pos = btn.frame.origin;
                    CGSize size = btn.frame.size;
                    
                    //create the label for the playlist
                    UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width-5, 30)]autorelease];
                    plTitle.textAlignment =  UITextAlignmentCenter;
                    plTitle.textColor = [UIColor blackColor];
                    plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
                    plTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
                    plTitle.text = [NSString stringWithFormat: @"%@",playlistDetail.name];
                    [btn addSubview:plTitle];
                    
                }
            }
        }
        
        // [self checkMissedPlaylists:playlistDetail];
        i++;
    }
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
    starredButton.frame = CGRectMake(5, 0, width, height);// position in the parent view and set the size of the
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
    plTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    plTitle.text = [NSString stringWithFormat: @"Starred tracks"];
    [starredButton addSubview:plTitle];
    
    [self.plMainView addSubview:starredButton];
    
    
}
-(void)starredClicked{
    
    CGSize rect = self.plMainView.window.frame.size;
    CGPoint offsetPnt = self.plMainView.contentOffset;
    int boxHeight = 600;
    int boxWidth = 400;
    
    UITapGestureRecognizer *bgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeplBg:)];
    bgTouch.numberOfTapsRequired = 1;
    
    UIView *plbgView =[[UIView alloc] initWithFrame: CGRectMake(offsetPnt.x, offsetPnt.y, rect.width, rect.height)];
    plbgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.86];   
    [plbgView addGestureRecognizer:bgTouch]; 
    
    [bgTouch release];    
    
    UIView *plView=[[UIView alloc] initWithFrame: CGRectMake((rect.width/2)-(boxWidth/2)+offsetPnt.x,
                                                             (rect.height/2)-(boxHeight/2)+offsetPnt.y,
                                                             boxWidth,boxHeight)];
    
    plView.backgroundColor = [UIColor clearColor];
    
    self.plViewController.view = plView;
    
    [self.view addSubview:plbgView];    
    [self.view addSubview:self.plViewController.view];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, boxWidth, 40) ];
    headerLabel.textAlignment =  UITextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    [self.plViewController.view addSubview:headerLabel];
    
    headerLabel.text = @"Starred tracks";

    
    
    plTableView *plSongTable = [[plTableView alloc]initWithFrame:CGRectMake(0, 80, 400, 400) andDataArray:starredTracksArray];
    plSongTable.backgroundColor = [UIColor clearColor];
    [self.plViewController.view addSubview:plSongTable];
    [self.plMainView setScrollEnabled:NO];
    
    [plSongTable release];
    [plbgView release];    
    [plView release];
    [headerLabel release];
    
    
}

-(void)loadPlaylistView:(SPPlaylistContainer *)playlistContainer {
    
    for (int i=0;i<nrOfPl;i++){
        if (x >= parentWidth){
            x=5;
            rowCount++;
            y=(height*rowCount)+(rowCount*5);
        }
        UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton.frame = CGRectMake(x, y, width, height);// position in the parent view and set the size of the
        // myButton.layer.borderWidth = 2;
        [myButton setTag:i+tagAdd];
        myButton.backgroundColor = [UIColor whiteColor];
        // myButton.borderColor = [[UIColor blackColor]CGColor];
        
        SPPlaylist *playlistDetail = [playlistContainer.playlists objectAtIndex:i];
        NSLog(@"first pl:%@",playlistDetail.name);
        [myButton addTarget:self 
                     action:@selector(plClicked:)
           forControlEvents:UIControlEventTouchDown];
        
        
        UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        av.frame=CGRectMake((width/2)-(40/2),(height/2)-(40/2), 40, 40);
        [myButton addSubview:av];
        [av startAnimating];
        //   [av release];
        [self.plMainView addSubview:myButton];
        
        myButton.enabled = NO;
        
        //   [myButton release];
        
        x = x+width+margin;
    }
}

-(void)checkMissedPlaylists:(SPPlaylist *)pl{
    SPPlaylist *playlistDetail = pl;
    
    if (![playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        
        if (!playlistDetail.isLoaded){
            self.loadPlaylist = playlistDetail;
            //      plCounter++;
            //     [self performSelector:@selector(checkPlLoad:) withObject:plContainer afterDelay:0.1];
            //     return;
        }
        else{
            [self setLoadedTrack:playlistDetail];
        }
    }
    else {
        SPPlaylistFolder *plFolder = playlistDetail;
        SPPlaylist *pl = [plFolder.playlists objectAtIndex:0];
        self.loadPlaylist = pl;
    }
    
    
}

-(void)checkPlLoad:(SPPlaylistContainer *)plCon{
    
    
    SPPlaylist *playlistDetail = [plCon.playlists objectAtIndex:plCounter];
    
    if (![playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        
        if (!playlistDetail.isLoaded){
            
            self.loadPlaylist = playlistDetail;
            //      plCounter++;
            //     [self performSelector:@selector(checkPlLoad:) withObject:plContainer afterDelay:0.1];
            //     return;
        }
        else{
            [self setLoadedTrack:playlistDetail];
        }
    }
    else {
        SPPlaylistFolder *plFolder = playlistDetail;
        SPPlaylist *pl = [plFolder.playlists objectAtIndex:0];
        self.loadPlaylist = pl;
    }
}

-(void)setLoadedTrack:(SPPlaylist *)pl{
    
    SPPlaylist *playlistDetail = pl;
    SPPlaylistFolder *playlistFolder;
    SPPlaylistItem *playlistItem;
    Boolean foundValidTrack = NO;
    
    NSURL *trackURL;
    
    //check if folderSPPlaylistFolder
    if ([playlistDetail isKindOfClass:[SPPlaylistFolder class]]){
        playlistFolder = [plContainer.playlists objectAtIndex:plCounter];
        playlistDetail = [playlistFolder.playlists objectAtIndex:0];
        
    }
    
    NSLog(@"fucking shit: %@",playlistDetail.name);
    for (SPPlaylistItem *trackTest in playlistDetail.items){
        if (!foundValidTrack){
            if(trackTest.itemURLType == SP_LINKTYPE_TRACK){
                SPTrack *trackAvailTest = [[SPSession sharedSession] trackForURL:trackTest.itemURL];
                if (trackAvailTest.availability == 1){
                    foundValidTrack = YES;
                    playlistItem = trackTest;
                    
                }
                
            }
        }
    }
    if (!foundValidTrack){
        UIButton *btn = (UIButton *)[self.plMainView viewWithTag:plCounter+tagAdd];
        for (UIView *view in [btn subviews]){
            [view removeFromSuperview];
            
        }
        
        CGSize size = btn.frame.size;
        
        UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width, 30)]autorelease];
        plTitle.textAlignment =  UITextAlignmentCenter;
        plTitle.textColor = [UIColor blackColor];
        plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
        plTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
        plTitle.text = [NSString stringWithFormat: @"No valid tracks"];
        [btn addSubview:plTitle];
        
        NSNumber *missedplNum = [NSNumber numberWithInt:plCounter];
        [missedPlArray addObject:missedplNum];
        plCounter++;
        
        [self checkPlLoad:plContainer];
        
    }
    else{
        trackURL = playlistItem.itemURL;
        SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
        if (track.availability == 1){
            CGImageRef cgref = [track.album.cover.image CGImage];
            CIImage *cim = [track.album.cover.image CIImage];
            
            if (cim == nil && cgref == NULL)
            {
                NSLog(@"no underlying data");
                self.trackimg = track;
            }
            else{
                
                [self createnewplBox:track.album.cover.image];
                if (plCounter < nrOfPl){
                    [self checkPlLoad:plContainer];    
                }
                
            }
            
        }
        else
        {
            UIButton *btn = (UIButton *)[self.plMainView viewWithTag:plCounter+tagAdd];
            for (UIView *view in [btn subviews]){
                [view removeFromSuperview];
                
            }
            
            CGSize size = btn.frame.size;
            UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width, 30)]autorelease];
            plTitle.textAlignment =  UITextAlignmentCenter;
            plTitle.textColor = [UIColor blackColor];
            plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
            plTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
            plTitle.text = [NSString stringWithFormat: @"No valid tracks"];
            [btn addSubview:plTitle];
            
            
            
            NSNumber *missedplNum = [NSNumber numberWithInt:plCounter];
            [missedPlArray addObject:missedplNum];
            plCounter++;
            [self checkPlLoad:plContainer];
            
        }   
        
    }
}

-(void)createnewplBox:(UIImage *)img{
    
    
    UIButton *btn = (UIButton *)[self.plMainView viewWithTag:plCounter+tagAdd];
    NSLog(@"plcounter: %d",plCounter);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    
    NSLog(@"subviews: %d",[[btn subviews] count]);
    for (UIView *view in [btn subviews]){
        [view removeFromSuperview];
        
    }
    
    btn.enabled = YES;
    
    SPPlaylist *playlist = [plContainer.playlists objectAtIndex:plCounter];
    
    //[btn setTitle:[NSString stringWithFormat:@"%@",playlist.name] forState:UIControlStateNormal];
    //[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    CGPoint pos = btn.frame.origin;
    CGSize size = btn.frame.size;
    
    //create the label for the playlist
    UILabel *plTitle = [[ [UILabel alloc ] initWithFrame:CGRectMake(0, (size.height/2)-(30/2), size.width, 30)]autorelease];
    plTitle.textAlignment =  UITextAlignmentCenter;
    plTitle.textColor = [UIColor blackColor];
    plTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    plTitle.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(16.0)];
    plTitle.text = [NSString stringWithFormat: @"%@",playlist.name];
    [btn addSubview:plTitle];
    
    //[plTitle release];
    
    NSLog(@"plCounter: %d",plCounter);
    
    NSLog(@"nrofpl: %d", nrOfPl);
    if (plCounter == nrOfPl){
        
        [self setMissedPlaylists];
    }
    plCounter++;
    
    
}

-(void)plClicked:(id)sender{
    
    UIButton *btn = (UIButton*)sender;
    NSLog(@"btn tag: %d",btn.tag);
    CGSize rect = self.plMainView.window.frame.size;
    CGPoint offsetPnt = self.plMainView.contentOffset;
    int boxHeight = 600;
    int boxWidth = 400;
    
    UITapGestureRecognizer *bgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeplBg:)];
    bgTouch.numberOfTapsRequired = 1;
    
    UIView *plbgView =[[UIView alloc] initWithFrame: CGRectMake(offsetPnt.x, offsetPnt.y, rect.width, rect.height)];
    plbgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.86];   
    [plbgView addGestureRecognizer:bgTouch]; 
    
    [bgTouch release];    
    
    UIView *plView=[[UIView alloc] initWithFrame: CGRectMake((rect.width/2)-(boxWidth/2)+offsetPnt.x,
                                                             (rect.height/2)-(boxHeight/2)+offsetPnt.y,
                                                             boxWidth,boxHeight)];
    
    plView.backgroundColor = [UIColor clearColor];
    
    self.plViewController.view = plView;
    
    [self.view addSubview:plbgView];    
    [self.view addSubview:self.plViewController.view];
    
    [Shared sharedInstance].curClickedPl = btn.tag-tagAdd;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, boxWidth, 40) ];
    headerLabel.textAlignment =  UITextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    [self.plViewController.view addSubview:headerLabel];
    
    SPPlaylist *plToShow = [plContainer.playlists objectAtIndex:btn.tag-tagAdd];
    
    NSMutableArray *plContainerArray = [[NSMutableArray alloc] init];
    
    if ([plToShow isKindOfClass:[SPPlaylistFolder class]]){
        SPPlaylistFolder *plFolder = [plContainer.playlists objectAtIndex:btn.tag-tagAdd];
        
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
    
    plTableView *plSongTable = [[plTableView alloc]initWithFrame:CGRectMake(0, 80, 400, 400) andDataArray:plContainerArray];
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
    UIView *view = [tap view];
    
    for (UIView *subview in [self.plViewController.view subviews]) 
    {
        [subview removeFromSuperview];
    }
    
    [self.plViewController.view removeFromSuperview];
    [view removeFromSuperview];
    
    [self.plMainView setScrollEnabled:YES];
    
    
}




@end
