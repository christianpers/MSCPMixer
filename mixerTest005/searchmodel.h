//
//  searchmodel.h
//  mixerTest005
//
//  Created by Christian Persson on 2012-05-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"

@interface searchmodel : NSObject {
    
    SPSearch *search;
    SPAlbumBrowse *albBrowse;
    SPArtistBrowse *artBrowse;
    SPAlbum *albumToBrowse;
    SPArtist *artistToBrowse;
    BOOL noResult;
    NSString *currSearchStr;
    BOOL arrayUpdated;
    BOOL albBrowseUpdated;
    BOOL artBrowseUpdated;
    NSMutableArray *resultArray;
    NSInteger currAlbumLimit;
    NSInteger currTrackLimit;
    NSInteger currRelArtistLimit;
    
    BOOL searchAll;
    BOOL getAlbums;
    BOOL getTracks;
    BOOL getArtists;
    
}

@property BOOL arrayUpdated;
@property BOOL albBrowseUpdated;
@property BOOL artBrowseUpdated;
@property (nonatomic, retain) SPSearch *search;
@property (nonatomic, retain) SPAlbumBrowse *albBrowse;
@property (nonatomic, retain) SPArtistBrowse *artBrowse;
@property (nonatomic, retain) NSMutableArray *resultArray;

- (void)setSearchString:(NSString *)searchquery;
- (void)doSearchOnNewThread:(SEL)selector;
- (BOOL)searchInProgress;
- (void)setAlbumToBrowse:(SPAlbum *)album;
- (void)setArtistToBrowse:(SPArtist *)artist;
- (void)setArtBrowseLimit:(NSInteger)typeToSet;
-(void)releaseSearchObject;

@end
