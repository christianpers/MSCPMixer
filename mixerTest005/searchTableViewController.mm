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
@synthesize albBrowse, artBrowse;
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
   
}
*/

- (void)viewDidLoad
{
    
   // self.tableView.backgroundColor = [UIColor blackColor];
    UIBarButtonItem *cancelButton =
	[[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                     style: UIBarButtonItemStylePlain
                                    target: self
                                    action: @selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"albBrowse.tracks"]) {
        SPAlbumBrowse *albumCallback = self.albBrowse;
        if([albumCallback.tracks count] > 0){
            
            trackTableViewController *trackTableController = [[trackTableViewController alloc]init];
            
          //  detailTableViewController *detailViewController = [[detailTableViewController alloc]init];
         //   SPAlbum *album = [arr objectAtIndex:indexPath.row];
         //   SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:album inSession:[SPSession sharedSession]];
            NSArray *array = albumCallback.tracks;
            NSMutableArray *detail = [[NSMutableArray alloc]init];
            [detail addObject:array];
            trackTableController.detailArr = detail;
            trackTableController.tableView.backgroundColor = [UIColor blackColor];
            [self.navigationController pushViewController:trackTableController animated:YES];
            [trackTableController release];
            [detail release];
            [self removeObserver:self forKeyPath:@"albBrowse.tracks"];
        }
        
    }
    else if ([keyPath isEqualToString:@"artBrowse.albums"]) {
     //   [self addObserver:self forKeyPath:@"artBrowse.relatedArtists" options:0 context:nil];
        SPArtistBrowse *artistCallback = self.artBrowse;
        if([artistCallback.albums count] > 0){
         /*   
            detailTableViewController *detailViewController = [[detailTableViewController alloc]init];
            //   SPAlbum *album = [arr objectAtIndex:indexPath.row];
            //   SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:album inSession:[SPSession sharedSession]];
            NSArray *albums = artistCallback.albums;
            NSArray *tracks = artistCallback.tracks;
            NSArray *related = artistCallback.relatedArtists;
            NSMutableArray *detail = [[NSMutableArray alloc]init];
            
            if (albums)
                [detail addObject:albums];
            if (tracks)
                [detail addObject:tracks];
            if (related)
                [detail addObject:related];
            
            detailViewController.detailArr = detail;
            detailViewController.tableView.backgroundColor = [UIColor blackColor];
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            [detail release];
            */
            [self removeObserver:self forKeyPath:@"artBrowse.albums"];
        }
    }
    else if ([keyPath isEqualToString:@"artBrowse.relatedArtists"]) {
        SPArtistBrowse *artistCallback = self.artBrowse;
        if ([artistCallback.relatedArtists count] > 0){
              
             reSearchTableViewController *detailViewController = [[reSearchTableViewController alloc]init];
             //   SPAlbum *album = [arr objectAtIndex:indexPath.row];
             //   SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:album inSession:[SPSession sharedSession]];
             NSArray *albums = artistCallback.albums;
             NSArray *tracks = artistCallback.tracks;
             NSArray *related = artistCallback.relatedArtists;
             NSMutableArray *detail = [[NSMutableArray alloc]init];
             
             if (albums)
                 [detail addObject:albums];
             if (tracks)
                 [detail addObject:tracks];
             if (related)
                 [detail addObject:related];
             
             detailViewController.detailArr = detail;
             detailViewController.tableView.backgroundColor = [UIColor blackColor];
             [self.navigationController pushViewController:detailViewController animated:YES];
             [detailViewController release];
             [detail release];
          //   [self removeObserver:self forKeyPath:@"artBrowse.albums"];
             [self removeObserver:self forKeyPath:@"artBrowse.relatedArtists"];
        }
        
    }
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.albBrowse = nil;
    self.artBrowse = nil;
    
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    // Return YES for supported orientations
	return YES;
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
    if (nrOfObjects > 20){
        return 20;
    }
    else{
       return nrOfObjects;     
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

    
    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[detailArr objectAtIndex:indexPath.section]];
    
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
        
        UILabel *cue = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-110, 10, 100, 20)];
        cue.text = @"Cue Song";
        cue.textAlignment = UITextAlignmentCenter;
        cue.textColor = [UIColor blackColor];
        cue.font = [UIFont fontWithName:@"GothamHTF-Medium" size:(18.0)];
        cue.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:cue];
        [cue release];
        
        NSTimeInterval interval = track.duration;
        long min = (long)interval / 60;    // divide two longs, truncates
        long sec = (long)interval % 60;    // remainder of long divide
        NSString* str = [[NSString alloc] initWithFormat:@"%02d:%02d", min, sec];
        
        UILabel *trackDuration = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-170, 5, 50, 30)];
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
    
   
    
  
    

    //cell.textLabel.text = lbl;
    // Configure the cell...
    
    [sectionArr release];
    //cell.contentView.backgroundColor = [UIColor blackColor];
   // cell.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}
- (void)cancel:(id)sender{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    main.cueController.view.hidden = NO;
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    UITableViewCell* theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    //Then you change the properties (label, text, color etc..) in your case, the background color
    theCell.contentView.backgroundColor = [UIColor whiteColor];
    
    //Deselect the cell so you can see the color change
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[detailArr objectAtIndex:indexPath.section]];
    
    if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPAlbum class]]){
        [self addObserver:self forKeyPath:@"albBrowse.tracks" options:0 context:nil];
        
        SPAlbum *album = [sectionArr objectAtIndex:indexPath.row];
        SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:album inSession:[SPSession sharedSession]];
        self.albBrowse = albumBrowse;
        
    }
    else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPTrack class]]){
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        SPTrack *track = [sectionArr objectAtIndex:indexPath.row];
        [main addSongFromSearch:track.spotifyURL];
        
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
        
        
    }
    else if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPArtist class]]){
        [self addObserver:self forKeyPath:@"artBrowse.albums" options:0 context:nil];
        [self addObserver:self forKeyPath:@"artBrowse.relatedArtists" options:0 context:nil];
        
        
        SPArtist *artist = [sectionArr objectAtIndex:indexPath.row];
        SPArtistBrowse *artistBrowse = [SPArtistBrowse browseArtist:artist inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_FULL];
        self.artBrowse = artistBrowse;
        
    }
    
    [sectionArr release];

    
}

-(void)dealloc{
    [super dealloc];
    
}

@end
