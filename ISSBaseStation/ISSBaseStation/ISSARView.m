//
//  ISSARView.m
//  ISSBaseStation
//
//  Created by Matthew Thomas on 4/20/13.
//  Copyright (c) 2013 Matthew Thomas. All rights reserved.
//

#import "ISSARView.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "ISSPosition.h"

#define SCREEN_OFFSET_DEGREES 22.5f
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

float azimuthToScreen(float azimuth);


@interface ISSARView ()
@property (strong, nonatomic) UIView *captureView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) UIView *issView;
@property (strong, nonatomic) UIView *maxPassView;
@property (assign, nonatomic) CGFloat rotAzimuth;
@property (assign, nonatomic) CGFloat minRotAzimuth;
@property (assign, nonatomic) CGFloat maxRotAzimuth;
@property (assign, nonatomic) CGFloat azimuth;
@property (assign, nonatomic) CGFloat minAzimuth;
@property (assign, nonatomic) CGFloat maxAzimuth;
@property (assign, nonatomic) CGFloat altitude;
@property (assign, nonatomic) CGFloat minAltitude;
@property (assign, nonatomic) CGFloat maxAltitude;
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
    self.backgroundColor = [UIColor greenColor];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
    _motionManager = [[CMMotionManager alloc] init];
    
    _issView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    _issView.backgroundColor = [UIColor greenColor];
    [self addSubview:_issView];
    
    _maxPassView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ISSTabBar"]];
    _maxPassView.backgroundColor = [UIColor purpleColor];
    [self addSubview:_maxPassView];
    
    _captureView = [[UIView alloc] initWithFrame:self.bounds];
    _captureView.backgroundColor = [UIColor orangeColor];
    _captureView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_captureView];
    [self sendSubviewToBack:_captureView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _issView.hidden = YES;
    _maxPassView.hidden = !self.nextPass;
    if (!_maxPassView.hidden) {
        // convert from pass azimuth to screen coordinates)
        CGFloat passAsimuth = [self.nextPass.maxPosition.azimuth floatValue];
        CGFloat passAltitude = [self.nextPass.maxPosition.altitude floatValue];
        
        CGFloat xPixelPerDegree = self.bounds.size.width / 180.0f;
        CGFloat yPixelPerDegree = self.bounds.size.height / 180.0f;
        
        CGFloat minScreenAz = azimuthToScreen(self.minAzimuth);
        CGFloat passScreenAz = azimuthToScreen(passAsimuth);
        
        CGFloat xPos = (passScreenAz - minScreenAz) * xPixelPerDegree;

//        CGFloat yOffset = (passAltitude - self.minAltitude);
//        CGFloat yPos = (self.bounds.size.height - yOffset) * yPixelPerDegree;
//        NSLog(@"passAltitude: %f", passAltitude);
//        NSLog(@"minAltitude: %f", self.minAltitude);
//        NSLog(@"yOffset: %f", yOffset);
//        NSLog(@"yPos: %f", yPos);
//        NSLog(@"self.altitude: %f", self.altitude);
//                _maxPassView.center = CGPointMake(xPos, yPos);
        _maxPassView.center = CGPointMake(xPos, self.bounds.size.height / 2.0f);
    }
}


#pragma mark - Instance Methods
- (void)startSensors {
    [self startCamera];
    [self startMotion];
    [self startDisplay];
}


- (void)stopSensors {
    [self stopCamera];
    [self stopMotion];
    [self stopDisplay];
}


#pragma mark - Private Instance Methods

- (void)startCamera {
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if (camera == nil) {
		return;
	}
	
	self.captureSession = [[AVCaptureSession alloc] init];
	AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:nil];
	[self.captureSession addInput:newVideoInput];
	
	self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    self.captureLayer.connection.videoOrientation = UIInterfaceOrientationLandscapeRight;
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


- (void)startMotion {
    self.motionManager.showsDeviceMovementDisplay = YES;
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
	[self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical];
}


- (void)stopMotion {
    [self.motionManager stopDeviceMotionUpdates];
}


- (void)startDisplay {
    [self.displayLink setFrameInterval:1];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)stopDisplay {
    [self.displayLink invalidate];
}


- (void)updateDisplay:(id)sender {
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;
    CMAttitude *attitude = deviceMotion.attitude;

    // This is for up and down
    self.altitude = (-RADIANS_TO_DEGREES(attitude.roll)) - 90.0f;
    self.maxAltitude = self.altitude + SCREEN_OFFSET_DEGREES;
    self.minAltitude = self.altitude - SCREEN_OFFSET_DEGREES;
    
    // This is for left-right
    CGFloat azimuth = -RADIANS_TO_DEGREES(attitude.yaw);
    self.azimuth = (azimuth >= 0.0f) ? azimuth : 360.0f + azimuth;
    CGFloat minAzimuth = self.azimuth - SCREEN_OFFSET_DEGREES;
    self.minAzimuth = (minAzimuth < 0.0f) ? minAzimuth + 360.0f : minAzimuth;
    CGFloat maxAzimuth = self.azimuth + SCREEN_OFFSET_DEGREES;
    self.maxAzimuth = (maxAzimuth > 360.0f) ? maxAzimuth - 360.0f : maxAzimuth;
    
	if (deviceMotion != nil) {
		[self setNeedsLayout];
	}
}


@end


#pragma mark - Maths
float azimuthToScreen(float azimuth) {
    return (azimuth > 180.0f) ? azimuth - 360.0f : azimuth;
}


