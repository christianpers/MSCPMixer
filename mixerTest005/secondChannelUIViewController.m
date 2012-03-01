//
//  secondChannelUIViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-02-27.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "secondChannelUIViewController.h"
#import <AVFoundation/AVAsset.h>
#import "AppDelegate.h"

@implementation secondChannelUIViewController

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker 
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	[self dismissModalViewControllerAnimated:YES];
	for (MPMediaItem* item in mediaItemCollection.items) {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
		NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration]; 
		//NSTimeInterval is a double
		duration_ = [dur doubleValue]; 
		
		//MPMediaItemPropertyArtist
		NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		if (nil == assetURL) {
			/**
			 * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
			 * in question is protected by DRM. (old m4p files)
			 */
			return;
		}
        NSLog(@"title: %@",title);
        [UIView animateWithDuration:1
                         animations:^{
                             //     self.tableView.alpha = 1;
                             //     self.tableView.hidden = YES;
                         }];
        
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
        [UIView commitAnimations];
        AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [main.playbackManager readAudioFilesIntoMemory:assetURL];
    //	[self exportAssetAtURL:assetURL withTitle:title withArtist:artist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissModalViewControllerAnimated:YES];
    
    [UIView animateWithDuration:1
                     animations:^{
                         //     self.tableView.alpha = 1;
                         //     self.tableView.hidden = YES;
                     }];
    
    [UIView beginAnimations : @"Display notif" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.view.frame = CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2);
   
    [UIView commitAnimations];
     //importingflag_=0; 
	
}



- (void)showMediaPicker {
	
	MPMediaPickerController* mediaPicker = [[[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic] autorelease];
	mediaPicker.delegate = self;
	[self presentModalViewController:mediaPicker animated:YES];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    [everything setGroupingType: MPMediaGroupingAlbum];
    NSArray *collections = [everything collections];
    NSLog(@"ts");
    
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    int i = 0;
    int j=0;
    
    
    MPMediaQuery *allMedia = [MPMediaQuery songsQuery];
    MPMediaPropertyPredicate *mpp1 = [MPMediaPropertyPredicate predicateWithValue:@"2"     forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonEqualTo];
    [allMedia addFilterPredicate:mpp1];
    
    NSArray *itemsFromGenericQuery = [allMedia items];
    
    NSLog(@"itemCount: %d",[itemsFromGenericQuery count]);
    
}


- (void)createChannelTwoUI{
    
       
    UIButton *addtrack = [UIButton buttonWithType:UIButtonTypeCustom];
    addtrack.frame = CGRectMake(50, self.view.bounds.size.height-100, 200, 40);// position in the parent view and set the size of the
    addtrack.backgroundColor = [UIColor blackColor];
    [addtrack setTitle:[NSString stringWithFormat:@"ADD TRACK"] forState:UIControlStateNormal];
    [addtrack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [addtrack addTarget:self 
                 action:@selector(showMediaPicker)
       forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:addtrack];
    
    
}

- (void)removeChannelTwoUI{
    
    for (UIView *view in self.view.subviews){
        if (view.tag != 10){
            [view removeFromSuperview];
            
        }
        
    }
}




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

@end
