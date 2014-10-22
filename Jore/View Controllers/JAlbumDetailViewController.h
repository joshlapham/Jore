//
//  JAlbumDetailViewController.h
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAlbum;

@interface JAlbumDetailViewController : UITableViewController

@property (nonatomic, strong) JAlbum *chosenAlbum;

@end
