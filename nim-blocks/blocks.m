#import "blocks.h"

@implementation Foo

- (int) doubleValue:(double)value withBlock:(int (^)(double))block {
    return floor(2 * block(value));
}

@end
