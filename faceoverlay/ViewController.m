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
}

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *overlay;

@end

@implementation ViewController

@synthesize photo;
@synthesize overlay;

- (void)viewDidLoad {
	[super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];

//	[self setupFaceDetector];
}

- (void)setupFaceDetector {
//	CIContext *context = [CIContext context];
	NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };

	faceDetector = [CIDetector detectorOfType: CIDetectorTypeFace
									  context: nil
									  options: opts];

	NSURL *photoURL = [[NSBundle mainBundle] URLForResource: @"bryan" withExtension: @"jpg"];
	CIImage *ciPhoto = [CIImage imageWithContentsOfURL: photoURL];

	NSLog(@"%@", [ciPhoto properties]);
	opts = @{ CIDetectorImageOrientation :
				  [[ciPhoto properties] valueForKey: kCGImagePropertyOrientation] };


	// Detect the faces
	NSArray *faces = [faceDetector featuresInImage: ciPhoto options: opts];

	CIFaceFeature *ff = [faces firstObject];

	CGPoint le = [ff leftEyePosition];

	CGPoint re = [ff rightEyePosition];

	CGPoint mo = [ff mouthPosition];

	CGRect fb = [ff bounds];

	CGFloat ciPhotoWidth = [[[ciPhoto properties] objectForKey: @"PixelWidth"] floatValue];
	CGFloat ciPhotoHeight = [[[ciPhoto properties] objectForKey: @"PixelHeight"] floatValue];
	CGFloat widthRatio = 1024/ciPhotoWidth;
	CGFloat heightRatio = 768/ciPhotoHeight;


	fb.origin.x = (fb.origin.x) * widthRatio;
	fb.origin.y = fb.origin.x * widthRatio;

	UIView *face = [[UIView alloc] initWithFrame: fb];
	[face setBackgroundColor: [UIColor redColor]];
	[[self view] addSubview: face];
	

	CGPoint leftEyePoint;

	leftEyePoint.x = ciPhotoWidth - le.x;
	leftEyePoint.y = ciPhotoHeight - le.y;

	UIView *leftEye = [[UIView alloc] initWithFrame: CGRectMake(leftEyePoint.x * widthRatio, le.y * heightRatio, 5, 5)];
	[leftEye setBackgroundColor: [UIColor redColor]];
	[[self view] addSubview: leftEye];

	CGPoint rightEyePoint;

	rightEyePoint.x = ciPhotoWidth - re.x;
	rightEyePoint.y = ciPhotoHeight - re.y;

	UIView *rightEye = [[UIView alloc] initWithFrame: CGRectMake(rightEyePoint.x * widthRatio, re.y * heightRatio, 5, 5)];
	[rightEye setBackgroundColor: [UIColor orangeColor]];
	[[self view] addSubview: rightEye];

	CGPoint mouthPoint;

	mouthPoint.x = ciPhotoWidth - mo.x;
	mouthPoint.y = ciPhotoHeight - mo.y;

	UIView *mouth = [[UIView alloc] initWithFrame: CGRectMake(mouthPoint.x * widthRatio, mo.y * heightRatio, 5, 5)];
	[mouth setBackgroundColor: [UIColor blueColor]];
	[[self view] addSubview: mouth];

	CGRect overlayFrame = [overlay frame];

	CGFloat overlayRatio = CGRectGetHeight(overlayFrame) / CGRectGetWidth(overlayFrame);

	overlayFrame.origin.x = fb.origin.x * widthRatio;
	overlayFrame.origin.y = fb.origin.y * heightRatio;
	overlayFrame.size.width = fb.size.width * widthRatio;
	overlayFrame.size.height = overlayFrame.size.width * overlayRatio;
//
//	overlayFrame.origin.x = 0;
//	overlayFrame.origin.y = 0;
//	overlayFrame.size.width = 100;
//	overlayFrame.size.height = 100;
//
	[overlay setFrame: overlayFrame];
//	[overlay setCenter: CGPointMake(50, 50)];
//	[overlay setBackgroundColor: [UIColor greenColor]];


	NSLog(@"%@", faces);
	NSLog(@"%@", ff);
}

@end
