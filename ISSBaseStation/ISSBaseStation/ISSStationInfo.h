//
//  ISSStationInfo.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "ISSBasicLocation.h"

@interface ISSStationInfo : MTLModel <MTLJSONSerializing>

@property (readonly, copy, nonatomic) NSString *stationIdentifier;
@property (readonly, copy, nonatomic) NSDate *infoStartDate;
@property (readonly, copy, nonatomic) NSDate *infoEndDate;
@property (readonly, copy, nonatomic) NSNumber *altitude;
@property (readonly, copy, nonatomic) ISSBasicLocation *location;
@property (readonly, copy, nonatomic) NSArray *passes;

@end
