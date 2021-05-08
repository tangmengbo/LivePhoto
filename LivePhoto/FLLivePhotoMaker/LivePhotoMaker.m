//
//  LivePhotoMaker.m
//  BeautyFace
//
//  Created by mac-vincent on 2017/4/13.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "LivePhotoMaker.h"
#import "MovModel.h"
#import "JPGModel.h"
#import "FilePathManager.h"

@import MobileCoreServices;
@import ImageIO;
@import Photos;


@implementation LivePhotoMaker


+ (void)makeLivePhotoByLibrary:(NSURL *)movUrl completed:(void (^)(NSDictionary * resultDic))didCreateLivePhoto {
    AVURLAsset *asset = [AVURLAsset assetWithURL:movUrl];

    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    generator.appliesPreferredTrackTransform = YES;
    [generator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:CMTimeMakeWithSeconds(CMTimeGetSeconds(asset.duration)/2.f, asset.duration.timescale)]]
                                    completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
                                        NSData * firstFrameData = UIImageJPEGRepresentation([UIImage imageWithCGImage:image],0.7);
                                        //save photo
                                        
                                        [firstFrameData writeToURL:[FilePathManager originJPGPath] atomically:YES];
                                        NSString *assetIdentifier = [[NSUUID UUID] UUIDString];
                                        [[NSFileManager defaultManager] createDirectoryAtPath:[FilePathManager getDocumentPath].path
                                                                  withIntermediateDirectories:YES
                                                                                   attributes:nil
                                                                                        error:&error];
                                        if (!error) {
                                            [[NSFileManager defaultManager] removeItemAtPath:[FilePathManager getJPGFinalPath].path
                                                                                       error:&error];
                                            
                                            [[NSFileManager defaultManager] removeItemAtPath:[FilePathManager getMovFinalPath].path
                                                                                       error:&error];   
                                        }
                                        
                                        [JPGModel writeToFileWithOriginJPGPath:[FilePathManager originJPGPath] TargetWriteFilePath:[FilePathManager getJPGFinalPath] AssetIdentifier:assetIdentifier];
                                       
                                        [MovModel writeToFileWithOriginMovPath:movUrl TargetWriteFilePath:[FilePathManager getMovFinalPath] AssetIdentifier:assetIdentifier];
                                        NSDictionary * dic = @{
                                                               @"MOVPath":[FilePathManager getMovFinalPath],
                                                               @"JPGPath":[FilePathManager getJPGFinalPath]
                                                               };
                                        didCreateLivePhoto(dic);
                                        
                               }];

                                        
                                       

}

+ (void)saveLivePhotoToAlbumWithMovPath:(NSURL *)movPath ImagePath:(NSURL *)jpgPath completed:(void (^)(BOOL isSuccess))didSaveLivePhoto {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
        [request addResourceWithType:PHAssetResourceTypePairedVideo fileURL:movPath options:options];
        [request addResourceWithType:PHAssetResourceTypePhoto fileURL:jpgPath options:options];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if(success) {
            NSLog(@"Save success\n");
            didSaveLivePhoto(YES);
        } else {
            didSaveLivePhoto(NO);
        }
    }];

}


@end
