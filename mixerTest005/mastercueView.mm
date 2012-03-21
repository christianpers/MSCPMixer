//
//  mastercueView.m
//  mixerTest003
//
//  Created by Christian Persson on 2012-01-24.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mastercueView.h"
#import "CocoaLibSpotify.h"
#import "Shared.h"
#import "AppDelegate.h"

@implementation mastercueView

@synthesize tableView;
@synthesize masterCuePan;
@synthesize editbtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:.8];
        
        UITapGestureRecognizer *doubleTap = 
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deactiveMasterCueEdit)];
        [doubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTap];
        [doubleTap release];
        
        masterCuePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
        [masterCuePan setMaximumNumberOfTouches:2];
        //  [panGesture setDelegate:playlistView];
        [self addGestureRecognizer:masterCuePan];
        
        UILabel *masterCueLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0, 5, 400, 50) ];
        masterCueLabel.textAlignment =  UITextAlignmentCenter;
        masterCueLabel.textColor = [UIColor whiteColor];
        masterCueLabel.backgroundColor = [UIColor clearColor];
        masterCueLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(26.0)];
        masterCueLabel.userInteractionEnabled = YES;
        [self addSubview:masterCueLabel];
        
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
        
        [self addSubview:self.tableView];
        
        self.tableView.hidden = YES;
        
        UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(320, 20, 60, 30)];
        edit.backgroundColor = [UIColor whiteColor];
        [edit setTitle:[NSString stringWithFormat:@"edit"] forState:UIControlStateNormal];
        [edit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [edit addTarget:self 
                    action:@selector(editMasterCueList:)
          forControlEvents:UIControlEventTouchDown];
        
        self.editbtn = edit;
        [self addSubview:self.editbtn];
        self.editbtn.hidden = YES;
        [edit release];
        
        
        
        [songCue release];
        [masterCueLabel release];
      
    }
    return self;
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
        
        CGRect bounds = self.bounds;
        bounds.size.height -= 400;
        self.bounds = bounds;
        
        self.editbtn.hidden = YES;
        
        [UIView commitAnimations];
        
        
        
    }
    else{
        [UIView beginAnimations : @"Display notif" context:nil];
        [UIView setAnimationDuration:1];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        CGRect bounds = self.bounds;
        bounds.size.height += 400;
        self.bounds = bounds;
        
        self.editbtn.hidden = NO;
        
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
    if (!self.tableView.isEditing){
        [self.tableView setEditing: YES animated: YES];
        [self removeGestureRecognizer:masterCuePan];
        
    }
    else{
        [self.tableView setEditing: NO animated: YES];
        [self addGestureRecognizer:masterCuePan];
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



-(void)dealloc{
    
    [masterCuePan release];
    [tableView release];
    [editbtn release];
    [super dealloc];
}

@end
