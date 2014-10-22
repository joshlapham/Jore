//
//  AppDelegate.m
//  Jore
//
//  Created by jl on 22/10/2014.
//  Copyright (c) 2014 Josh Lapham. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Stores/JPLReachabilityManager.h"
#import "Stores/JDataStore.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - Check for network reachability method

- (void)checkForNetworkReachability {
    if ([JPLReachabilityManager isReachable]) {
        // Fetch album data
        [JDataStore fetchAlbumData];
    } else {
        // TODO: show UIAlertView advising of no network connection
    }
}

#pragma mark - App Delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Init CocoaLumberjack
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // Init Reachability
    [JPLReachabilityManager sharedManager];
    
    // Init data store
    [JDataStore sharedStore];
    
    // Check for network reachability
    //[self checkForNetworkReachability];
    
    // Fetch album data
    [JDataStore fetchAlbumData];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
