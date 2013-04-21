//
//  ISSARViewController.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSARViewController.h"
#import "ISSARView.h"

@interface ISSARViewController ()
@property (strong, nonatomic) IBOutlet ISSARView *arView;
@end

@implementation ISSARViewController

- (void)setNextPass:(ISSPass *)nextPass {
    _nextPass = [nextPass copy];
    self.arView.nextPass = _nextPass;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.arView startSensors];
}


- (void)viewDidDisappear:(BOOL)animated {
    [self.arView stopSensors];
}

@end
