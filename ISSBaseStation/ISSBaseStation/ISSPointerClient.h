//
//  ISSPointerClient.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/21/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface ISSPointerClient : AFHTTPClient

- (void)sendAzimuth:(NSUInteger)azimuth
           altitude:(NSUInteger)altitude;
@end
