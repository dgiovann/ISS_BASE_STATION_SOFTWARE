//
//  ISSBasicLocation.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle/Mantle.h>

@interface ISSBasicLocation : MTLModel <MTLJSONSerializing>

@property (readonly, copy, nonatomic) NSNumber *latitude;
@property (readonly, copy, nonatomic) NSNumber *longitude;

@end
