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

@synthesize arrayUpdated, albBrowseUpdated, artBrowseUpdated;
@synthesize search;
@synthesize resultArray;
@synthesize albBrowse, artBrowse;

- (void)setSearchString:(NSString *)searchquery{
    
    currSearchStr = searchquery;
   // [self doSearchOnNewThread];
    
}

- (void)setAlbumToBrowse:(SPAlbum *)album{
    
    albumToBrowse = album;
}

- (void)setArtistToBrowse:(SPArtist *)artist{
    
    artistToBrowse = artist;
    currAlbumLimit = 25;
    currTrackLimit = 25;
    currRelArtistLimit = 25;
}

- (void)setArtBrowseLimit:(NSInteger)typeToSet{
    
    switch (typeToSet) {
        case 0:
            currAlbumLimit += 25;
            break;
        
        case 1:
            currTrackLimit += 25;
            break;
        
        case 2:
            currRelArtistLimit += 25;
            break;
            
        default:
            break;
    }
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

- (void)browseArtist{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SPArtistBrowse *artistBrowse = [SPArtistBrowse browseArtist:artistToBrowse inSession:[SPSession sharedSession] type:SP_ARTISTBROWSE_FULL];
    self.artBrowse = artistBrowse;
    
    [self addObserver:self forKeyPath:@"self.artBrowse.albums" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.artBrowse.tracks" options:0 context:nil];
    [self addObserver:self forKeyPath:@"self.artBrowse.relatedArtists" options:0 context:nil];
    
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
    else if([keyPath isEqualToString:@"self.artBrowse.tracks"]){
        SPArtistBrowse *artistCallback = self.artBrowse;
        if([artistCallback.tracks count] > 0){
            
            if (([artistCallback.relatedArtists count] > 0 || artistCallback.relatedArtists != nil) && ([artistCallback.albums count] > 0 || artistCallback.albums != nil)){
                [self setupArtistBrowseResults:NO];
            }
        }
    }
    else if([keyPath isEqualToString:@"self.artBrowse.albums"]){
        SPArtistBrowse *artistCallback = self.artBrowse;
        if([artistCallback.albums count] > 0){
            
            if (([artistCallback.relatedArtists count] > 0 || artistCallback.relatedArtists != nil) && ([artistCallback.tracks count] > 0 || artistCallback.tracks != nil)){
                [self setupArtistBrowseResults:NO];
            }
        }
    }
    else if([keyPath isEqualToString:@"self.artBrowse.relatedArtists"]){
        SPArtistBrowse *artistCallback = self.artBrowse;
        if([artistCallback.relatedArtists count] > 0){
            
            if (([artistCallback.tracks count] > 0 || artistCallback.tracks != nil) && ([artistCallback.albums count] > 0 || artistCallback.albums != nil)){
                [self setupArtistBrowseResults:NO];
            }
        }
    }
}

- (void)getmoreArtistBrowseResults{
    
    [self setupArtistBrowseResults:YES];
    
}


-(void)setupArtistBrowseResults:(BOOL)updateArray{
    
    SPArtistBrowse *currBrowse = self.artBrowse;
    if (!updateArray){
        [self removeObserver:self forKeyPath:@"self.artBrowse.tracks"];
        [self removeObserver:self forKeyPath:@"self.artBrowse.albums"];
        [self removeObserver:self forKeyPath:@"self.artBrowse.relatedArtists"];
        
    }
    NSMutableArray *artbrowseArray = [NSMutableArray array];
    
    
    if ([currBrowse.albums count] > 0){
        NSInteger i = 0;
        NSMutableArray *albums = [NSMutableArray array];
        if ([currBrowse.albums count]>=currAlbumLimit){
            while (i<currAlbumLimit){
                [albums addObject:[currBrowse.albums objectAtIndex:i]];
                i++;
            }
            
        }else {
            albums = [NSMutableArray arrayWithArray:currBrowse.albums];
        }
        
        [artbrowseArray addObject:albums];
    }
    if ([currBrowse.tracks count] > 0){
        NSInteger i = 0;
        NSMutableArray *tracks = [NSMutableArray array];
        if ([currBrowse.tracks count]>=currTrackLimit){
            while (i<currTrackLimit){
                [tracks addObject:[currBrowse.tracks objectAtIndex:i]];
                i++;
            }
            
        }else {
            tracks = [NSMutableArray arrayWithArray:currBrowse.tracks];
        }
        
        [artbrowseArray addObject:tracks];
    }
    if ([currBrowse.relatedArtists count] > 0){
        NSInteger i = 0;
        NSMutableArray *relatedArtists = [NSMutableArray array];
        if ([currBrowse.relatedArtists count]>=currRelArtistLimit){
            while (i<currRelArtistLimit){
                [relatedArtists addObject:[currBrowse.relatedArtists objectAtIndex:i]];
                i++;
            }
            
        }else {
            relatedArtists = [NSMutableArray arrayWithArray:currBrowse.relatedArtists];
        }
        
        [artbrowseArray addObject:relatedArtists];
    }
    if (!updateArray){
        [self performSelectorOnMainThread:@selector(returnArtistBrowseResults:) withObject:artbrowseArray waitUntilDone:NO];
    }else {
        [self performSelectorOnMainThread:@selector(updateArtistBrowseResults:) withObject:artbrowseArray waitUntilDone:NO];
    }
    
}

-(void)updateArtistBrowseResults:(NSMutableArray *)arr{
    resultArray = [NSMutableArray arrayWithArray:arr];
    self.arrayUpdated = YES;
    
}

-(void)returnArtistBrowseResults:(NSMutableArray *)arr{
    
    resultArray = [NSMutableArray arrayWithArray:arr];
    self.artBrowseUpdated = YES;
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

-(void)releaseSearchObject{
    
    [search release];
}

- (void)dealloc{
    
    [search release];
    [super dealloc];
}


@end
