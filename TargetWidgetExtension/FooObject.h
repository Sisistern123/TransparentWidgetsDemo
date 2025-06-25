// FooObject.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FooObject : NSObject

/// This is implemented in FooObject.mm; it builds the private
/// CHSMutableWidgetDescriptor for “clear” (false) or “blur” (true).
+ (id)makeBackgroundDescriptor:(BOOL)isBlur;

@end

NS_ASSUME_NONNULL_END
