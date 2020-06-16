
#include "blocks.h"
#include <stdio.h>

static DoubleBlock add5 = ^int(double a) { return (a + 5.0); };


int main(const int argc, const char* argv[]) {
  float value = 2.5f;
  printf("value = %f\n", value);

  DoubleBlock block = add5;
  printf("add5 = ^int(double a) { return (a + 5.0); }\n");

  int result = doubleValueWithBlock(value, block);
  printf("doubleValueWithBlock(%f, add5) = %i\n", value, result);

  return 0;
}
