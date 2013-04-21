//
//  ISSHeavensAboveClient.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSHeavensAboveClient.h"

static NSString *const ISSHeavensAboveClientBaseURL = @"http://api.uhaapi.com/";

@implementation ISSHeavensAboveClient

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        self.parameterEncoding = AFJSONParameterEncoding;
    }
    return self;
}

- (instancetype)init {
    return [self initWithBaseURL:[NSURL URLWithString:ISSHeavensAboveClientBaseURL]];
}


- (void)gitISSPassesForLocation:(CLLocation *)location
                        success:(void (^)(AFHTTPRequestOperation *operation, ISSStationInfo *stationInfo))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self getPath:@"satellites/25544/passes"
       parameters:@{ISSStationInfoLatitudeKey: @(location.coordinate.latitude),
                    ISSStationInfoLongitudeKey: @(location.coordinate.longitude)}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSError *creationError;
              ISSStationInfo *stationInfo = [MTLJSONAdapter modelOfClass:ISSStationInfo.class
                                                      fromJSONDictionary:responseObject
                                                                   error:&creationError];
              if (stationInfo) {
                  if (success) {
                      success(operation, stationInfo);
                  }
              } else {
                  if (failure) {
                      failure(operation, creationError);
                  }
              }
          }
          failure:failure];
}


@end
