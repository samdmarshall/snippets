#import <Foundation/Foundation.h>

@interface Foo : NSObject

- (int) doubleValue:(double)value withBlock:(int (^)(double value))block;

@end
