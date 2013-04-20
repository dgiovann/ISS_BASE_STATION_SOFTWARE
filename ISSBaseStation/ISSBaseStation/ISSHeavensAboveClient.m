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
                        success:(void (^)(AFHTTPRequestOperation *operation, NSArray *passes))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [self getPath:@"satellites/25544/passes"
       parameters:@{@"lat": @(location.coordinate.latitude), @"lng": @(location.coordinate.latitude)}
          success:success
          failure:failure];
}


@end
