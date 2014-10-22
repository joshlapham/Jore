//
//  JTrack.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JTrack.h"

@implementation JTrack

@synthesize trackName, trackId, trackDuration, trackNumber, trackPreviewUrl, trackBelongsToAlbumId;

#pragma mark - Init method

- (id)initWithName:(NSString *)trackNameValue
             andId:(NSString *)trackIdValue
       andDuration:(NSString *)trackDurationValue
         andNumber:(NSString *)trackNumberValue
     andPreviewUrl:(NSString *)trackPreviewUrlValue
        andAlbumId:(NSString *)trackAlbumIdValue {
    self = [super init];
    if (self) {
        trackName = trackNameValue;
        trackId = trackIdValue;
        trackDuration = trackDurationValue;
        trackNumber = trackNumberValue;
        trackPreviewUrl = trackPreviewUrlValue;
        trackBelongsToAlbumId = trackAlbumIdValue;
    }
    return self;
}

#pragma mark - NSCoding delegate methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        trackName = [aDecoder decodeObjectForKey:@"trackName"];
        trackId = [aDecoder decodeObjectForKey:@"trackId"];
        trackDuration = [aDecoder decodeObjectForKey:@"trackDuration"];
        trackNumber = [aDecoder decodeObjectForKey:@"trackNumber"];
        trackPreviewUrl = [aDecoder decodeObjectForKey:@"trackPreviewUrl"];
        trackBelongsToAlbumId = [aDecoder decodeObjectForKey:@"trackBelongsToAlbumId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:trackName forKey:@"albumName"];
    [aCoder encodeObject:trackId forKey:@"trackId"];
    [aCoder encodeObject:trackDuration forKey:@"trackDuration"];
    [aCoder encodeObject:trackNumber forKey:@"trackNumber"];
    [aCoder encodeObject:trackPreviewUrl forKey:@"trackPreviewUrl"];
    [aCoder encodeObject:trackBelongsToAlbumId forKey:@"trackBelongsToAlbumId"];
}

@end
