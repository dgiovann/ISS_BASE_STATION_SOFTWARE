//
//  ISSPosition.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSPosition.h"

@implementation ISSPosition

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"altitude": @"alt",
             @"azimuth": @"az",
             @"date": @"time"
             };
}


+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *seconds) {
        return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
    } reverseBlock:^(NSDate *date) {
        return [NSNumber numberWithDouble:date.timeIntervalSince1970];
    }];
}


@end
