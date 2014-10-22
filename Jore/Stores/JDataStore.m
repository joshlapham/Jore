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
        // Init array to hold album name strings
        NSMutableArray *albumNames = [[NSMutableArray alloc] init];
        
        // Loop over fetched data to get album names and add to albumNames array
        for (NSDictionary *item in [responseObject objectForKey:@"items"]) {
            NSString *albumName = [item objectForKey:@"name"];
            DDLogVerbose(@"Album name: %@", albumName);
            [albumNames addObject:albumName];
        }
        
        // Save albumNames array to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setObject:albumNames forKey:@"JFetchedAlbumNames"];
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

#pragma mark - Return fetched album names method

+ (NSArray *)returnFetchedAlbumNames {
    NSArray *arrayToReturn = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:@"JFetchedAlbumNames"]];
    
    DDLogVerbose(@"dataStore: return fetched album names count: %d", [arrayToReturn count]);
    
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
