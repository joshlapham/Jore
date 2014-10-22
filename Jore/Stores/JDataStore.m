//
//  JDataStore.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JDataStore.h"
#import <AFNetworking/AFNetworking.h>
#import <CocoaLumberjack.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation JDataStore

#pragma mark - Fetch album data method

+ (void)fetchAlbumData {
    DDLogVerbose(@"dataStore: fetching album data ..");
    
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
        // Init dictionary to hold album info
        NSDictionary *albumInfo;
        
        // Init array to hold albumInfo dicts
        NSMutableArray *albumInfoArray = [[NSMutableArray alloc] init];
        
        // Loop over fetched data to get album names and add to albumNames array
        for (NSDictionary *item in [responseObject objectForKey:@"items"]) {
            NSString *albumName = [item objectForKey:@"name"];
            DDLogVerbose(@"Album name: %@", albumName);
            
            NSString *albumImageUrl;
            
            // Get album image URL (if sized 300x300)
            for (NSDictionary *albumImage in [item objectForKey:@"images"]) {
                if ([[albumImage objectForKey:@"height"] isEqualToNumber:@300]) {
                    albumImageUrl = [albumImage objectForKey:@"url"];
                    
                    DDLogVerbose(@"Album image URL: %@", albumImageUrl);
                }
            }
            
            // Set albumInfo dict
            albumInfo = @{ @"albumName" : albumName, @"albumImageUrl" : albumImageUrl };
            
            // Add albumInfo dict to albumInfoArray
            [albumInfoArray addObject:albumInfo];
        }
        
        // Save albumNames array to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:albumInfoArray forKey:@"JAlbumInfoArray"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        DDLogVerbose(@"dataStore: saved fetched album names to NSUserDefaults");
        
        // Post notification that data fetch did happen
        [self postNotificationThatDataFetchDidHappen];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"dataStore: error fetching album data: %@", [error localizedDescription]);
    }];
    
    // Start the data fetch operation
    [dataFetchOperation start];
}

#pragma mark - Return fetched album info method

+ (NSArray *)returnFetchedAlbums {
    NSArray *arrayToReturn = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"JAlbumInfoArray"]];
    
    DDLogVerbose(@"dataStore: return fetched albums count: %d", [arrayToReturn count]);
    
    return arrayToReturn;
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
