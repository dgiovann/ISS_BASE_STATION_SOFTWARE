//
//  ISSBasicLocation.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSBasicLocation.h"

@implementation ISSBasicLocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"latitude": @"lat",
             @"longitude": @"lng"
             };
}


@end
