//
//  MergeVideoViewController.h
//  VideoPlayRecord
//
//  Created by Dandeljane Maraat on 11/14/16.
//  Copyright © 2016 Dandeljane Maraat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>

@interface MergeVideoViewController: UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate,MPMediaPickerControllerDelegate>{
	BOOL isSelectingAssetOne;
}

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;
@property(nonatomic, strong) AVAsset *audioAsset;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

-(IBAction)loadAssetOne:(id)sender;
-(IBAction)loadAssetTwo:(id)sender;
-(IBAction)loadAudio:(id)sender;
-(IBAction)mergeAndSave:(id)sender;
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id <UIImagePickerControllerDelegate,
																						UINavigationControllerDelegate>)delegate;
-(void)exportDidFinish:(AVAssetExportSession*)session;
@end
