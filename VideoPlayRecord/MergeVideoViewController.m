//
//  MergeVideoViewController.m
//  VideoPlayRecord
//
//  Created by Dandeljane Maraat on 11/14/16.
//  Copyright © 2016 Dandeljane Maraat. All rights reserved.
//

#import "MergeVideoViewController.h"

@interface MergeVideoViewController ()

@end

@implementation MergeVideoViewController

@synthesize firstAsset, secondAsset, audioAsset;
@synthesize activityView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loadAssetOne:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
		UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Saved Album Found" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			// handle
		}];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		isSelectingAssetOne = TRUE;
		[self startMediaBrowserFromViewController:self usingDelegate:self];
	}
}

- (IBAction)loadAssetTwo:(id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
		UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Saved Album Found" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			// handle
		}];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		isSelectingAssetOne = FALSE;
		[self startMediaBrowserFromViewController:self usingDelegate:self];
	}
}

- (IBAction)loadAudio:(id)sender {
	MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
	mediaPicker.delegate = self;
	mediaPicker.prompt = @"Select Audio";
	[self presentViewController:mediaPicker animated:NO completion:nil];
}

- (IBAction)mergeAndSave:(id)sender {
	if(firstAsset !=nil && secondAsset!=nil){
		[activityView startAnimating];
		//Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
		AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
		
		//VIDEO TRACK
		AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
		[firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
		
		AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
		[secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];
		
		//AUDIO TRACK
		if(audioAsset!=nil){
			AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
			[AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
		}
		
		AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
		MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration));
		
		//FIXING ORIENTATION//
		AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
		AVAssetTrack *FirstAssetTrack = [[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
		UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
		BOOL  isFirstAssetPortrait_  = NO;
		CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
		if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
		if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
		if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
		if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
		CGFloat FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.width;
		if(isFirstAssetPortrait_){
			FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.height;
			CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
			[FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
		}else{
			CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
			[FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
		}
		[FirstlayerInstruction setOpacity:0.0 atTime:firstAsset.duration];
		
		AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
		AVAssetTrack *SecondAssetTrack = [[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
		UIImageOrientation SecondAssetOrientation_  = UIImageOrientationUp;
		BOOL  isSecondAssetPortrait_  = NO;
		CGAffineTransform secondTransform = SecondAssetTrack.preferredTransform;
		if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)  {SecondAssetOrientation_= UIImageOrientationRight; isSecondAssetPortrait_ = YES;}
		if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)  {SecondAssetOrientation_ =  UIImageOrientationLeft; isSecondAssetPortrait_ = YES;}
		if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)   {SecondAssetOrientation_ =  UIImageOrientationUp;}
		if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {SecondAssetOrientation_ = UIImageOrientationDown;}
		CGFloat SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.width;
		if(isSecondAssetPortrait_){
			SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.height;
			CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
			[SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor) atTime:firstAsset.duration];
		}else{
			;
			CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
			[SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:firstAsset.duration];
		}
		
		
		MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
		
		AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
		MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
		MainCompositionInst.frameDuration = CMTimeMake(1, 30);
		MainCompositionInst.renderSize = CGSizeMake(320.0, 480.0);
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
		
		NSURL *url = [NSURL fileURLWithPath:myPathDocs];
		
		AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
		exporter.outputURL=url;
		exporter.outputFileType = AVFileTypeQuickTimeMovie;
		exporter.videoComposition = MainCompositionInst;
		exporter.shouldOptimizeForNetworkUse = YES;
		[exporter exportAsynchronouslyWithCompletionHandler:^
		 {
			 dispatch_async(dispatch_get_main_queue(), ^{
				 [self exportDidFinish:exporter];
			 });
		 }];
	}
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
	// 1 - Validation
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
		|| (delegate == nil)
		|| (controller == nil)) {
		return NO;
	}
	// 2 - Create image picker
	UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
	mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
	// Hides the controls for moving & scaling pictures, or for
	// trimming movies. To instead show the controls, use YES.
	mediaUI.allowsEditing = YES;
	mediaUI.delegate = delegate;
	// 3 - Display image picker
	[controller presentViewController:mediaUI animated:NO completion:nil];
	return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// 1 - Get media type
	NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
	// 2 - Dismiss image picker
	[self dismissViewControllerAnimated:NO completion:nil];
	// 3 - Handle video selection
	if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
		if (isSelectingAssetOne){
			NSLog(@"Video One  Loaded");
			UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video One Loaded" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				// handle
			}];
			[alert addAction:okButton];
			
			firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
			[self presentViewController:alert animated:YES completion:nil];
		} else {
			NSLog(@"Video two Loaded");
			UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video Two Loaded" preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				// handle
			}];
			[alert addAction:okButton];
			secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
			[self presentViewController:alert animated:YES completion:nil];
		}
	}
}

-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
	NSArray *selectedSong = [mediaItemCollection items];
	if ([selectedSong count] > 0) {
		MPMediaItem *songItem = [selectedSong objectAtIndex:0];
		NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
		audioAsset = [AVAsset assetWithURL:songURL];
		NSLog(@"Audio Loaded");
		UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Audio Loaded" preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			// handle
		}];
		[alert addAction:okButton];
		[self presentViewController:alert animated:YES completion:nil];
	}
	[self dismissViewControllerAnimated:NO completion:nil];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
	[self dismissViewControllerAnimated:NO completion:nil];
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
	if (session.status == AVAssetExportSessionStatusCompleted) {
		NSURL *outputURL = session.outputURL;
		// Save to the album
		__block PHObjectPlaceholder *placeholder;
		
		[[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
			PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
			placeholder = [createAssetRequest placeholderForCreatedAsset];
			
		} completionHandler:^(BOOL success, NSError *error) {
			if (success)
			{
				UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Video Saved" message:@"Saved To Photo Album" preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
					// handle
				}];
				[alert addAction:okButton];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self presentViewController:alert animated:YES completion:nil];
				});
			}
			else
			{
				UIAlertController  *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Video Saving Failed" preferredStyle:UIAlertControllerStyleAlert];
				UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
					// handle
				}];
				[alert addAction:okButton];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self presentViewController:alert animated:YES completion:nil];
				});
			}
		}];
	}
	
	audioAsset = nil;
	firstAsset = nil;
	secondAsset = nil;
	[activityView stopAnimating];
}

@end
