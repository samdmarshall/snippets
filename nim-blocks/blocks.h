#import <Foundation/Foundation.h>

@interface Foo : NSObject

- (int) doubleValue:(double)value withBlock:(int (^double_it)(double value))block- (int) doubleValue:(int (^double_it)(double)) block;

@end
