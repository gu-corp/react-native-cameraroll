/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCAssetsLibraryRequestHandler.h"

#if RCT_NEW_ARCH_ENABLED
// on new arch, we have RNCPHAssetLoader and RNCPHUploader.
#else

#import <React/RCTBridge.h>
#import <React/RCTUtils.h>

// NOTE: Photos.framework dependency removed to allow this library to be used
// in apps (such as in-app browsers) that must not link Photos.framework
// (avoids requiring NSPhotoLibraryUsageDescription and Apple review issues).

@implementation RNCAssetsLibraryRequestHandler

NSString *const PHUploadScheme = @"ph-upload";

RCT_EXPORT_MODULE()

#pragma mark - RNCURLRequestHandler

- (BOOL)canHandleRequest:(NSURLRequest *)request
{
  // We no longer support ph://, assets-library:// or ph-upload:// because
  // they require Photos.framework which is intentionally not linked.
  return NO;
}

- (id)sendRequest:(NSURLRequest *)request
     withDelegate:(id<RCTURLRequestDelegate>)delegate
{
  void (^cancellationBlock)(void) = ^{};
  NSString *const msg = @"ph:// / assets-library:// schemes are not supported in this build (Photos.framework is not linked).";
  [delegate URLRequest:cancellationBlock didCompleteWithError:RCTErrorWithMessage(msg)];
  return cancellationBlock;
}

- (void)cancelRequest:(id)requestToken
{
  if (requestToken) {
    ((void (^)(void))requestToken)();
  }
}

@end


#endif
