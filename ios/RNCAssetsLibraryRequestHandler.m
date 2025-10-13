/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCAssetsLibraryRequestHandler.h"

#import <stdatomic.h>
#import <dlfcn.h>
#import <objc/runtime.h>

//#import <Photos/Photos.h>
//#import <MobileCoreServices/MobileCoreServices.h>

#import <React/RCTBridge.h>
#import <React/RCTNetworking.h>
#import <React/RCTUtils.h>

@implementation RNCAssetsLibraryRequestHandler

NSString *const PHUploadScheme = @"ph-upload";

RCT_EXPORT_MODULE()

#pragma mark - RNCURLRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request
{
  // Since we can't use Photos framework without NSPhotoLibraryUsageDescription,
  // we'll disable handling of ph:// and assets-library:// URLs
  return NO;
}

- (id)sendRequest:(NSURLRequest *)request
     withDelegate:(id<RCTURLRequestDelegate>)delegate
{
  // Return a cancellation block that does nothing
  void (^cancellationBlock)(void) = ^{
    // Do nothing since we're not handling any requests
  };

  // Immediately fail the request with an appropriate error
  NSString *const msg = [NSString stringWithFormat:@"Photo library access is not available in this app configuration"];
  NSError *error = [NSError errorWithDomain:@"RNCCameraRollError"
                                       code:1001
                                   userInfo:@{NSLocalizedDescriptionKey: msg}];
  [delegate URLRequest:cancellationBlock didCompleteWithError:error];

  return cancellationBlock;
}

- (void)cancelRequest:(id)requestToken
{
  if (requestToken) {
    ((void (^)(void))requestToken)();
  }
}

@end
