//
//  ISSAppDelegate.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "ISSHeavensAboveClient.h"
#import "ISSStationInfo.h"
#import "ISSPass.h"
#import "ISSPosition.h"


@interface ISSAppDelegate () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) ISSHeavensAboveClient *heavensAboveClient;
@end

@implementation ISSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.heavensAboveClient = [ISSHeavensAboveClient new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 100.0;
    [self.locationManager startUpdatingLocation];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.heavensAboveClient gitISSPassesForLocation:[locations lastObject]
                                             success:^(AFHTTPRequestOperation *operation, ISSStationInfo *stationInfo) {
                                                 NSLog(@"stationInfo: %@", stationInfo);
                                                 for (ISSPass *pass in stationInfo.passes) {
                                                     NSLog(@"pass: %@", pass.maxPosition);
                                                 }
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"oops!: %@", error);
                                             }];
}

@end
