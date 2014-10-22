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
+ (NSArray *)returnFetchedAlbumNames;
+ (void)postNotificationThatDataFetchDidHappen;

@end
