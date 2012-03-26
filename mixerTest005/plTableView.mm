//
//  plTableView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "plTableView.h"
#import "AppDelegate.h"

@implementation plTableView
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
    if ([[dataArray objectAtIndex:0]isKindOfClass:[NSMutableArray class]]){
        return [dataArray count]; 
    }
    else{
        return 1;
    }
       
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([[dataArray objectAtIndex:section]isKindOfClass:[NSMutableArray class]]){
        return [NSString stringWithFormat:@"Playlist %d",section];
    }     
}
*/
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[dataArray objectAtIndex:section]isKindOfClass:[NSMutableArray class]]){
        return 32.0;
    }     
    else{
        return 0;
    }

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![[dataArray objectAtIndex:section]isKindOfClass:[NSMutableArray class]]){
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        customView.backgroundColor = [UIColor clearColor];
        return customView;
        
    }
    else{
        // create the parent view that will hold header Label
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 400.0, 20.0)];
	
        // create the button object
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:.8];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor blackColor];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(22.0)];
        headerLabel.frame = CGRectMake(0.0, 0.0, 400.0, 30.0);
    
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        NSString *lbl;
        if([[dataArray objectAtIndex:0] isKindOfClass:[SPAlbum class]]){
            lbl = @"Albums";
        
        }
        else if([[dataArray objectAtIndex:0] isKindOfClass:[SPTrack class]]){
            lbl = @"Tracks";
        
        }
        else if([[dataArray objectAtIndex:0] isKindOfClass:[SPArtist class]]){
            lbl = @"Artists";
        }
    
        headerLabel.text = [NSString stringWithFormat:@"Playlist %d",section]; // i.e. array element
        [customView addSubview:headerLabel];
    
        return customView;
    }
}

- (NSInteger)tableView:(UITableView *)tableView 
    numberOfRowsInSection:(NSInteger)section {  
    if ([[dataArray objectAtIndex:section]isKindOfClass:[NSMutableArray class]]){
      //  NSArray *arr = [[NSArray alloc]initWithArray:[dataArray objectAtIndex:section]];
        
       // NSInteger *ret = [arr count];
        return [[dataArray objectAtIndex:section] count];
        
        
    }
    else{
      return [dataArray count];  
    }
    
} 

- (UITableViewCell *)tableView:(UITableView *)tableView     
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = 
    [tableView 
     dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
                                       reuseIdentifier:CellIdentifier] autorelease];   
    }
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    for (UIView *v in cell.contentView.subviews){
        
        [v removeFromSuperview];
    }
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.frame.size.width-10, 30)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    [cell.contentView addSubview:lbl];
    
    if ([[dataArray objectAtIndex:section]isKindOfClass:[NSMutableArray class]]){
        NSArray *arr = [[NSArray alloc]initWithArray:[dataArray objectAtIndex:section]];
       // cell.textLabel.text = [arr objectAtIndex:row];
        lbl.text = [arr objectAtIndex:row];
        
    }
    else{
       // cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
        lbl.text = [dataArray objectAtIndex:indexPath.row];
    }
    
    
    
    [lbl release];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"song selected: %d",indexPath.row);
    
    AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main addSongToPlaybackCue:indexPath.row :indexPath.section];
   // [tableView setEditing:YES animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   /* NSLog(@"song deselected: %d",indexPath.row);
    
    mixerTest003AppDelegate *main = (mixerTest003AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [main removeSongFromPlaybackCue:indexPath.row];
    */
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}



@end
