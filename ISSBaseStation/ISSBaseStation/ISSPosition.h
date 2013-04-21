//
//  ISSPosition.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ISSPosition : MTLModel <MTLJSONSerializing>

@property (readonly, copy, nonatomic) NSNumber *altitude;
@property (readonly, copy, nonatomic) NSNumber *azimuth;
@property (readonly, copy, nonatomic) NSDate *date;

@end
