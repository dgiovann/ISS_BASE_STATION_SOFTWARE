//
//  ISSPointerClient.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/21/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSPointerClient.h"

static NSString *const ISSPointerClientBaseURL = @"http://192.168.1.1/";

@implementation ISSPointerClient

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
    return [self initWithBaseURL:[NSURL URLWithString:ISSPointerClientBaseURL]];
}


- (void)sendAzimuth:(NSUInteger)azimuth
           altitude:(NSUInteger)altitude;
{
    [self getPath:[NSString stringWithFormat:@"?%d,%d,1", azimuth, altitude]
                                  parameters:nil
                                     success:nil
                                     failure:nil];
}

@end
