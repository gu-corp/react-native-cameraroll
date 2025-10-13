/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCCameraRollManager.h"

//#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <Photos/Photos.h>
#import <dlfcn.h>
#import <objc/runtime.h>
//#import <MobileCoreServices/UTType.h>

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

#import "ImageSaver.h"

#import "RNCAssetsLibraryRequestHandler.h"

//@implementation RCTConvert (PHAssetCollectionSubtype)
//
//RCT_ENUM_CONVERTER(PHAssetCollectionSubtype, (@{
//   @"album": @(PHAssetCollectionSubtypeAny),
//   @"all": @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
//   @"event": @(PHAssetCollectionSubtypeAlbumSyncedEvent),
//   @"faces": @(PHAssetCollectionSubtypeAlbumSyncedFaces),
//   @"library": @(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
//   @"photo-stream": @(PHAssetCollectionSubtypeAlbumMyPhotoStream), // incorrect, but legacy
//   @"photostream": @(PHAssetCollectionSubtypeAlbumMyPhotoStream),
//   @"saved-photos": @(PHAssetCollectionSubtypeAny), // incorrect, but legacy correspondence in PHAssetCollectionSubtype
//   @"savedphotos": @(PHAssetCollectionSubtypeAny), // This was ALAssetsGroupSavedPhotos, seems to have no direct correspondence in PHAssetCollectionSubtype
//}), PHAssetCollectionSubtypeAny, integerValue)
//
//
//@end

//@implementation RCTConvert (PHFetchOptions)
//
//+ (PHFetchOptions *)PHFetchOptionsFromMediaType:(NSString *)mediaType
//                                       fromTime:(NSUInteger)fromTime
//                                         toTime:(NSUInteger)toTime
//{
//  // This is not exhaustive in terms of supported media type predicates; more can be added in the future
//  NSString *const lowercase = [mediaType lowercaseString];
//  NSMutableArray *format = [NSMutableArray new];
//  NSMutableArray *arguments = [NSMutableArray new];
//
//  if ([lowercase isEqualToString:@"photos"]) {
//    [format addObject:@"mediaType = %d"];
//    [arguments addObject:@(PHAssetMediaTypeImage)];
//  } else if ([lowercase isEqualToString:@"videos"]) {
//    [format addObject:@"mediaType = %d"];
//    [arguments addObject:@(PHAssetMediaTypeVideo)];
//  } else {
//    if (![lowercase isEqualToString:@"all"]) {
//      RCTLogError(@"Invalid filter option: '%@'. Expected one of 'photos',"
//                  "'videos' or 'all'.", mediaType);
//    }
//  }
//
//  if (fromTime > 0) {
//    NSDate* fromDate = [NSDate dateWithTimeIntervalSince1970:fromTime/1000];
//    [format addObject:@"creationDate > %@"];
//    [arguments addObject:fromDate];
//  }
//  if (toTime > 0) {
//    NSDate* toDate = [NSDate dateWithTimeIntervalSince1970:toTime/1000];
//    [format addObject:@"creationDate <= %@"];
//    [arguments addObject:toDate];
//  }
//
//  // This case includes the "all" mediatype
//  PHFetchOptions *const options = [PHFetchOptions new];
//  if ([format count] > 0) {
//    options.predicate = [NSPredicate predicateWithFormat:[format componentsJoinedByString:@" AND "] argumentArray:arguments];
//  }
//  return options;
//}
//
//@end

@implementation RNCCameraRollManager

RCT_EXPORT_MODULE(RNCCameraRoll)

@synthesize bridge = _bridge;

static NSString *const kErrorUnableToSave = @"E_UNABLE_TO_SAVE";
static NSString *const kErrorUnableToLoad = @"E_UNABLE_TO_LOAD";

static NSString *const kErrorAuthRestricted = @"E_PHOTO_LIBRARY_AUTH_RESTRICTED";
static NSString *const kErrorAuthDenied = @"E_PHOTO_LIBRARY_AUTH_DENIED";

typedef void (^PhotosAuthorizedBlock)(bool isLimited);

//static void requestPhotoLibraryAccess(RCTPromiseRejectBlock reject, PhotosAuthorizedBlock authorizedBlock) {
//  PHAuthorizationStatus authStatus;
//  if (@available(iOS 14, *)) {
//    authStatus = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
//  } else {
//    authStatus = [PHPhotoLibrary authorizationStatus];
//  }
//  if (authStatus == PHAuthorizationStatusRestricted) {
//    reject(kErrorAuthRestricted, @"Access to photo library is restricted", nil);
//  } else if (authStatus == PHAuthorizationStatusAuthorized) {
//    authorizedBlock(false);
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunguarded-availability-new"
//  } else if (authStatus == PHAuthorizationStatusLimited) {
//#pragma clang diagnostic pop
//    authorizedBlock(true);
//  } else if (authStatus == PHAuthorizationStatusNotDetermined) {
//      if (@available(iOS 14, *)) {
//          [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus status) {
//              requestPhotoLibraryAccess(reject, authorizedBlock);
//          }];
//      } else {
//          [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//              requestPhotoLibraryAccess(reject, authorizedBlock);
//          }];
//      }
//  } else {
//    reject(kErrorAuthDenied, @"Access to photo library was denied", nil);
//  }
//}

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

RCT_EXPORT_METHOD(saveToCameraRoll:(NSURLRequest *)request
                  options:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  [self saveToLibrary:request resolve:resolve reject:reject];
}

// Disable other methods that require Photos framework
RCT_EXPORT_METHOD(getAlbums:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

static void RCTResolvePromise(RCTPromiseResolveBlock resolve,
                              NSArray<NSDictionary<NSString *, id> *> *assets,
                              BOOL hasNextPage,
                              bool isLimited)
{
  if (!assets.count) {
    resolve(@{
      @"edges": assets,
      @"page_info": @{
        @"has_next_page": @NO,
      },
      @"limited": @(isLimited)
    });
    return;
  }
  resolve(@{
    @"edges": assets,
    @"page_info": @{
      @"start_cursor": assets[0][@"node"][@"image"][@"uri"],
      @"end_cursor": assets[assets.count - 1][@"node"][@"image"][@"uri"],
      @"has_next_page": @(hasNextPage),
    },
    @"limited": @(isLimited)
  });
}

// Disable other methods that require Photos framework
RCT_EXPORT_METHOD(getPhotos:(NSDictionary *)params
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

// Disable other methods that require Photos framework
RCT_EXPORT_METHOD(deletePhotos:(NSArray<NSString *>*)assets
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
  reject(kErrorUnableToLoad, @"Photo library access is not available in this app configuration", nil);
}

//static void checkPhotoLibraryConfig()
//{
//#if RCT_DEV
//  if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"]) {
//    RCTLogError(@"NSPhotoLibraryUsageDescription key must be present in Info.plist to use camera roll.");
//  }
//#endif
//}

@end
