/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCPHAssetUploader.h"

#if RCT_NEW_ARCH_ENABLED

#import <React/RCTUtils.h>

// NOTE: Photos.framework dependency removed to allow this library to be used
// in apps (such as in-app browsers) that must not link Photos.framework.
// This uploader is therefore a no-op stub.

@implementation RNCPHAssetUploader

RCT_EXPORT_MODULE()

NSString *const PHUploadScheme = @"ph-upload";

- (BOOL)canHandleRequest:(NSURLRequest *)request {
  return NO;
}

- (id)sendRequest:(NSURLRequest *)request withDelegate:(id<RCTURLRequestDelegate>)delegate {
  void (^cancellationBlock)(void) = ^{};
  NSString *const msg = @"ph-upload:// scheme is not supported in this build (Photos.framework is not linked).";
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
