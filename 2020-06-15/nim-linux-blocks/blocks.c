#include "blocks.h"
#include <math.h>
#include <stdio.h>

int doubleValueWithBlock(double value, DoubleBlock block) {
  printf("value: %f\n", value);
  printf("block: %p\n", block);
  int result = block(value);
  printf("result: %i\n", result);
  int answer = floor(2 * result);
  printf("answer: %i\n", answer);
  return answer;
}

