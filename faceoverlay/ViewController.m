//
//  ViewController.m
//  faceoverlay
//
//  Created by Bryan O'Malley on 1/23/17.
//  Copyright © 2017 Bryan O'Malley. All rights reserved.
//

#import "ViewController.h"
@import CoreImage;
@import ImageIO;
@import QuartzCore;
@import GLKit;



@interface ViewController () {
	NSArray *photos;

	NSInteger photoIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *overlay;

@end

@implementation ViewController

@synthesize photo;
@synthesize overlay;

- (void)viewDidLoad {
	[super viewDidLoad];

	photos = @[[[NSBundle mainBundle] URLForResource: @"bryan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"dan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"shaun" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"michael" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"alan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"anna" withExtension: @"jpg"]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];

	[photo setImage: [UIImage imageWithData: [NSData dataWithContentsOfURL: [photos objectAtIndex: photoIndex]]]];
	[self setupFaceDetector];
}

- (IBAction)nextPhoto:(id)sender {
	photoIndex++;

	if (photoIndex >= [photos count]) {
		photoIndex = 0;
	}

	[overlay setTransform: CGAffineTransformIdentity];

	[photo setImage: [UIImage imageWithData: [NSData dataWithContentsOfURL: [photos objectAtIndex: photoIndex]]]];
	[self setupFaceDetector];
}

- (void)setupFaceDetector {
	NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };

	CIDetector *faceDetector = [CIDetector detectorOfType: CIDetectorTypeFace
									  context: nil
									  options: opts];

	CIImage *ciPhoto = [CIImage imageWithContentsOfURL: [photos objectAtIndex: photoIndex]];

	NSLog(@"%@", [ciPhoto properties]);
	opts = @{ CIDetectorImageOrientation : [[ciPhoto properties] valueForKey: kCGImagePropertyOrientation] };


	// Detect the faces
	NSArray *faces = [faceDetector featuresInImage: ciPhoto options: opts];

	CIFaceFeature *ff = [faces firstObject];

	CGPoint le = [ff leftEyePosition];

	CGPoint re = [ff rightEyePosition];

	CGPoint mo = [ff mouthPosition];

	CGRect fb = [ff bounds];

	CGFloat ciPhotoWidth = [[[ciPhoto properties] objectForKey: @"PixelWidth"] floatValue];
	CGFloat ciPhotoHeight = [[[ciPhoto properties] objectForKey: @"PixelHeight"] floatValue];
	CGFloat uiPhotoWidth = CGRectGetWidth([photo bounds]);
	CGFloat uiPhotoHeight = CGRectGetHeight([photo bounds]);
	CGFloat widthRatio = uiPhotoWidth/ciPhotoWidth;
	CGFloat heightRatio = uiPhotoHeight/ciPhotoHeight;



	CGRect overlayFrame = [overlay frame];

	CGFloat overlayRatio = CGRectGetHeight(overlayFrame) / CGRectGetWidth(overlayFrame);

	overlayFrame.size.width = fb.size.width * widthRatio;
	overlayFrame.size.height = overlayFrame.size.width * overlayRatio;

	[overlay setFrame: overlayFrame];

	CGPoint faceCenter;

	faceCenter.x = ((le.x + re.x + mo.x) / 3.0) * widthRatio;
	faceCenter.y = (([self fixY: le.y forImageHeight: ciPhotoHeight] + [self fixY: re.y forImageHeight: ciPhotoHeight] + [self fixY: mo.y forImageHeight: ciPhotoHeight]) / 3.0) * heightRatio;

	[overlay setCenter: faceCenter];

	CGFloat faceAngleInRadians = GLKMathDegreesToRadians(ff.faceAngle);

	CGAffineTransform t = [overlay transform];
	CGAffineTransform rotateTransform = CGAffineTransformRotate(t, faceAngleInRadians);

	[overlay setTransform: rotateTransform];

	NSLog(@"Face Angle in Degrees %f", ff.faceAngle);
	NSLog(@"Face Angle in Radians %f", faceAngleInRadians);
//	NSLog(@"%@", faces);
//	NSLog(@"%@", ff);
}

- (CGFloat)fixY:(CGFloat)y forImageHeight:(CGFloat)height {
	return height - y;
}

@end
