//
//  JDataStore.h
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDataStore : NSObject

// Init method
+ (JDataStore *)sharedStore;

// Class methods
+ (void)fetchAlbumData;
+ (NSArray *)returnFetchedAlbums;
+ (NSArray *)returnFetchedTracksForAlbumId:(NSString *)albumId;
+ (NSString *)convertTrackDurationFromMilliseconds:(int)milliseconds;
+ (NSString *)convertAlbumDurationFromMilliseconds:(int)milliseconds;

@end
