//
//  searchmodel.m
//  mixerTest005
//
//  Created by Christian Persson on 2012-05-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "searchmodel.h"
#import "AppDelegate.h"

@implementation searchmodel

@synthesize arrayUpdated, albBrowseUpdated;
@synthesize search;
@synthesize resultArray;
@synthesize albBrowse;

- (void)setSearchString:(NSString *)searchquery{
    
    currSearchStr = searchquery;
   // [self doSearchOnNewThread];
    
}

- (void)setAlbumToBrowse:(SPAlbum *)album{
    
    albumToBrowse = album;
}

- (void) doSearchOnNewThread:(SEL)selector {
	[NSThread detachNewThreadSelector:selector toTarget:self withObject:nil];
}

- (void) startNewSearch {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    getAlbums = YES;
    getArtists = YES;
    getTracks = YES;
 //   search = [SPSearch searchWithSearchQuery:currSearchStr inSession:[SPSession sharedSession]];
    search = [[SPSearch alloc] initWithSearchQuery:currSearchStr pageSize:25 inSession:[SPSession sharedSession]];
    
    searchAll = YES;
    
    [self addObserver:self forKeyPath:@"self.search.tracks" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.search.albums" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.search.artists" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self addObserver:self forKeyPath:@"self.search.searchInProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    
	[pool release];
}

- (void)getMoreAlbums{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL moreData = NO;
    getAlbums = YES;
    [self addObserver:self forKeyPath:@"self.search.albums" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.search.searchInProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    moreData = search.addAlbumPage;
    [pool release];
}

- (void)getMoreTracks{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL moreData = NO;
    getTracks = YES;
    [self addObserver:self forKeyPath:@"self.search.tracks" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.search.searchInProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    moreData = search.addTrackPage;
    [pool release];
}
- (void)getMoreArtists{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL moreData = NO;
    getArtists = YES;
    [self addObserver:self forKeyPath:@"self.search.artists" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"self.search.searchInProgress" options:NSKeyValueObservingOptionNew context:NULL];
    
    
    moreData = search.addArtistPage;
    [pool release];
}

- (void)browseAlbum{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SPAlbumBrowse *albumBrowse = [SPAlbumBrowse browseAlbum:albumToBrowse inSession:[SPSession sharedSession]];
    self.albBrowse = albumBrowse;
    
    [self addObserver:self forKeyPath:@"self.albBrowse.tracks" options:0 context:nil];
    
    [pool release];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.search.tracks"]) {
        SPSearch *searchCallback = search;
        noResult = YES;
        
        if([searchCallback.tracks count] > 0){
            
            if (searchAll){
                if (([searchCallback.albums count] > 0 || searchCallback.hasExhaustedAlbumResults) && ([searchCallback.artists count] > 0 || searchCallback.hasExhaustedArtistResults)){
                    
                    [self createSearchList:searchCallback];
                    noResult = NO;
                }
            }else {
                [self createSearchList:searchCallback];
                noResult = NO;
            }
        }
    }
    else if ([keyPath isEqualToString:@"self.search.albums"]) {
        SPSearch *searchCallback = search;
        noResult = YES;
        
        if([searchCallback.albums count] > 0){
            
            if (searchAll){
                if (([searchCallback.artists count] > 0 || searchCallback.hasExhaustedArtistResults) && ([searchCallback.tracks count] > 0 || searchCallback.hasExhaustedTrackResults)){
                    
                    [self createSearchList:searchCallback];
                    noResult = NO;
                }
            }else {
                [self createSearchList:searchCallback];
                noResult = NO;
            }
            
        }
    } 
    else if ([keyPath isEqualToString:@"self.search.artists"]) {
        SPSearch *searchCallback = search;
        noResult = YES;
        
        if([searchCallback.artists count] > 0){
            
            if (searchAll){
                if (([searchCallback.albums count] > 0 || searchCallback.hasExhaustedAlbumResults) && ([searchCallback.tracks count] > 0 || searchCallback.hasExhaustedTrackResults)){
                 
                    [self createSearchList:searchCallback];
                    noResult = NO;
                }
            }else {
                [self createSearchList:searchCallback];
                noResult = NO;
            }
        }
    } 
    else if([keyPath isEqualToString:@"self.search.searchInProgress"]){
        SPSearch *searchCallback = search;
        
        if (noResult && !searchCallback.searchInProgress){
            AppDelegate *main = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            NSLog(@"no matches");
            [main.mainViewController.searchController showNoResult];
        }
        
    }
    else if([keyPath isEqualToString:@"self.albBrowse.tracks"]){
        SPAlbumBrowse *albumCallback = self.albBrowse;
        if([albumCallback.tracks count] > 0){
            [self removeObserver:self forKeyPath:@"self.albBrowse.tracks"];
            [self performSelectorOnMainThread:@selector(returnBrowseResults:) withObject:albumCallback.tracks waitUntilDone:NO];
        }
    }
}

-(void)returnBrowseResults:(NSArray *)arr{
    
    
    resultArray = [NSMutableArray arrayWithArray:arr];
    self.albBrowseUpdated = YES;    
}

-(void)createSearchList:(SPSearch *)returnObj{
    
    NSMutableArray *albumarr;
    NSMutableArray *trackarr;
    NSMutableArray *artistsarr;
    NSMutableArray *arr = [NSMutableArray array];
    
    if (returnObj.albums > 0 && getAlbums){
        [self removeObserver:self forKeyPath:@"self.search.albums"];
        
    }
    if (returnObj.tracks > 0 && getTracks){
        [self removeObserver:self forKeyPath:@"self.search.tracks"];
        
    }
    if (returnObj.artists > 0 && getArtists){
        [self removeObserver:self forKeyPath:@"self.search.artists"];
        
    }
    artistsarr = [NSMutableArray arrayWithArray:returnObj.artists];
    trackarr = [NSMutableArray arrayWithArray:returnObj.tracks];
    albumarr = [NSMutableArray arrayWithArray:returnObj.albums];
    
    [arr addObject:albumarr];
    [arr addObject:trackarr];
    [arr addObject:artistsarr];
    
    if ([arr count] > 0){
        [self removeObserver:self forKeyPath:@"self.search.searchInProgress"];
        searchAll = NO;
        [self performSelectorOnMainThread:@selector(returnArray:) withObject:arr waitUntilDone:NO];
    }
}

-(void)returnArray:(NSMutableArray *)arr{
    
    getAlbums = NO;
    getTracks = NO;
    getArtists = NO;
    resultArray = [NSMutableArray arrayWithArray:arr];
    self.arrayUpdated = YES;
    
    
}

-(BOOL)searchInProgress{
    
    return search.searchInProgress;
}

- (void)dealloc{
    
    [search release];
    [super dealloc];
}


@end
