//
//  macroDetailTableViewController.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-02-11.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "macroDetailTableViewController.h"
#import "AppDelegate.h"

@implementation macroDetailTableViewController

@synthesize detailArr;

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

- (void)viewDidLoad
{
    
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

- (void)viewDidUnload
{
    
  
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.detailArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.detailArr objectAtIndex:section]count];
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
    headerLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(28.0)];
    headerLabel.frame = CGRectMake(10.0, 0.0, size.width, 50.0);
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[detailArr objectAtIndex:section]];
    
    NSString *lbl;
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
    
    return customView;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *lbl;
    
    //    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[self.detailArr objectAtIndex:indexPath.section]];
    NSArray *sectionArr = [self.detailArr objectAtIndex:indexPath.section];
    int row = indexPath.row;
    if([[sectionArr objectAtIndex:0] isKindOfClass:[SPAlbum class]]){
        SPAlbum *album = [sectionArr objectAtIndex:row];
        NSString *art = album.artist.name;
        lbl = [NSString stringWithFormat:@"%@ - %@", art, album.name];
        
    }
    else if([[sectionArr objectAtIndex:0] isKindOfClass:[SPTrack class]]){
        
        SPTrack *track = [sectionArr objectAtIndex:row];
        NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
        lbl = [NSString stringWithFormat:@"%@ - %@",artists,track.name];
        
    }
    
    if ([lbl length]== 0){
        NSLog(@"fuck");
    }
    
    cell.textLabel.text = lbl;
    // Configure the cell...
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
    
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
    UITableViewCell* theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    //Then you change the properties (label, text, color etc..) in your case, the background color
    theCell.contentView.backgroundColor = [UIColor orangeColor];
    
    //Deselect the cell so you can see the color change
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *sectionArr = [[NSMutableArray alloc]initWithArray:[detailArr objectAtIndex:indexPath.section]];
    
    if([[sectionArr objectAtIndex:indexPath.row] isKindOfClass:[SPTrack class]]){
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        SPTrack *track = [sectionArr objectAtIndex:indexPath.row];
        [main addSongFromSearch:track.spotifyURL];
    }
    
    [sectionArr release];
}

- (void)cancel:(id)sender{
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    main.playbackLabel.hidden = NO;
    main.playlistLabel.hidden = NO;
    main.searchLabel.hidden = NO;
    main.cueView.hidden = NO;
    
}

@end
