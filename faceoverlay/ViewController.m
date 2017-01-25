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


#define OVERLAY_RATIO	0.75
#define OVERLAY_FRAME	CGRectMake(-1536, -1152, 4096, 3072)


@interface ViewController () {
	NSArray *photos;

	NSInteger photoIndex;
	UIImage *currentPhoto;
}

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UIImageView *overlay;

@end

@implementation ViewController

@synthesize photo;
@synthesize overlay;

//*********************************
- (void)viewDidLoad {
	[super viewDidLoad];

	photos = @[[[NSBundle mainBundle] URLForResource: @"bryan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"dan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"shaun" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"michael" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"alan" withExtension: @"jpg"],
			   [[NSBundle mainBundle] URLForResource: @"anna" withExtension: @"jpg"]];
}

//*********************************
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];

	currentPhoto = [UIImage imageWithData: [NSData dataWithContentsOfURL: [photos firstObject]]];
//	[self setupFaceDetector];
}

//*********************************
- (IBAction)takePhoto:(UIButton *)sender {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	[picker setDelegate: self];
	[picker setAllowsEditing: NO];
	[picker setSourceType: UIImagePickerControllerSourceTypeCamera];

	[self presentViewController: picker animated: YES completion: NULL];
}

//*********************************
- (void)setupFaceDetector {
	NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };

	CIDetector *faceDetector = [CIDetector detectorOfType: CIDetectorTypeFace
									  context: nil
									  options: opts];

	NSData *data = UIImageJPEGRepresentation(currentPhoto, 1.0);
	CIImage *ciPhoto = [CIImage imageWithData: data];

	NSLog(@"%@", [ciPhoto properties]);

	if([[ciPhoto properties] valueForKey: (NSString *)kCGImagePropertyOrientation]) {
		opts = @{ CIDetectorImageOrientation : [[ciPhoto properties] valueForKey: (NSString *)kCGImagePropertyOrientation] };
	} else {
		opts = @{CIDetectorImageOrientation : [NSNumber numberWithInt: 1]};
	}

	// Detect the faces
	NSArray *faces = [faceDetector featuresInImage: ciPhoto options: opts];

	if ([faces count]) {
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

		CGFloat overlayFaceHeight = 536;
		CGFloat overlayFaceWidth = 446;



		CGRect overlayFrame = [overlay frame];

		overlayFrame.size.width = CGRectGetWidth(overlayFrame) * ((fb.size.width * widthRatio) / overlayFaceWidth);
		overlayFrame.size.height = overlayFrame.size.width * OVERLAY_RATIO;

		[overlay setFrame: overlayFrame];

		[overlay setHidden: NO];

		CGPoint faceCenter;

		faceCenter.x = (([self fixCoordinate: le.x forDimension: ciPhotoWidth] + [self fixCoordinate: re.x forDimension: ciPhotoWidth] + [self fixCoordinate: mo.x forDimension: ciPhotoWidth]) / 3.0) * widthRatio;
		faceCenter.y = ((le.y + re.y + mo.y) / 3.0) * heightRatio;

		[overlay setCenter: faceCenter];

		CGFloat faceAngleInRadians = GLKMathDegreesToRadians(ff.faceAngle);

		CGAffineTransform t = [overlay transform];
		CGAffineTransform rotateTransform = CGAffineTransformRotate(t, faceAngleInRadians);

		[overlay setTransform: rotateTransform];

		NSLog(@"Face Angle in Degrees %f", ff.faceAngle);
		NSLog(@"Face Angle in Radians %f", faceAngleInRadians);

//		UIView *leftEye = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 25, 25)];
//		[leftEye setBackgroundColor: [UIColor redColor]];
//		[leftEye setCenter: CGPointMake([self fixCoordinate: le.x forDimension: ciPhotoWidth] * widthRatio, le.y * heightRatio)];
//		[[self view] addSubview: leftEye];
	}
}

//*********************************
# pragma mark Image Picker Delegate
//*********************************


//*********************************
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

	[self resetOverlay];

	currentPhoto = info[UIImagePickerControllerOriginalImage];

	[photo setImage: currentPhoto];
	[self setupFaceDetector];
	[picker dismissViewControllerAnimated: YES completion: NULL];
}

//*********************************
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated: YES completion: NULL];
}

//*********************************
- (CGFloat)fixCoordinate:(CGFloat)c forDimension:(CGFloat)d {
	return d - c;
}

//*********************************
- (void)resetOverlay {
	[overlay setTransform: CGAffineTransformIdentity];
	[overlay setFrame: OVERLAY_FRAME];
}

@end
