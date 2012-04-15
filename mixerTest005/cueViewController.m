//
//  cueViewController.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-03-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cueViewController.h"
#import "Shared.h"
#import "AppDelegate.h"

@interface cueViewController ()

@end

@implementation cueViewController
@synthesize tableView;
@synthesize masterCuePan;
@synthesize editbtn, clearbtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize winSize = window.frame.size;
    UIView *cueView = [[UIView alloc]initWithFrame:CGRectMake((winSize.width/2-600/2), winSize.height-200, 400, 60)];
    self.view = cueView;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:.8];
    
    masterCuePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [masterCuePan setMaximumNumberOfTouches:2];
    //  [panGesture setDelegate:playlistView];
    [self.view addGestureRecognizer:masterCuePan];
    
    UILabel *masterCueLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 5, 400, 50) ];
    masterCueLabel.textAlignment =  UITextAlignmentCenter;
    masterCueLabel.textColor = [UIColor whiteColor];
    masterCueLabel.backgroundColor = [UIColor clearColor];
    masterCueLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
    masterCueLabel.userInteractionEnabled = YES;
    [self.view addSubview:masterCueLabel];
    
    UITapGestureRecognizer *touch = 
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMasterCueView)];
    [touch setNumberOfTapsRequired:1];
    [masterCueLabel addGestureRecognizer:touch];
    [touch release];
    
    masterCueLabel.text = @"Cue (channel 1)";
    
    NSMutableArray *songCue = [[NSMutableArray alloc]init];
    
    for (NSURL *url in [Shared sharedInstance].masterCue){
        SPTrack *track = [[SPSession sharedSession] trackForURL:url];
        NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
        NSString *title = track.name;
        NSString *finalStr = [NSString stringWithFormat:@"%@ - %@",artists,title];
        
        [songCue addObject:finalStr];
    }
    
    self.tableView = [[masterCueTableView alloc]initWithFrame:CGRectMake(30, 80, 340, 300) andDataArray:songCue];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tag = 20;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.hidden = YES;
    
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(320, 20, 60, 30)];
    edit.backgroundColor = [UIColor whiteColor];
    [edit setTitle:[NSString stringWithFormat:@"Edit"] forState:UIControlStateNormal];
    [edit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [edit addTarget:self 
             action:@selector(editMasterCueList:)
   forControlEvents:UIControlEventTouchDown];
    edit.layer.cornerRadius = 5;
    self.editbtn = edit;
    [self.view addSubview:self.editbtn];
    self.editbtn.hidden = YES;
    [edit release];
    
    UIButton *removeBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 60, 30)];
    removeBtn.backgroundColor = [UIColor whiteColor];
    [removeBtn setTitle:[NSString stringWithFormat:@"Clear"] forState:UIControlStateNormal];
    [removeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [removeBtn addTarget:self action:@selector(removeCueChOne:) forControlEvents:UIControlEventTouchDown];
    removeBtn.layer.cornerRadius = 5;
    self.clearbtn = removeBtn;
    [self.view addSubview:self.clearbtn];
    self.clearbtn.hidden = YES;
    
    [removeBtn release];
    
    [songCue release];
    [masterCueLabel release];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [masterCuePan release];
    self.tableView = nil;
    [tableView release];
    [editbtn release];
    [clearbtn release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)toggleMasterCueView{
    
    if(!self.tableView.hidden){
        
        [UIView animateWithDuration:1
                         animations:^{
                             self.tableView.alpha = 1;
                             self.tableView.hidden = YES;
                         }];
        
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect viewbounds = self.view.bounds;
        viewbounds.size.height -= 400;
        self.view.bounds = viewbounds;
        
        self.editbtn.hidden = YES;
        self.clearbtn.hidden = YES;
        
        [UIView commitAnimations];
        
        
        
    }
    else{
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect viewbounds = self.view.bounds;
        viewbounds.size.height += 400;
        self.view.bounds = viewbounds;
        
        self.editbtn.hidden = NO;
        self.clearbtn.hidden = NO;
        
        [UIView commitAnimations];
        
        NSMutableArray *songCue = [[NSMutableArray alloc]init];
        
        for (NSURL *url in [Shared sharedInstance].masterCue){
            SPTrack *track = [[SPSession sharedSession] trackForURL:url];
            NSString *artists = [[track.artists valueForKey:@"name"] componentsJoinedByString:@","];
            NSString *title = track.name;
            NSString *finalStr = [NSString stringWithFormat:@"%@ - %@",artists,title];
            
            [songCue addObject:finalStr];
        }
        
        
        
        [self.tableView reloadData];
        
        self.tableView.alpha = 0;
        self.tableView.hidden = NO;
        
        [UIView animateWithDuration:1.2
                         animations:^{
                             self.tableView.alpha = 1;
                         }];
        
        [songCue release];
    }     
}

- (void)editMasterCueList:(id)sender
{
    UIButton *edit = (UIButton *)sender;
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [edit.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    if (!self.tableView.isEditing){
        [self.tableView setEditing: YES animated: YES];
        [self.view removeGestureRecognizer:masterCuePan];
        
    }
    else{
        [self.tableView setEditing: NO animated: YES];
        [self.view addGestureRecognizer:masterCuePan];
    }
}

- (void)removeCueChOne:(id)sender{
    UIButton *clear = (UIButton *)sender;
    
    CABasicAnimation *fadeAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"]; 
    fadeAnimation.fromValue=[NSNumber numberWithFloat:1];
    fadeAnimation.toValue=[NSNumber numberWithFloat:.6];   
    fadeAnimation.duration=.1;
    fadeAnimation.repeatCount=0;
    // fadeAnimation.autoreverses=YES;
    [clear.layer addAnimation:fadeAnimation forKey:@"fadeinout"];
    
    if ([SPSession sharedSession].isPlaying){
        NSURL *trackurl = [[Shared sharedInstance].masterCue objectAtIndex:[Shared sharedInstance].currTrackCueNum];
        
        [[Shared sharedInstance].masterCue removeAllObjects];
        
        [[Shared sharedInstance].masterCue addObject:trackurl];
        
        [self.tableView reloadData];
        
        [Shared sharedInstance].currTrackCueNum = 0;
        
    }else{
        
        [[Shared sharedInstance].masterCue removeAllObjects];
        [self.tableView reloadData];
        
    }
   
}


- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        
        
    }
}



@end
