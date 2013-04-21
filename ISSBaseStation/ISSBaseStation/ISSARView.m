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

#define SCREEN_OFFSET_DEGREES 22.5f

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#define DEGREES_TO_RADIANS (M_PI/180.0)
#define WGS84_A	(6378137.0)				// WGS 84 semi-major axis constant in meters
#define WGS84_E (8.1819190842622e-2)	// WGS 84 eccentricity
typedef float mat4f_t[16];	// 4x4 matrix in column major order
typedef float vec4f_t[4];	// 4D vector
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar);
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v);
void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b);
void transformFromRotationMatrix(vec4f_t mout, const CMRotationMatrix *m);
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z);
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u);


#pragma mark -
#pragma mark Geodetic utilities definition

// References to ECEF and ECEF to ENU conversion may be found on the web.

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z);

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u);


@interface ISSARView ()
@property (strong, nonatomic) UIView *captureView;
@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMAttitude *referenceAttitude;
@property (strong, nonatomic) UIView *issView;
@property (assign, nonatomic) CGFloat azimuth;
@property (assign, nonatomic) CGFloat minAzimuth;
@property (assign, nonatomic) CGFloat maxAzimuth;
@property (assign, nonatomic) CGFloat altitude;
@property (assign, nonatomic) CGFloat minAltitude;
@property (assign, nonatomic) CGFloat maxAltitude;
@end


@implementation ISSARView {
    mat4f_t _cameraTransform;
    mat4f_t _projectionTransform;
    vec4f_t _issCoordinates;
}

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
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplay:)];
    _locationManager = [[CLLocationManager alloc] init];
    _motionManager = [[CMMotionManager alloc] init];
    
    _issView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30.0, 30.0)];
    _issView.backgroundColor = [UIColor greenColor];
    [self addSubview:_issView];
    
    _captureView = [[UIView alloc] initWithFrame:self.bounds];
    _captureView.bounds = self.bounds;
    _captureView.backgroundColor = [UIColor orangeColor];
    [self addSubview:_captureView];
    [self sendSubviewToBack:_captureView];
    
    self.issLocation = [[CLLocation alloc] initWithLatitude:37.7690400
                                                  longitude:-122.4835193];
    
    // Initialize projection matrix
	createProjectionMatrix(_projectionTransform, 60.0f*DEGREES_TO_RADIANS, self.bounds.size.height*1.0f / self.bounds.size.width, 0.25f, 1000.0f);
    
    [self updateISSLocation];
}

- (void)drawRect:(CGRect)rect
{
    mat4f_t projectionCameraTransform;
	multiplyMatrixAndMatrix(projectionCameraTransform,
                            _projectionTransform,
                            _cameraTransform);
    vec4f_t v;
    multiplyMatrixAndVector(v, projectionCameraTransform, _issCoordinates);
    
    float y = (v[0] / v[3] + 1.0f) * 0.5f;
    float x = (v[1] / v[3] + 1.0f) * 0.5f;
    if (v[2] < 0.0f) {
    self.issView.center = CGPointMake(x*self.bounds.size.width, self.bounds.size.height-y*self.bounds.size.height);
        self.issView.hidden = NO;
    } else {
        self.issView.hidden = YES;
    }
}


#pragma mark - Instance Methods
- (void)startSensors {
    [self startCamera];
    [self startLocation];
    [self startMotion];
    [self startDisplay];
}


- (void)stopSensors {
    [self stopCamera];
    [self stopLocation];
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


- (void)startLocation {
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 100.0;
    [self.locationManager startUpdatingLocation];
}


- (void)stopLocation {
    [self.locationManager stopUpdatingLocation];
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
    self.altitude = RADIANS_TO_DEGREES(attitude.roll) - 90.0f;
    self.maxAltitude = self.altitude + SCREEN_OFFSET_DEGREES;
    self.minAltitude = self.altitude + SCREEN_OFFSET_DEGREES;
    
    // This is for left-right
    CGFloat azimuth = -RADIANS_TO_DEGREES(attitude.yaw);
    self.azimuth = (azimuth >= 0.0f) ? azimuth : 360.0f + azimuth;
    CGFloat minAzimuth = self.azimuth - SCREEN_OFFSET_DEGREES;
    self.minAzimuth = (minAzimuth < 0.0f) ? minAzimuth + 360.0f : minAzimuth;
    CGFloat maxAzimuth = self.azimuth + SCREEN_OFFSET_DEGREES;
    self.maxAzimuth = (maxAzimuth > 360.0f) ? maxAzimuth - 360.0f : maxAzimuth;
    
	if (deviceMotion != nil) {
		CMRotationMatrix r = deviceMotion.attitude.rotationMatrix;
		transformFromRotationMatrix(_cameraTransform, &r);
		[self setNeedsDisplay];
	}
}


- (void)updateISSLocation {
    if (self.currentLocation && self.issLocation) {
        double myX, myY, myZ, issX, issY, issZ, e, n, u;
        latLonToEcef(self.currentLocation.coordinate.latitude,
                     self.currentLocation.coordinate.longitude,
                     0.0,
                     &myX, &myY, &myZ);
        
        latLonToEcef(self.issLocation.coordinate.latitude,
                     self.issLocation.coordinate.longitude,
                     0.0,
                     &issX, &issY, &issZ);
        
        ecefToEnu(self.currentLocation.coordinate.latitude,
                  self.currentLocation.coordinate.longitude,
                  myX, myY, myZ,
                  issX, issY, issZ,
                  &e, &n, &u);
        
        _issCoordinates[0] = (float)n;
        _issCoordinates[1] = -(float)e;
        _issCoordinates[2] = 0.0f;
        _issCoordinates[3] = 1.0f;
    }
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    self.currentLocation = [locations lastObject];
    [self updateISSLocation];
}


@end


#pragma mark -
#pragma mark Math utilities definition

// Creates a projection matrix using the given y-axis field-of-view, aspect ratio, and near and far clipping planes
void createProjectionMatrix(mat4f_t mout, float fovy, float aspect, float zNear, float zFar)
{
	float f = 1.0f / tanf(fovy/2.0f);
	
	mout[0] = f / aspect;
	mout[1] = 0.0f;
	mout[2] = 0.0f;
	mout[3] = 0.0f;
	
	mout[4] = 0.0f;
	mout[5] = f;
	mout[6] = 0.0f;
	mout[7] = 0.0f;
	
	mout[8] = 0.0f;
	mout[9] = 0.0f;
	mout[10] = (zFar+zNear) / (zNear-zFar);
	mout[11] = -1.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 2 * zFar * zNear /  (zNear-zFar);
	mout[15] = 0.0f;
}

// Matrix-vector and matrix-matricx multiplication routines
void multiplyMatrixAndVector(vec4f_t vout, const mat4f_t m, const vec4f_t v)
{
	vout[0] = m[0]*v[0] + m[4]*v[1] + m[8]*v[2] + m[12]*v[3];
	vout[1] = m[1]*v[0] + m[5]*v[1] + m[9]*v[2] + m[13]*v[3];
	vout[2] = m[2]*v[0] + m[6]*v[1] + m[10]*v[2] + m[14]*v[3];
	vout[3] = m[3]*v[0] + m[7]*v[1] + m[11]*v[2] + m[15]*v[3];
}

void multiplyMatrixAndMatrix(mat4f_t c, const mat4f_t a, const mat4f_t b)
{
	uint8_t col, row, i;
	memset(c, 0, 16*sizeof(float));
	
	for (col = 0; col < 4; col++) {
		for (row = 0; row < 4; row++) {
			for (i = 0; i < 4; i++) {
				c[col*4+row] += a[i*4+row]*b[col*4+i];
			}
		}
	}
}

// Initialize mout to be an affine transform corresponding to the same rotation specified by m
void transformFromRotationMatrix(vec4f_t mout, const CMRotationMatrix *m)
{
	mout[0] = (float)m->m11;
	mout[1] = (float)m->m21;
	mout[2] = (float)m->m31;
	mout[3] = 0.0f;
	
	mout[4] = (float)m->m12;
	mout[5] = (float)m->m22;
	mout[6] = (float)m->m32;
	mout[7] = 0.0f;
	
	mout[8] = (float)m->m13;
	mout[9] = (float)m->m23;
	mout[10] = (float)m->m33;
	mout[11] = 0.0f;
	
	mout[12] = 0.0f;
	mout[13] = 0.0f;
	mout[14] = 0.0f;
	mout[15] = 1.0f;
}

#pragma mark -
#pragma mark Geodetic utilities definition

// References to ECEF and ECEF to ENU conversion may be found on the web.

// Converts latitude, longitude to ECEF coordinate system
void latLonToEcef(double lat, double lon, double alt, double *x, double *y, double *z)
{
	double clat = cos(lat * DEGREES_TO_RADIANS);
	double slat = sin(lat * DEGREES_TO_RADIANS);
	double clon = cos(lon * DEGREES_TO_RADIANS);
	double slon = sin(lon * DEGREES_TO_RADIANS);
	
	double N = WGS84_A / sqrt(1.0 - WGS84_E * WGS84_E * slat * slat);
	
	*x = (N + alt) * clat * clon;
	*y = (N + alt) * clat * slon;
	*z = (N * (1.0 - WGS84_E * WGS84_E) + alt) * slat;
}

// Coverts ECEF to ENU coordinates centered at given lat, lon
void ecefToEnu(double lat, double lon, double x, double y, double z, double xr, double yr, double zr, double *e, double *n, double *u)
{
	double clat = cos(lat * DEGREES_TO_RADIANS);
	double slat = sin(lat * DEGREES_TO_RADIANS);
	double clon = cos(lon * DEGREES_TO_RADIANS);
	double slon = sin(lon * DEGREES_TO_RADIANS);
	double dx = x - xr;
	double dy = y - yr;
	double dz = z - zr;
	
	*e = -slon*dx  + clon*dy;
	*n = -slat*clon*dx - slat*slon*dy + clat*dz;
	*u = clat*clon*dx + clat*slon*dy + slat*dz;
}
