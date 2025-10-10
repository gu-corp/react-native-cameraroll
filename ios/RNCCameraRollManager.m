/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCCameraRollManager.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <objc/runtime.h>

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

#import "ImageSaver.h"
#import "RNCAssetsLibraryRequestHandler.h"

@implementation RNCCameraRollManager

RCT_EXPORT_MODULE(RNCCameraRoll)

@synthesize bridge = _bridge;

static NSString *const kErrorUnableToSave = @"E_UNABLE_TO_SAVE";
static NSString *const kErrorUnableToLoad = @"E_UNABLE_TO_LOAD";
static NSString *const kErrorAuthRestricted = @"E_PHOTO_LIBRARY_AUTH_RESTRICTED";
static NSString *const kErrorAuthDenied = @"E_PHOTO_LIBRARY_AUTH_DENIED";

typedef void (^PhotosAuthorizedBlock)(bool isLimited);

RCT_EXPORT_METHOD(saveToLibrary:(NSURLRequest *)request
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    ImageSaver *imgManager = [[ImageSaver alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:request.URL];
    UIImage *image = [UIImage imageWithData:data];
    
    imgManager.successHandle = ^{
        resolve(request.URL.absoluteString);
    };
    
    imgManager.faildHandle = ^void(NSError* error){
        if ([error.domain isEqual:@"ALAssetsLibraryErrorDomain"]) {
            reject(kErrorAuthDenied, @"Access to photo library is restricted", nil);
        } else {
            reject(kErrorUnableToSave, nil, error);
        }
    };
    
    [imgManager writeToPhoto:image];
}

// Fallback method for compatibility
RCT_EXPORT_METHOD(saveToCameraRoll:(NSURLRequest *)request
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [self saveToLibrary:request resolve:resolve reject:reject];
}

// Fallback method for compatibility
RCT_EXPORT_METHOD(save:(NSURLRequest *)request
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [self saveToLibrary:request resolve:resolve reject:reject];
}

// Disable other methods that require Photos framework
RCT_EXPORT_METHOD(getPhotos:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

RCT_EXPORT_METHOD(getAlbums:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

RCT_EXPORT_METHOD(deletePhotos:(NSArray<NSString *>*)assets
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

@end
