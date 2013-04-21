//
//  ISSPass.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "ISSPosition.h"

@interface ISSPass : MTLModel <MTLJSONSerializing>

@property (readonly, copy, nonatomic) NSNumber *magnitude;
@property (readonly, copy, nonatomic) ISSPosition *startPosition;
@property (readonly, copy, nonatomic) ISSPosition *endPosition;
@property (readonly, copy, nonatomic) ISSPosition *maxPosition;

@end
