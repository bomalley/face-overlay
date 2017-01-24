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




@interface ViewController () {
	CIDetector *faceDetector;

	NSURL *photoURL;
}

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *overlay;

@end

@implementation ViewController

@synthesize photo;
@synthesize overlay;

- (void)viewDidLoad {
	[super viewDidLoad];

	photoURL = [[NSBundle mainBundle] URLForResource: @"michael" withExtension: @"jpg"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];

	[photo setImage: [UIImage imageWithData: [NSData dataWithContentsOfURL: photoURL]]];
	[self setupFaceDetector];
}

- (void)setupFaceDetector {
	NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };

	faceDetector = [CIDetector detectorOfType: CIDetectorTypeFace
									  context: nil
									  options: opts];

	CIImage *ciPhoto = [CIImage imageWithContentsOfURL: photoURL];

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


	UIView *leftEyeAlt = [[UIView alloc] initWithFrame: CGRectMake(le.x * widthRatio, (ciPhotoHeight - le.y) * heightRatio, 5, 5)];
	[leftEyeAlt setBackgroundColor: [UIColor whiteColor]];
	[[self view] addSubview: leftEyeAlt];

	CGPoint faceCenter;

	faceCenter.x = ((le.x + re.x + mo.x) / 3.0) * widthRatio;
	faceCenter.y = (([self fixY: le.y forImageHeight: ciPhotoHeight] + [self fixY: re.y forImageHeight: ciPhotoHeight] + [self fixY: mo.y forImageHeight: ciPhotoHeight]) / 3.0) * heightRatio;

	[overlay setCenter: faceCenter];
//	CGRect overlayFrame = [overlay frame];
//
//	CGFloat overlayRatio = CGRectGetHeight(overlayFrame) / CGRectGetWidth(overlayFrame);
//
//	overlayFrame.origin.x = fb.origin.x * widthRatio;
//	overlayFrame.origin.y = fb.origin.y * heightRatio;
//	overlayFrame.size.width = fb.size.width * widthRatio;
//	overlayFrame.size.height = overlayFrame.size.width * overlayRatio;
//
//	[overlay setFrame: overlayFrame];
//	[overlay setCenter: CGPointMake(50, 50)];
//	[overlay setBackgroundColor: [UIColor greenColor]];
//
//
//	NSLog(@"%@", faces);
//	NSLog(@"%@", ff);
}

- (CGFloat)fixY:(CGFloat)y forImageHeight:(CGFloat)height {
	return height - y;
}

@end
