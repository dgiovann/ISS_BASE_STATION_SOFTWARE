//
//  ISSARView.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSARView.h"
#import <AVFoundation/AVFoundation.h>

@interface ISSARView ()
@property (strong, nonatomic) UIView *captureView;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;
@end


@implementation ISSARView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _captureView = [[UIView alloc] initWithFrame:self.bounds];
    _captureView.bounds = self.bounds;
    _captureView.backgroundColor = [UIColor orangeColor];
    [self addSubview:_captureView];
    [self sendSubviewToBack:_captureView];
    [self startCamera];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (void)startCamera {
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (camera == nil) {
		return;
	}
	
	self.captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	[self.captureSession addInput:newVideoInput];
	
	self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.captureLayer.connection.videoOrientation = UIInterfaceOrientationLandscapeLeft;
	self.captureLayer.frame = self.captureView.bounds;
	[self.captureLayer setVideoGravity:AVLayerVideoGravityResize];
	[self.captureView.layer addSublayer:self.captureLayer];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.captureSession startRunning];
	});
}


- (void)stopCamera {
    [self.captureSession stopRunning];
	[self.captureLayer removeFromSuperlayer];
	self.captureSession = nil;
	self.captureLayer = nil;
}

@end
