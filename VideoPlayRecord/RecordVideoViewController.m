//
//  RecordVideoViewController.m
//  VideoPlayRecord
//
//  Created by Dandeljane Maraat on 11/14/16.
//  Copyright © 2016 Dandeljane Maraat. All rights reserved.
//

#import "RecordVideoViewController.h"

@interface RecordVideoViewController ()

@end

@implementation RecordVideoViewController

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

- (IBAction)recordAndPlay:(id)sender {
	[self startCameraControllerFromViewController:self usingDelegate:self];
}

-(BOOL)startCameraControllerFromViewController:(UIViewController*)controller
								 usingDelegate:(id )delegate {
	// 1 - Validattions
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
		|| (delegate == nil)
		|| (controller == nil)) {
		return NO;
	}
	// 2 - Get image picker
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
	// Displays a control that allows the user to choose movie capture
	cameraUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
	// Hides the controls for moving & scaling pictures, or for
	// trimming movies. To instead show the controls, use YES.
	cameraUI.allowsEditing = NO;
	cameraUI.delegate = delegate;
	// 3 - Display image picker
	[controller presentViewController:cameraUI animated:NO completion:nil];
	return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
	[self dismissViewControllerAnimated:NO completion:nil];
	// Handle a movie capture
	if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
		NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
		if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
			UISaveVideoAtPathToSavedPhotosAlbum(moviePath, self,
												@selector(video:didFinishSavingWithError:contextInfo:), nil);
		}
	}
}

-(void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
	if (error) {
		UIAlertController * alert = [UIAlertController
									 alertControllerWithTitle:@"Error"
									 message:@"Video Saving Failed"
									 preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction* cancelButton = [UIAlertAction
								   actionWithTitle:@"Ok"
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction * action) {
									   //Handle no, thanks button
								   }];
		
		[alert addAction:cancelButton];
		
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		UIAlertController * alert = [UIAlertController
									 alertControllerWithTitle:@"Video Saved"
									 message:@"Saved To Photo Album"
									 preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction* okButton = [UIAlertAction
								   actionWithTitle:@"Ok"
								   style:UIAlertActionStyleDefault
								   handler:^(UIAlertAction * action) {
									   //Handle no, thanks button
								   }];
		
		[alert addAction:okButton];
		
		[self presentViewController:alert animated:YES completion:nil];
	}
}
@end
