#import <React/RCTUtils.h>
#import "RNCPermissionHelper.h"

// NOTE: Photos.framework dependency removed to allow this library to be used
// in apps (such as in-app browsers) that must not link Photos.framework
// (avoids requiring NSPhotoLibraryUsageDescription and Apple review issues).
//
// All permission methods are stubbed: since the library no longer reads from
// the photo library, no permission is required for `saveToLibrary`
// (UIImageWriteToSavedPhotosAlbum prompts the user for "Add Only" permission
// automatically when needed).

@implementation RNCPermissionHelper

+ (void)checkCameraRollPermission:(NSString *) accessLevel
                         resolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                         rejecter:(void (^ _Nonnull)(NSString *code, NSString *message))reject {
  resolve(RNPermissionStatusAuthorized);
}

+ (void)requestCameraRollReadWritePermission:(void (^ _Nonnull)(RNPermissionStatus))resolve
                                    rejecter:(void (^ _Nonnull)(NSString *code, NSString *message))reject {
  resolve(RNPermissionStatusAuthorized);
}

+ (void)requestCameraRollAddOnlyPermission:(void (^ _Nonnull)(RNPermissionStatus))resolve
                                    rejecter:(void (^ _Nonnull)(NSString *code, NSString *message))reject {
  resolve(RNPermissionStatusAuthorized);
}

+ (void)refreshLimitedPhotoselection:(RCTPromiseResolveBlock _Nonnull)resolve
                                         rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  reject(@"cannot_open_limited_picker", @"Limited photo picker is not supported in this build (Photos.framework is not linked).", nil);
}

@end
