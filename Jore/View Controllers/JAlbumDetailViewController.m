//
//  JAlbumDetailViewController.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JAlbumDetailViewController.h"
#import "JAlbum.h"
#import "JDataStore.h"
#import "JTrack.h"
#import <CocoaLumberjack.h>
#import <AVFoundation/AVFoundation.h>

@interface JAlbumDetailViewController ()

@end

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation JAlbumDetailViewController {
    NSArray *_cellDataSourceArray;
    AVPlayer *_player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title text
    self.title = self.chosenAlbum.albumName;
    
    // Init tableView data source
    _cellDataSourceArray = [JDataStore returnFetchedTracksForAlbumId:self.chosenAlbum.albumId];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:NO];
    
    // Remove KVO for AVPlayer
    [_player removeObserver:self forKeyPath:@"status" context:nil];
    _player = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_cellDataSourceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumDetailCell" forIndexPath:indexPath];
    
    // Init data for cell
    JTrack *cellData = [_cellDataSourceArray objectAtIndex:indexPath.row];
    
    // Init labels and strings
    UILabel *trackNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *trackDurationLabel = (UILabel *)[cell viewWithTag:102];
    NSString *trackNameLabelString = [NSString stringWithFormat:@"%@. %@", cellData.trackNumber, cellData.trackName];
    NSString *trackDurationLabelString = [JDataStore convertTrackDurationFromMilliseconds:cellData.trackDuration];
    
    // Set contents of labels using our data
    [trackNameLabel setText:trackNameLabelString];
    [trackDurationLabel setText:trackDurationLabelString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JTrack *cellData = [_cellDataSourceArray objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL URLWithString:cellData.trackPreviewUrl];
    
    // Remove existing KVO
    [_player removeObserver:self forKeyPath:@"status" context:nil];
    _player = nil;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [_player addObserver:self forKeyPath:@"status" options:0 context:NULL];
}

#pragma mark - AVPlayer KVO method

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [_player play];
        } else if (_player.status == AVPlayerStatusFailed) {
            DDLogError(@"Album Detail VC: error playing sample");
        }
    }
}

@end
