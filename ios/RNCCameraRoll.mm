/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCCameraRoll.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

#import "ImageSaver.h"

@implementation RNCCameraRoll
{
  bool hasListeners;
}

RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

static NSString *const kErrorUnableToSave = @"E_UNABLE_TO_SAVE";
static NSString *const kErrorUnableToLoad = @"E_UNABLE_TO_LOAD";
static NSString *const kErrorNotSupported = @"E_NOT_SUPPORTED";

static NSString *const kErrorAuthRestricted = @"E_PHOTO_LIBRARY_AUTH_RESTRICTED";
static NSString *const kErrorAuthDenied = @"E_PHOTO_LIBRARY_AUTH_DENIED";

#pragma mark - Save image to library (no Photos.framework dependency)

RCT_EXPORT_METHOD(saveToLibrary:(NSURLRequest *)request
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    ImageSaver *imgManager = [[ImageSaver alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:request.URL];
    UIImage *image = [UIImage imageWithData:data];

    if (image == nil) {
        reject(kErrorUnableToLoad, @"Could not load image from URL", nil);
        return;
    }

    imgManager.successHandle = ^{
        resolve(request.URL.absoluteString);
    };

    imgManager.faildHandle = ^void(NSError* error){
        if ([error.domain isEqual:@"ALAssetsLibraryErrorDomain"]) {
            reject(kErrorAuthDenied, @"Access to photo library is restricted", nil);
        } else {
            reject(kErrorUnableToSave, error.localizedDescription, error);
        }
    };

    [imgManager writeToPhoto:image];
}

#pragma mark - Stubs for legacy APIs (Photos.framework removed for Browser-app compatibility)

RCT_EXPORT_METHOD(saveToCameraRoll:(NSURLRequest *)request
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"saveToCameraRoll is not supported in this build. Use saveToLibrary instead.", nil);
}

RCT_EXPORT_METHOD(getAlbums:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"getAlbums is not supported in this build.", nil);
}

RCT_EXPORT_METHOD(getPhotos:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"getPhotos is not supported in this build.", nil);
}

RCT_EXPORT_METHOD(deletePhotos:(NSArray<NSString *>*)assets
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"deletePhotos is not supported in this build.", nil);
}

RCT_EXPORT_METHOD(getPhotoByInternalID:(NSString *)internalId
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"getPhotoByInternalID is not supported in this build.", nil);
}

RCT_EXPORT_METHOD(getPhotoThumbnail:(NSString *)internalId
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorNotSupported, @"getPhotoThumbnail is not supported in this build.", nil);
}

#pragma mark - Event emitter

- (NSArray<NSString *> *)supportedEvents {
	return @[@"onProgressUpdate"];
}

-(void)startObserving {
  hasListeners = YES;
}

-(void)stopObserving {
  hasListeners = NO;
}

#if RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeCameraRollModuleSpecJSI>(params);
}
#endif

@end
