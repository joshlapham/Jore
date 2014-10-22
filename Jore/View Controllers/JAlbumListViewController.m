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
    NSDictionary *cellData = [_cellDataSourceArray objectAtIndex:indexPath.row];
    NSString *albumNameString = [cellData objectForKey:@"albumName"];
    NSString *albumImageUrlString = [cellData objectForKey:@"albumImageUrl"];
    
    // Init cell labels
    UILabel *albumNameLabel = (UILabel *)[cell viewWithTag:101];
    UIImageView *albumImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Set contents of labels using cell data
    [albumNameLabel setText:albumNameString];
    [albumImageView setImageWithURL:[NSURL URLWithString:albumImageUrlString]];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
