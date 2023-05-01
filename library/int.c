#include <stdlib.h>

typedef uint64_t VALUE;

extern VALUE index_(VALUE, int);
extern char* decode_string(VALUE);
extern VALUE integer(int);

VALUE String_toInteger(VALUE args) {
  VALUE string = index_(args, 1);
  return integer(atoi(decode_string(string)));
}