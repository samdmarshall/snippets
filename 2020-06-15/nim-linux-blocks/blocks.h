#include <stdlib.h>
#include <Block.h>

typedef int (^DoubleBlock)(double value);

int doubleValueWithBlock(double value, DoubleBlock block);
