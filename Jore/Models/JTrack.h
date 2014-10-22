//
//  JTrack.h
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTrack : NSObject <NSCoding>

@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *trackId;
@property (nonatomic, strong) NSString *trackDuration;
@property (nonatomic, strong) NSString *trackNumber;
@property (nonatomic, strong) NSString *trackPreviewUrl;
@property (nonatomic, strong) NSString *trackBelongsToAlbumId;

- (id)initWithName:(NSString *)trackNameValue
             andId:(NSString *)trackIdValue
       andDuration:(NSString *)trackDurationValue
         andNumber:(NSString *)trackNumberValue
     andPreviewUrl:(NSString *)trackPreviewUrlValue
        andAlbumId:(NSString *)trackAlbumIdValue;

@end
