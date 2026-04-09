//
//  ImageSaver.m
//  react-native-cameraroll
//

#import "ImageSaver.h"
#import <UIKit/UIKit.h>
#import <React/RCTBridge.h>

@implementation ImageSaver

- (void) writeToPhoto: (UIImage*)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(handleImage:didFinishSavingWithError:contextInfo:), nil);
}

- (void)handleImage:(UIImage *)image
    didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    if (error == nil) {
        if (_successHandle) {
            _successHandle();
        }
    } else {
        if (_faildHandle) {
            _faildHandle(error);
        }
    }
}
@end
