//
//  masterCueTableView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "masterCueTableView.h"
#import "AppDelegate.h"
#import "Shared.h"


@implementation masterCueTableView
@synthesize dataArray;


- (id) initWithFrame:(CGRect)theFrame 
        andDataArray:(NSMutableArray*)data {
    if (self = [super initWithFrame:theFrame]) {
        // This is the "Trick", set the delegates to self.
        self.dataArray = data;
        self.dataSource = self;
        self.delegate = self;
        self.allowsMultipleSelection = true;
        
    }
    
    return self;
}

#pragma mark -
#pragma mark Table View Delegates

- (NSInteger)
numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {  
    return [[Shared sharedInstance].masterCue count];
} 



- (UITableViewCell *)tableView:(UITableView *)tableView     
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString* imagePathPlay = [[NSBundle mainBundle] pathForResource:@"playNew" ofType:@"png"];
    UIImage *playImg = [UIImage imageWithContentsOfFile:imagePathPlay];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = 
    [tableView 
     dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:CellIdentifier] autorelease];   
    }
    
    for (UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
   
    
    
    NSURL *url = [[Shared sharedInstance].masterCue objectAtIndex:indexPath.row];
    
    SPTrack *track = [[SPSession sharedSession] trackForURL:url];
    NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
    NSString *title = track.name;
    NSString *finalStr = [NSString stringWithFormat:@"%@ - %@",artists,title];
    
   // cell.textLabel.text = finalStr;
    
    cell.contentView.backgroundColor = [UIColor clearColor];
  //  cell.textLabel.textColor = [UIColor whiteColor];
  //  cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if (indexPath.row == [Shared sharedInstance].currTrackCueNum && main.playbackManager.isPlaying){
        UIImageView *playView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 14, 12, 12)];
        playView.image = playImg;
        [cell.contentView addSubview:playView];
        [playView release];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(25, 5, self.frame.size.width-10, 30)];
        lbl.text = finalStr;
        lbl.textColor = [UIColor whiteColor];
        
        lbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lbl];
        [lbl release];
        
    }else{
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width-10, 30)];
        lbl.text = finalStr;
        lbl.textColor = [UIColor whiteColor];
        
        lbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:lbl];
        [lbl release];
        
    }
        //cell.imageView.image = NULL;
    
    
    return cell;    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"song selected: %d",indexPath.row);
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSURL *trackURL = [[Shared sharedInstance].masterCue objectAtIndex:indexPath.row];
    [Shared sharedInstance].currTrackCueNum = indexPath.row;
    SPTrack *track = [[SPSession sharedSession] trackForURL:trackURL];
    
    [main handlecuetrackSelect:track];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"song deselected: %d",indexPath.row);
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[Shared sharedInstance].masterCue removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView 
canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)table
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{    // How to rearrange stuff if you're backed by an NSMutableArray:
    NSURL *cue = [[Shared sharedInstance].masterCue objectAtIndex: sourceIndexPath.row];
    [cue retain];  // Let it survive being removed from the array.
    NSLog(@"from row:%d",sourceIndexPath.row);
    NSLog(@"to row:%d",destinationIndexPath.row);
    [[Shared sharedInstance].masterCue removeObjectAtIndex: sourceIndexPath.row];
    [[Shared sharedInstance].masterCue insertObject: cue  atIndex: destinationIndexPath.row];
    int currpltrackIndex = [Shared sharedInstance].currTrackCueNum;
    if (sourceIndexPath.row == currpltrackIndex){
        
        [Shared sharedInstance].currTrackCueNum = destinationIndexPath.row;
        
    }else{
        
        if (destinationIndexPath.row < currpltrackIndex){
            [Shared sharedInstance].currTrackCueNum += 1;
            
        } 
        
    }
    
    [cue release];
    [table reloadData];
    
} // moveRowAtIndexPath



@end

