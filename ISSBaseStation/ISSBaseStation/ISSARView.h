//
//  ISSARView.h
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ISSPass.h"

@interface ISSARView : UIView <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *issLocation;
@property (copy, nonatomic) ISSPass *nextPass;
- (void)startSensors;
- (void)stopSensors;
@end
