//
//  ISSARViewController.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSARViewController.h"
#import "ISSARView.h"
#import "ISSPass.h"
#import <CoreLocation/CoreLocation.h>
#import "ISSHeavensAboveClient.h"
#import <Social/Social.h>

@interface ISSARViewController () <CLLocationManagerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) IBOutlet ISSARView *arView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) ISSHeavensAboveClient *heavensAboveClient;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation ISSARViewController


- (IBAction)cameraPressed:(id)sender {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    __weak id weakself = self;
    self.imagePickerController.delegate = weakself;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLoad {
    self.heavensAboveClient = [ISSHeavensAboveClient new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 100.0;
    [self.locationManager startUpdatingLocation];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.arView startSensors];
}


- (void)viewDidDisappear:(BOOL)animated {
    [self.arView stopSensors];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.heavensAboveClient gitISSPassesForLocation:[locations lastObject]
                                             success:^(AFHTTPRequestOperation *operation, ISSStationInfo *stationInfo) {
                                                 self.arView.nextPass = [stationInfo.passes mtl_firstObject];
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"oops!: %@", error);
                                             }];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        SLComposeViewController *compose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [compose setInitialText:@" #ISSPhilly"];
        [compose addImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [self presentViewController:compose animated:YES completion:nil];
    }];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
