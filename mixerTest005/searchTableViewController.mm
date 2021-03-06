//
//  searchTableViewController.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-06.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "searchTableViewController.h"
#import "AppDelegate.h"
@implementation searchTableViewController

@synthesize detailArr;
@synthesize loadingView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
/*
- (void)loadView{
  //  self.navigationController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]autorelease];
  //  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    searchTableViewController* tv = [[[searchTableViewController alloc]initWithFrame: CGRectZero style: UITableViewStylePlain]autorelease];
    tv.dataSource = self;
    tv.delegate = self;
    self.view = tv;
    self.tableView = tv;
    
}
*/
- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewdidappear");
 //   self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *cancelButton =
	[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                     style: UIBarButtonItemStylePlain
                                    target: self
                                    action: @selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];
    
}


- (void)viewDidLoad
{
   // self.tableView.backgroundColor = [UIColor blackColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 
    offsetAlbum = 0;
    offsetTracks = 0;
    offsetArtists = 0;
    //sessionArr = [NSMutableArray arrayWithArray:self.detailArr];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"arrayUpdated"]) {
        NSLog(@"array updated");
    //    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self setData];
      //  self.detailArr = context.mainViewController.searchController.model.resultArray;
        
    }   
    else if ([keyPath isEqualToString:@"albBrowseUpdated"]) {
        NSLog(@"albBrowse updated");
        
        //    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self loadtrackTableViewController];
        //  self.detailArr = context.mainViewController.searchController.model.resultArray;
        
        
    }
    else if ([keyPath isEqualToString:@"artBrowseUpdated"]) {
        NSLog(@"albBrowse updated");
        //    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self loadartBrowseTableViewController];
        //  self.detailArr = context.mainViewController.searchController.model.resultArray;
        
    }
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.detailArr release];
     
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [super viewDidDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        return YES;
        
    }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        return YES;
    }
}

- (void)setData{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (![self.detailArr isEqualToArray:main.mainViewController.searchController.model.resultArray]){
        self.detailArr = main.mainViewController.searchController.model.resultArray;
        //   NSMutableArray *arr = [NSMutableArray arrayWithArray:sessionArr];
        //   [detailArr addObject:sessionArr];
        //   [detailArr insertObject:arr atIndex:0];
        switch (getmoreSectionNum) {
            case 0:
                offsetAlbum += 25;
                break;
                
            case 1:
                offsetTracks += 25;
                break;
                
            case 2:
                offsetArtists += 25;
                break;
                
            default:
                break;
        }
        NSLog(@"offsetalbum: %d",offsetAlbum);
        
        NSLog(@"number albums: %d, number tracks: %d ",[[self.detailArr objectAtIndex:0] count], [[self.detailArr objectAtIndex:1]count]);
        
        [self.tableView reloadData];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        CGSize size = tableView.frame.size;
        // create the parent view that will hold header Label
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, 50.0)];
        
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
   //     headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(28.0)];
        headerLabel.frame = CGRectMake(10.0, 0.0, size.width, 50.0);
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
        NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[detailArr objectAtIndex:section]];
    
        NSString *lbl;
        if(![sectionArr count] == 0){
          
            if([[sectionArr objectAtIndex:0] isKindOfClass:[SPAlbum class]]){
                lbl = @"Albums";
                
            }
            else if([[sectionArr objectAtIndex:0] isKindOfClass:[SPTrack class]]){
                lbl = @"Tracks";
                
            }
            else if([[sectionArr objectAtIndex:0] isKindOfClass:[SPArtist class]]){
                lbl = @"Artists";
            }
            
            
            customView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.9];
            headerLabel.text = [NSString stringWithFormat:lbl]; // i.e. array element
            [customView addSubview:headerLabel];
        
        }
        
    return customView;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"number sections: %d",[detailArr count]);
    return [detailArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    // return [[detailArr objectAtIndex:section]count];
    int nrOfObjects = [[detailArr objectAtIndex:section]count];
    NSMutableArray *sectionArr = [NSMutableArray arrayWithArray:[detailArr objectAtIndex:section]];
    if ([sectionArr count]>0){
        if([[sectionArr objectAtIndex:0] isKindOfClass:[SPAlbum class]]){
            if (nrOfObjects-offsetAlbum < 25){
                return nrOfObjects;
            }
            else{
                return nrOfObjects+1;     
            }
            
        }else if ([[sectionArr objectAtIndex:0] isKindOfClass:[SPTrack class]]) {
            if (nrOfObjects-offsetTracks < 25){
                return nrOfObjects;
            }
            else{
                return nrOfObjects+1;     
            }
            
        }else if ([[sectionArr objectAtIndex:0] isKindOfClass:[SPArtist class]]) {
            if (nrOfObjects-offsetArtists < 25){
                return nrOfObjects;
            }
            else{
                return nrOfObjects+1;     
            }
            
        }
        
    
     }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  self.tableView.backgroundColor = [UIColor blackColor];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    for (UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    NSString *lbl;
    
    NSLog(@"indexpath.section %d",indexPath.section);
    NSLog(@"indexpath.row %d",indexPath.row);
    NSLog(@"arr length: %d",[self.detailArr count]);
    NSMutableArray *sectionArr = [NSMutableArray arrayWithArray:[self.detailArr objectAtIndex:indexPath.section]];
    
    //check if last line. Create a showmore btn if true
    //check here if more results is available ?? TODO
    if (indexPath.row == [sectionArr count]){
      
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, self.view.frame.size.width, 30)];
        title.text = @"Show more results  +";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = UITextAlignmentCenter;
        title.font = [UIFont fontWithName:@"GothamHTF-Book" size:(18.0)];
        title.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:title];
        [title release];
        
        
    }else {
        if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPAlbum class]]){
            SPAlbum *album = [sectionArr objectAtIndex:indexPath.row];
            
            lbl = [NSString stringWithFormat:@"%@ - %@",album.artist.name,album.name];
            
            UILabel *yearlbl = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, 5, 50, 30)];
            yearlbl.backgroundColor = [UIColor clearColor];
            yearlbl.textColor = [UIColor whiteColor];
            yearlbl.textAlignment = UITextAlignmentCenter;
            yearlbl.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(18.0)];
            if (album.year > 0)
                yearlbl.text = [NSString stringWithFormat:@"%d",album.year];
            else
                yearlbl.text = @"-";
            [cell.contentView addSubview:yearlbl];
            [yearlbl release];
            
        }
        else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPTrack class]]){
            SPTrack *track = [sectionArr objectAtIndex:indexPath.row];
            NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
            lbl = [NSString stringWithFormat:@"%@ - %@",artists,track.name];
            
            UILabel *cue = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-110, 10, 60, 20)];
            cue.text = @"Cue Song";
            cue.textAlignment = UITextAlignmentCenter;
            cue.textColor = [UIColor blackColor];
            cue.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(12.0)];
            cue.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:cue];
            [cue release];
            
            NSTimeInterval interval = track.duration;
            long min = (long)interval / 60;    // divide two longs, truncates
            long sec = (long)interval % 60;    // remainder of long divide
            NSString* str = [[NSString alloc] initWithFormat:@"%02d:%02d", min, sec];
            
            UILabel *trackDuration = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-200, 5, 100, 30)];
            trackDuration.text = str;
            trackDuration.textColor = [UIColor whiteColor];
            trackDuration.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:trackDuration];
            trackDuration.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(18.0)];
            [trackDuration release];
            
            
        }
        else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPArtist class]]){
            SPArtist *artist = [sectionArr objectAtIndex:indexPath.row];
            lbl = [NSString stringWithFormat:@"%@",artist.name];
            
        }
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, self.view.frame.size.width-220, 30)];
        title.text = lbl;
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(18.0)];
        title.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:title];
        [title release];
        
       
     }
    //cell.contentView.backgroundColor = [UIColor blackColor];
   // cell.backgroundColor = [UIColor blackColor];
    
 //   cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (void)cancel:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main.mainViewController.searchController.model releaseSearchObject];
    
 //   main.cueController.view.hidden = NO;
    
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UITableViewCell* theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    //Then you change the properties (label, text, color etc..) in your case, the background color
    theCell.contentView.backgroundColor = [UIColor whiteColor];
    
    //Deselect the cell so you can see the color change
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[self.detailArr objectAtIndex:indexPath.section]];
    
    
    //the maximum number of cells needs to be changed before this. Global variable I guess would do it. TODO
    
    /*
     Loading view
     */
    CGSize winSize = self.tableView.frame.size;
    CGPoint offsetPnt = self.tableView.contentOffset;
    self.loadingView = [[UIView alloc]initWithFrame:CGRectMake(offsetPnt.x, offsetPnt.y, winSize.width, winSize.height)];
    self.loadingView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:.9];
    [self.view addSubview:self.loadingView];
    
    UIActivityIndicatorView  *av = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    av.frame=CGRectMake((winSize.width/2)-(85/2), ((winSize.height/2)-(85/2))-40, 85, 85);
    av.tag  = 1;
    [self.loadingView addSubview:av];
    [av startAnimating];
    
    NSLog(@"indexpath %d",indexPath.row);
    if (indexPath.row == [sectionArr count]){
        //  maxresultAlbums += 20;
        getmoreSectionNum = indexPath.section;
        [self loadmoreresults];
        [self.loadingView removeFromSuperview];
    }
    else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPAlbum class]]){
     
        [main.mainViewController.searchController.model addObserver:self forKeyPath:@"albBrowseUpdated" options:NSKeyValueObservingOptionNew context:nil];
        
        SPAlbum *album = [sectionArr objectAtIndex:indexPath.row];
        
        [main.mainViewController.searchController.model setAlbumToBrowse:album];
        SEL func = @selector(browseAlbum);
        [main.mainViewController.searchController.model doSearchOnNewThread:func];
        
    }
    else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPTrack class]]){
     
        SPTrack *track = [sectionArr objectAtIndex:indexPath.row];
        [main addSongFromSearch:track.spotifyURL];
        
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
        
    }
    else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPArtist class]]){
        
        [main.mainViewController.searchController.model addObserver:self forKeyPath:@"artBrowseUpdated" options:NSKeyValueObservingOptionNew context:nil];
        
        SPArtist *artist = [sectionArr objectAtIndex:indexPath.row];
   
        [main.mainViewController.searchController.model setArtistToBrowse:artist];
        SEL func = @selector(browseArtist);
        [main.mainViewController.searchController.model doSearchOnNewThread:func];
        
        
    }
    [sectionArr release];
    
}

- (void)loadmoreresults{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SEL func;
    switch (getmoreSectionNum) {
        case 0:
            func = @selector(getMoreAlbums);
            [main.mainViewController.searchController.model doSearchOnNewThread:func];
            break;
        
        case 1:
            func = @selector(getMoreTracks);
            [main.mainViewController.searchController.model doSearchOnNewThread:func];
            
            break;
        
        case 2:
            func = @selector(getMoreArtists);
            [main.mainViewController.searchController.model doSearchOnNewThread:func];
            
            break;
            
        default:
            break;
    }
    
    [main.mainViewController.searchController.model addObserver:self forKeyPath:@"arrayUpdated" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)loadtrackTableViewController{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main.mainViewController.searchController.model removeObserver:self forKeyPath:@"albBrowseUpdated"];
    
    trackTableViewController *trackTableController = [[trackTableViewController alloc]init];
    NSMutableArray *wrapper = [NSMutableArray arrayWithArray:main.mainViewController.searchController.model.resultArray];
    NSMutableArray *detail = [[NSMutableArray alloc]init];
    [detail addObject:wrapper];
    trackTableController.detailArr = detail;
    trackTableController.tableView.backgroundColor = [UIColor blackColor];
    [self.navigationController pushViewController:trackTableController animated:YES];
    [trackTableController release];
   
}

- (void)loadartBrowseTableViewController{
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [main.mainViewController.searchController.model removeObserver:self forKeyPath:@"artBrowseUpdated"];
    
    reSearchTableViewController *detailViewController = [[reSearchTableViewController alloc]init];
    //   SPAlbum *album = [arr objectAtIndex:indexPath.row];
    //   SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:album inSession:[SPSession sharedSession]];
    NSMutableArray *detail = [NSMutableArray arrayWithArray:main.mainViewController.searchController.model.resultArray];
  //  NSMutableArray *detail = [[NSMutableArray alloc]init];
  //  [detail addObject:wrapper];
    detailViewController.detailArr = detail;
    detailViewController.tableView.backgroundColor = [UIColor blackColor];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
   // [detail release];
    
    
}

-(void)dealloc{
    [super dealloc];
    
}

@end
