#include "/Volumes/Programmation/Goose/goose/std/core/value.h"
#include "/Volumes/Programmation/Goose/goose/std/core/conversion.h"
#include "/Volumes/Programmation/Goose/goose/std/core/list.h"
#include <stdlib.h>

Value* String_toInteger(Value* args) {
  Value* string = index_(args, 0);
  return integer(atoi(toString(string)));
}