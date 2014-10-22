//
//  JDataStore.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JDataStore.h"
#import <AFNetworking/AFNetworking.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "JAlbum.h"
#import "JTrack.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation JDataStore

#pragma mark - Convert track duration from milliseconds

+ (NSString *)convertTrackDurationFromMilliseconds:(NSString *)millisecondsValue {
    float seconds = [millisecondsValue floatValue] / 1000.0;
    float minutes = seconds / 60.0;
    
    // TODO: fix up the returned string formatting, cause it doesn't look right
    return [NSString stringWithFormat:@"%.f:%.f", minutes, seconds];
}

#pragma mark - Fetch album details method

+ (void)fetchAlbumDetailsForAlbumId:(NSString *)albumIdToFetch {
    DDLogVerbose(@"dataStore: fetching data for album ID: %@", albumIdToFetch);
    
    // Init URL to fetch data from
    NSString *dataUrlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@", albumIdToFetch];
    NSURL *dataUrl = [NSURL URLWithString:dataUrlString];
    NSURLRequest *dataUrlRequest = [NSURLRequest requestWithURL:dataUrl];
    
    // Init AFNetworking
    AFHTTPRequestOperation *dataFetchOperation = [[AFHTTPRequestOperation alloc] initWithRequest:dataUrlRequest];
    dataFetchOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [dataFetchOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Init array to hold track info for album
        NSArray *tracksArray = [[responseObject objectForKey:@"tracks"] objectForKey:@"items"];
        
        // Init album name string
        NSString *albumName = [responseObject objectForKey:@"name"];
        
        DDLogVerbose(@"dataStore: %d tracks for album: %@", [tracksArray count], albumName);
        
        // Init dictionary to hold track info
        NSDictionary *trackDict;
        
        // Init array to hold track info
        NSMutableArray *allTracksArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *track in tracksArray) {
            //DDLogVerbose(@"TRACK: %@", [track class]);
            NSString *trackName = [track objectForKey:@"name"];
            NSString *trackId = [track objectForKey:@"id"];
            NSString *trackNumber = [track objectForKey:@"track_number"];
            NSString *trackDuration = [track objectForKey:@"duration_ms"];
            NSString *trackPreviewUrl = [track objectForKey:@"preview_url"];
            // Use method parameter for the trackAlbumId
            NSString *trackAlbumId = albumIdToFetch;
            
            trackDict = @{ @"trackName": trackName, @"trackId": trackId, @"trackNumber" : trackNumber, @"trackDuration": trackDuration, @"trackPreviewUrl": trackPreviewUrl, @"trackAlbumId": trackAlbumId };
            
            // Init JTrack object
            JTrack *track = [[JTrack alloc] initWithName:trackName
                                                   andId:trackId
                                             andDuration:trackDuration
                                               andNumber:trackNumber
                                           andPreviewUrl:trackPreviewUrl
                                              andAlbumId:trackAlbumId];
            
            DDLogVerbose(@"dataStore: init track: %@; duration: %@", track.trackName, track.trackDuration);
            
            // Add track to tracksArray
            [allTracksArray addObject:track];
        }
        
        // Init album release date string
        NSString *albumReleaseDate = [responseObject objectForKey:@"release_date"];
        
        DDLogVerbose(@"Album release date: %@", albumReleaseDate);
        
        // Init album ID string
        NSString *albumId = [responseObject objectForKey:@"id"];
        
        // Init album track count string
        // TODO: review this, maybe don't store as a string
        NSString *albumTrackCount = [NSString stringWithFormat:@"%d", [tracksArray count]];
        
        // Init album image URL string
        NSString *albumImageUrl;
        
        // Get album image URL (if sized 300x300)
        for (NSDictionary *albumImage in [responseObject objectForKey:@"images"]) {
            if ([[albumImage objectForKey:@"height"] isEqualToNumber:@300]) {
                albumImageUrl = [albumImage objectForKey:@"url"];
                
                DDLogVerbose(@"Album image URL: %@", albumImageUrl);
            }
        }
        
        // Init JAlbum object
        JAlbum *album = [[JAlbum alloc] initWithName:albumName
                                               andId:albumId
                                      andReleaseDate:albumReleaseDate
                                       andTrackCount:albumTrackCount
                                         andImageUrl:albumImageUrl];
        
        // Persist album to NSUserDefaults
        [self persistAlbum:album andTracks:allTracksArray];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"dataStore: error fetching data for album ID: %@, Reason: %@", albumIdToFetch, [error localizedDescription]);
    }];
    
    // Start the data fetch operation
    [dataFetchOperation start];
}

#pragma mark - Clear previously fetched album results method

+ (void)clearAlbumCache {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JAlbumArray"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JAlbumIdArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DDLogVerbose(@"dataStore: cleared previously fetched album results from NSUserDefaults");
}

#pragma mark - Persist fetched album to NSUserDefaults method

+ (void)persistAlbum:(JAlbum *)albumToPersist andTracks:(NSArray *)tracksArray {
    NSMutableArray *cachedResults = [NSMutableArray arrayWithArray:[self returnFetchedAlbums]];
    
    if ([self checkIfAlbumIsByJore:albumToPersist]) {
        [cachedResults addObject:albumToPersist];
    }
    
    NSData *albumArrayToSave = [NSKeyedArchiver archivedDataWithRootObject:cachedResults];
    [[NSUserDefaults standardUserDefaults] setObject:albumArrayToSave forKey:@"JAlbumArray"];
    // Persist tracks using album ID as the unique key
    NSData *trackArrayToSave = [NSKeyedArchiver archivedDataWithRootObject:tracksArray];
    NSString *keyForTracks = [NSString stringWithFormat:@"%@-tracks", albumToPersist.albumId];
    [[NSUserDefaults standardUserDefaults] setObject:trackArrayToSave forKey:keyForTracks];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DDLogVerbose(@"dataStore: persisted album to NSUserDefaults: %@; total: %d", albumToPersist.albumName, [cachedResults count]);
    
    [self postNotificationThatDataFetchDidHappen];
}

#pragma mark - Return tracks for album ID method

+ (NSArray *)returnFetchedTracksForAlbumId:(NSString *)albumId {
    NSString *keyForTracks = [NSString stringWithFormat:@"%@-tracks", albumId];
    NSData *cachedTrackData = [[NSUserDefaults standardUserDefaults] objectForKey:keyForTracks];
    NSArray *arrayToSort = [NSKeyedUnarchiver unarchiveObjectWithData:cachedTrackData];
    
    // Init sort descriptor (sorted by track number)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    
    DDLogVerbose(@"dataStore: return fetched tracks count: %d", [sortedArray count]);
    
    return sortedArray;
}

#pragma mark - Check for albums that aren't by Jore method

+ (BOOL)checkIfAlbumIsByJore:(JAlbum *)albumToCheck {
    // NOTE:
    // There is one album returned by the Spotify Web API that isn't actually by Jore (our chosen artist for this app).
    // This one album has a release date of 2004, and since Jore didn't release any albums in 2004, we'll use this method
    // to check if the release date for a given album is 2004 and return a BOOL accordingly.
    // It's a little hacky, I know ..
    if ([albumToCheck.albumReleaseDate isEqualToString:@"2004"]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Fetch album data method

+ (void)fetchAlbumData {
    DDLogVerbose(@"dataStore: fetching album data ..");
    
    // Clear any previously fetched album results
    [self clearAlbumCache];
    
    // Init Spotify artist ID string
    NSString *spotifyArtistId = @"0vIqwp5PW929D9dZcB0wtc";
    
    // Init URL to fetch data from
    NSString *dataUrlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/artists/%@/albums", spotifyArtistId];
    NSURL *dataUrl = [NSURL URLWithString:dataUrlString];
    NSURLRequest *dataUrlRequest = [NSURLRequest requestWithURL:dataUrl];
    
    // Init AFNetworking
    AFHTTPRequestOperation *dataFetchOperation = [[AFHTTPRequestOperation alloc] initWithRequest:dataUrlRequest];
    dataFetchOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [dataFetchOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Init array to hold album IDs
        NSMutableArray *albumIdArray = [[NSMutableArray alloc] init];
        
        // Loop over fetched data to get album IDs and add to albumIdArray
        for (NSDictionary *item in [responseObject objectForKey:@"items"]) {
            [albumIdArray addObject:[item objectForKey:@"id"]];
        }
        
        // Save albumIdArray to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:albumIdArray forKey:@"JAlbumIdArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        DDLogVerbose(@"dataStore: saved fetched album IDs to NSUserDefaults");
        
        // Call did finish fetching album IDs method
        [self didFinishFetchingAlbumIds];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"dataStore: error fetching album data: %@", [error localizedDescription]);
    }];
    
    // Start the data fetch operation
    [dataFetchOperation start];
}

#pragma mark - Did finish fetching album IDs method

+ (void)didFinishFetchingAlbumIds {
    NSArray *albumIds = [NSArray arrayWithArray:[self returnFetchedAlbumIds]];
    
    // Fetch album details for all album IDs
    for (NSString *albumId in albumIds) {
        [self fetchAlbumDetailsForAlbumId:albumId];
    }
}

#pragma mark - Return fetched album IDs method

+ (NSArray *)returnFetchedAlbumIds {
    NSArray *arrayToReturn = [[NSUserDefaults standardUserDefaults] arrayForKey:@"JAlbumIdArray"];
    
    DDLogVerbose(@"dataStore: return fetched album IDs count: %d", [arrayToReturn count]);
    
    return arrayToReturn;
}

#pragma mark - Return fetched album info method

+ (NSArray *)returnFetchedAlbums {
    NSData *cachedAlbumData = [[NSUserDefaults standardUserDefaults] objectForKey:@"JAlbumArray"];
    NSArray *arrayToSort = [NSKeyedUnarchiver unarchiveObjectWithData:cachedAlbumData];
    
    // Init sort descriptor (latest albums at the top, sorted by release date)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"albumReleaseDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [arrayToSort sortedArrayUsingDescriptors:sortDescriptors];
    
    DDLogVerbose(@"dataStore: return fetched albums count: %d", [sortedArray count]);
    
    return sortedArray;
}

#pragma mark - Post NSNotification that data fetch did happen method

+ (void)postNotificationThatDataFetchDidHappen
{
    DDLogVerbose(@"dataStore: posting notification that data fetch did happen");
    
    // Post data fetch did happen NSNotification
    NSString *notificationName = @"JDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

#pragma mark - Init method

+ (instancetype)sharedStore {
    static JDataStore *_sharedStore = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedStore = [[JDataStore alloc] init];
    });
    
    return _sharedStore;
}

@end
