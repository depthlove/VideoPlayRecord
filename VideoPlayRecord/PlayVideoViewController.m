//
//  PlayVideoViewController.m
//  VideoPlayRecord
//
//  Created by Dandeljane Maraat on 11/14/16.
//  Copyright © 2016 Dandeljane Maraat. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()

@end

@implementation PlayVideoViewController

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

- (IBAction)playVideo:(id)sender {
	[self startMediaBrowserFromViewController:self usingDelegate:self];
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id )delegate {
	// 1 - Validations
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
		|| (delegate == nil)
		|| (controller == nil)) {
		return NO;
	}
	// 2 - Get image picker
	UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
	mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
	// Hides the controls for moving & scaling pictures, or for
	// trimming movies. To instead show the controls, use YES.
	mediaUI.allowsEditing = YES;
	mediaUI.delegate = delegate;
	// 3 - Display image picker
	[controller presentViewController:mediaUI animated:YES completion:nil];
	return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	// 1 - Get media type
	NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
	// 2 - Dismiss image picker
	[self dismissViewControllerAnimated:NO completion:nil];
	// Handle a movie capture
	if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
		// 3 - Play the video
		// create a player view controller
		
		AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
		
		playerViewController.player = [AVPlayer playerWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
		[self presentViewController:playerViewController animated:NO completion:nil];
	}
}

// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
	[self dismissViewControllerAnimated:NO completion:nil];
//	AVPlayerViewController *theMovie = [aNotification object];
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self
//													name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}
@end
