//
//  ImageSaver.h
//  react-native-cameraroll
//

#import <React/RCTBridge.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageSaver : NSObject
@property (nonatomic, copy, nullable) void (^successHandle)(void);
@property (nonatomic, copy, nullable) void (^faildHandle)(NSError* error);

- (void) writeToPhoto: (UIImage*)image;
@end

NS_ASSUME_NONNULL_END
