//
//  playlistView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "playlistView.h"
#import "plTableView.h"
#import "Shared.h"

@implementation playlistView

@synthesize plContainer = _plContainer;
@synthesize loadPlaylist = _loadPlaylist;
@synthesize trackimg = _trackimg;
@synthesize plViewController = _plViewController;
@synthesize tempImg = _tempImg;
@synthesize plCallback = _plCallback;
@synthesize loadItem = _loadItem;
@synthesize plCallb = _plCallb;
@synthesize itemCallback = _itemCallback;


int plCounter = 0;
int margin = 6;
CGFloat x = 5;
CGFloat y = 0;
CGFloat height;
CGFloat width;
int nrOfPl = 0;
int rows = 0;
int rowCount = 0;
int columns = 0;
int parentWidth = 3200;
int parentHeight = 3200;

int tagAdd = 10;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            // Initialization code
        
        self.plViewController = [[playlistViewController alloc]init];
        
        missedPlArray = [[NSMutableArray alloc] init];
        
        [self addObserver:self forKeyPath:@"loadPlaylist.items" options:0 context:nil];
        
        [self addObserver:self forKeyPath:@"trackimg.album.cover.image" options:0 context:nil];
        

         
        
    }
    return self;
}

- (void)initGridParams{
    
    int nrofViewChilds = [[self subviews]count];
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
    x = 5;
    
    
    NSLog(@"height:%f, width:%f",height,width);
    
    //  parentWidth = (width * columns)+(margin * columns);
    //  parentHeight = (height * (rows+1))+(margin * rows);
    self.contentSize = CGSizeMake(parentWidth+(margin*columns), parentHeight+(rows*margin)+height);
    self.scrollEnabled = YES;
    
   
    self.loadPlaylist = nil;
    self.trackimg = nil;
    self.plCallback = nil;
    self.tempImg = nil;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"trackimg.album.cover.image"]) {
        self.tempImg = self.trackimg.album.cover.image;
        
        if (self.trackimg.album.cover.isLoaded){
            NSLog(@"loaded image nr: %d",plCounter);
         
            [self createnewplBox:self.tempImg];
            if (plCounter < nrOfPl){
                [self checkPlLoad:plContainer];    
            }
        }
	}
    else if ([keyPath isEqualToString:@"loadPlaylist.items"]){
      //  self.plCallback = self.loadPlaylist.items;
        self.plCallb = self.loadPlaylist;
        if(self.loadPlaylist.isLoaded)
         
            [self setLoadedTrack:self.loadPlaylist];
    }
}

-(void)removeObservers{
    [self removeObserver:self forKeyPath:@"trackimg.album.cover.image"];
    [self removeObserver:self forKeyPath:@"loadPlaylist.items"];

    
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
                if (track.availability == 1){
                    img = track.album.cover.image;
                    
                    UIButton *btn = (UIButton *)[self viewWithTag:plNum+tagAdd];
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
        [self addSubview:myButton];
        
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
                
                foundValidTrack = YES;
                playlistItem = trackTest;
            }
        }
    }
    if (!foundValidTrack){
        UIButton *btn = (UIButton *)[self viewWithTag:plCounter+tagAdd];
        for (UIView *view in [btn subviews]){
            [view removeFromSuperview];
            
        }
        NSNumber *missedplNum = [NSNumber numberWithInt:plCounter];
        [missedPlArray addObject:missedplNum];
        plCounter++;
        
        [self checkPlLoad:plContainer];
        
    }
   // playlistItem = [playlistDetail.items objectAtIndex:0];
   /* 
    if (playlistItem.itemURLType == SP_LINKTYPE_INVALID){
        
        UIButton *btn = (UIButton *)[self viewWithTag:plCounter+tagAdd];
        for (UIView *view in [btn subviews]){
            [view removeFromSuperview];
            
        }
        NSNumber *missedplNum = [NSNumber numberWithInt:plCounter];
        [missedPlArray addObject:missedplNum];
        plCounter++;
        
        [self checkPlLoad:plContainer];
    }
    */
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
            UIButton *btn = (UIButton *)[self viewWithTag:plCounter+tagAdd];
            for (UIView *view in [btn subviews]){
                [view removeFromSuperview];
                
            }
            NSNumber *missedplNum = [NSNumber numberWithInt:plCounter];
            [missedPlArray addObject:missedplNum];
            plCounter++;
            [self checkPlLoad:plContainer];
            
        }   

    }
}

-(void)createnewplBox:(UIImage *)img{
    
    
    UIButton *btn = (UIButton *)[self viewWithTag:plCounter+tagAdd];
    NSLog(@"plcounter: %d",plCounter);
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    
    NSLog(@"subviews: %d",[[btn subviews] count]);
    for (UIView *view in [btn subviews]){
        [view removeFromSuperview];
        
    }
    
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
    CGSize rect = self.window.frame.size;
    CGPoint offsetPnt = self.contentOffset;
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
    
    [self addSubview:plbgView];    
    [self addSubview:self.plViewController.view];
    
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
                NSString *str = [self getTrackStr:plItem];
                [plList addObject:str];
                
            }
            [plContainerArray addObject:plList];
            [plList release];
        }
    }
    else{
        headerLabel.text = [NSString stringWithFormat: @"%@", plToShow.name];
        
        for (int i=0;i<[plToShow.items count];i++){
            SPPlaylistItem *plItem = [plToShow.items objectAtIndex:i];
            NSString *str = [self getTrackStr:plItem];
            [plContainerArray addObject:str];
            
        }
    }
    
    plTableView *plSongTable = [[plTableView alloc]initWithFrame:CGRectMake(0, 80, 400, 400) andDataArray:plContainerArray];
    plSongTable.backgroundColor = [UIColor clearColor];
    
    [self.plViewController.view addSubview:plSongTable];
    
    [self setScrollEnabled:NO];
    
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
    
    [self setScrollEnabled:YES];
    
    
}




- (void)dealloc{
    [self removeObserver:self forKeyPath:@"trackimg.album.cover.image"];
    [self removeObserver:self forKeyPath:@"loadPlaylist.items"];
    
    
    
    [_plContainer release];
    [_loadPlaylist release];
    [_trackimg release];
    [_plViewController release];
    [_tempImg release];
    [_plCallback release];
    [_loadItem release];
    [missedPlArray release];
  
    [super dealloc];
}

@end
