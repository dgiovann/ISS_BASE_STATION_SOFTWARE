//
//  ISSHeavensAboveClient.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import "ISSStationInfo.h"

@interface ISSHeavensAboveClient : AFHTTPClient

- (void)gitISSPassesForLocation:(CLLocation *)location
                        success:(void (^)(AFHTTPRequestOperation *operation, ISSStationInfo *stationInfo))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
