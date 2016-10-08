//
//  AppDelegate.m
//  PenfreeMap
//
//  Created by Penfree.Tseng on 16/10/5.
//  Copyright © 2016年 Penfree.Tseng. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>

#define kBaiduAK @"6hOPDibG6qBVUQqYvhp9w1jcWwfjeuC0"

@interface AppDelegate ()
@property (nonatomic, strong) BMKMapManager *mapManager;
@end

@implementation AppDelegate
- (BMKMapManager *)mapManager {
    if (!_mapManager) {
        _mapManager = [[BMKMapManager alloc] init];
        BOOL ret = [_mapManager start:kBaiduAK  generalDelegate:nil];
        if (!ret) {
            NSLog(@"manager start failed!");
        }
    }
    return _mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //
    [self mapManager];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //
}

@end
