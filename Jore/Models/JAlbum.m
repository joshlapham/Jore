//
//  JAlbum.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JAlbum.h"

@implementation JAlbum

@synthesize albumName, albumId, albumReleaseDate, albumTrackCount, albumImageUrl;

#pragma mark - Init method

- (id)initWithName:(NSString *)albumNameValue
             andId:(NSString *)albumIdValue
    andReleaseDate:(NSString *)albumReleaseDateValue
     andTrackCount:(NSString *)albumTrackCountValue
       andImageUrl:(NSString *)albumImageUrlValue {
    self = [super init];
    if (self) {
        albumName = albumNameValue;
        albumId = albumIdValue;
        albumReleaseDate = albumReleaseDateValue;
        albumTrackCount = albumTrackCountValue;
        albumImageUrl = albumImageUrlValue;
    }
    return self;
}

#pragma mark - NSCoding delegate methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        albumName = [aDecoder decodeObjectForKey:@"albumName"];
        albumId = [aDecoder decodeObjectForKey:@"albumId"];
        albumReleaseDate = [aDecoder decodeObjectForKey:@"albumReleaseDate"];
        albumTrackCount = [aDecoder decodeObjectForKey:@"albumTrackCount"];
        albumImageUrl = [aDecoder decodeObjectForKey:@"albumImageUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:albumName forKey:@"albumName"];
    [aCoder encodeObject:albumId forKey:@"albumId"];
    [aCoder encodeObject:albumReleaseDate forKey:@"albumReleaseDate"];
    [aCoder encodeObject:albumTrackCount forKey:@"albumTrackCount"];
    [aCoder encodeObject:albumImageUrl forKey:@"albumImageUrl"];
}

@end
