//
//  JAlbumListViewController.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "JAlbumListViewController.h"
#import <CocoaLumberjack.h>
#import "JDataStore.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "JAlbum.h"
#import "JAlbumDetailViewController.h"

@interface JAlbumListViewController ()

@end

static const int ddLogLevel = LOG_LEVEL_OFF;

@implementation JAlbumListViewController {
    NSArray *_cellDataSourceArray;
}

#pragma mark - Data fetch did happen NSNotifcation method

- (void)dataFetchDidHappen {
    DDLogVerbose(@"Album List VC: was notified that data fetch did happen");
    
    // Init data source array for tableView
    _cellDataSourceArray = [NSArray arrayWithArray:[JDataStore returnFetchedAlbums]];
    
    // Reload tableView with new data
    [self.tableView reloadData];
}

#pragma mark - Init methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register for dataFetchDidHappen NSNotification
    NSString *notificationName = @"JDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataFetchDidHappen)
                                                 name:notificationName
                                               object:nil];
}

- (void)dealloc {
    // Remove NSNotification observers
    NSString *notificationName = @"JDataFetchDidHappen";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:nil];
}

#pragma mark - Table view data source methods

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumListCell" forIndexPath:indexPath];
    
    // Init cell data
    JAlbum *cellData = [_cellDataSourceArray objectAtIndex:indexPath.row];
    NSString *albumNameString = cellData.albumName;
    NSString *albumReleaseDateString = cellData.albumReleaseDate;
    NSString *albumTrackCountString = cellData.albumTrackCount;
    
    // Init cell labels
    UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *albumReleaseDateLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *albumTrackCountLabel = (UILabel *)[cell viewWithTag:103];
    UIImageView *albumImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Set contents of labels using cell data
    [albumNameLabel setText:albumNameString];
    [albumReleaseDateLabel setText:albumReleaseDateString];
    [albumTrackCountLabel setText:[NSString stringWithFormat:@"%@ Songs", albumTrackCountString]];
    
    // Set image using AFNetworking
    [albumImageView setImageWithURL:[NSURL URLWithString:cellData.albumImageUrl]];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlbumDetailSegue"]) {
        // Init back bar button text
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Albums", nil)
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
        // Init cell data that was just chosen
        NSIndexPath *indexPath;
        JAlbumDetailViewController *destViewController = segue.destinationViewController;
        JAlbum *cellData;
        
        indexPath = [self.tableView indexPathForSelectedRow];
        cellData = [_cellDataSourceArray objectAtIndex:indexPath.row];
        destViewController.chosenAlbum = cellData;
    }
}

@end
