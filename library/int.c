#include "/Volumes/Programmation/Goose/goose/std/core/value.h"
#include "/Volumes/Programmation/Goose/goose/std/core/conversion.h"
#include "/Volumes/Programmation/Goose/goose/std/core/list.h"
#include <stdlib.h>

nanbox_t String_toInteger(nanbox_t args) {
  nanbox_t string = index_(args, 0);
  return integer(atoi(decode_string(string)));
}