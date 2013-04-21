//
//  ISSStationInfo.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSStationInfo.h"
#import "ISSPass.h"

NSString *const ISSStationInfoLatitudeKey = @"lat";
NSString *const ISSStationInfoLongitudeKey = @"lng";

@implementation ISSStationInfo

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"stationIdentifier": @"id",
             @"infoStartDate": @"from",
             @"infoEndDate": @"to",
             @"altitude": @"altitude",
             @"location": @"location",
             @"passes": @"results"
             };
}


+ (NSValueTransformer *)infoStartDateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *seconds) {
        return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
    } reverseBlock:^(NSDate *date) {
        return [NSNumber numberWithDouble:date.timeIntervalSince1970];
    }];
}


+ (NSValueTransformer *)infoEndDateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *seconds) {
        return [NSDate dateWithTimeIntervalSince1970:seconds.doubleValue];
    } reverseBlock:^(NSDate *date) {
        return [NSNumber numberWithDouble:date.timeIntervalSince1970];
    }];
}


+ (NSValueTransformer *)locationJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *locationJSON) {
        return [[CLLocation alloc] initWithLatitude:[[locationJSON objectForKey:ISSStationInfoLatitudeKey] doubleValue]
                                          longitude:[[locationJSON objectForKey:ISSStationInfoLongitudeKey] doubleValue]];
    } reverseBlock:^(CLLocation *location) {
        return @{ISSStationInfoLatitudeKey: @(location.coordinate.latitude),
                 ISSStationInfoLongitudeKey: @(location.coordinate.longitude)};
    }];
}


+ (NSValueTransformer *)passesJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *results) {
        NSMutableArray *passes = [NSMutableArray arrayWithCapacity:results.count];
        for (NSDictionary *passJSON in results) {
            NSError *err;
            ISSPass *pass = [MTLJSONAdapter modelOfClass:[ISSPass class]
                                      fromJSONDictionary:passJSON
                                                   error:&err];
            if (pass) {
                [passes addObject:pass];
            } else {
                NSLog(@"err: %@", err);
            }
        }
        return passes;
    } reverseBlock:^(NSArray *passes) {
        NSMutableArray *resultsJSON = [NSMutableArray arrayWithCapacity:passes.count];
        for (ISSPass *pass in passes) {
            NSDictionary *resultJSON = [MTLJSONAdapter JSONDictionaryFromModel:pass];
            if (resultsJSON) {
                [resultsJSON addObject:resultJSON];
            }
        }
        return resultsJSON;
    }];
}


@end
