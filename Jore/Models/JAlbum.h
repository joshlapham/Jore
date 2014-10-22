//
//  JAlbum.h
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAlbum : NSObject <NSCoding>

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSString *albumId;
@property (nonatomic, strong) NSString *albumReleaseDate;
@property (nonatomic, strong) NSString *albumTrackCount;
@property (nonatomic, strong) NSString *albumImageUrl;

- (id)initWithName:(NSString *)albumNameValue
             andId:(NSString *)albumIdValue
    andReleaseDate:(NSString *)albumReleaseDateValue
     andTrackCount:(NSString *)albumTrackCountValue
       andImageUrl:(NSString *)albumImageUrlValue;

@end
