#include "blocks.h"
#include <math.h>

int doubleValueWithBlock(double value, DoubleBlock block) {
  return floor(2 * block(value));
}

