//
//  ISSPass.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSPass.h"
#import "ISSPosition.h"

@implementation ISSPass

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"magnitude": @"magnitude",
             @"startPosition": @"start",
             @"endPosition": @"end",
             @"maxPosition": @"max"
             };
}

+ (NSValueTransformer *)startPositionJSONTransformer {
    return [ISSPass positionTransformer];
}

+ (NSValueTransformer *)endPositionJSONTransformer {
    return [ISSPass positionTransformer];
}


+ (NSValueTransformer *)maxPositionJSONTransformer {
    return [ISSPass positionTransformer];
}


+ (NSValueTransformer *)positionTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *positionJSON) {
        NSError *err;
        ISSPosition *position = [MTLJSONAdapter modelOfClass:ISSPosition.class
                                          fromJSONDictionary:positionJSON
                                                       error:&err];
        if (!position) {
            NSLog(@"err: %@", err);
        }
        return position;
    } reverseBlock:^(ISSPosition *position) {
        return [MTLJSONAdapter JSONDictionaryFromModel:position];
    }];
}

@end
