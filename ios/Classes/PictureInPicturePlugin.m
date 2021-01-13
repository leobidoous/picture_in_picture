#import "PictureInPicturePlugin.h"
#if __has_include(<picture_in_picture/picture_in_picture-Swift.h>)
#import <picture_in_picture/picture_in_picture-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "picture_in_picture-Swift.h"
#endif

@implementation PictureInPicturePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPictureInPicturePlugin registerWithRegistrar:registrar];
}
@end
