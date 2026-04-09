/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#ifdef RCT_NEW_ARCH_ENABLED
#import <rncameraroll/rncameraroll.h>
#else
#import <React/RCTBridge.h>
#endif
#import <React/RCTEventEmitter.h>
#import <React/RCTConvert.h>


@interface RNCCameraRoll : RCTEventEmitter
#ifdef RCT_NEW_ARCH_ENABLED
                                   <NativeCameraRollModuleSpec>
#else
                                   <RCTBridgeModule>
#endif

@end
