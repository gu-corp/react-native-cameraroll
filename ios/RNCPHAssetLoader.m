/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RNCPHAssetLoader.h"

#if RCT_NEW_ARCH_ENABLED

#import <React/RCTUtils.h>

// NOTE: Photos.framework dependency removed to allow this library to be used
// in apps (such as in-app browsers) that must not link Photos.framework.
// This loader is therefore a no-op stub: it never claims it can load any URL.

@implementation RNCPHAssetLoader

RCT_EXPORT_MODULE()

#pragma mark - RCTImageURLLoader

- (BOOL)canLoadImageURL:(NSURL *)requestURL {
  return NO;
}

- (RCTImageLoaderCancellationBlock)loadImageForURL:(NSURL *)imageURL
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(RCTResizeMode)resizeMode
                                   progressHandler:(RCTImageLoaderProgressBlock)progressHandler
                                partialLoadHandler:(RCTImageLoaderPartialLoadBlock)partialLoadHandler
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler {
  completionHandler(RCTErrorWithMessage(@"ph:// / assets-library:// schemes are not supported in this build (Photos.framework is not linked)."), nil);
  return ^{};
}

@end

#endif
