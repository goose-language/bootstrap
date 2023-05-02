#include "env.h"
#include <stdlib.h>

extern VALUE index_(VALUE, int);
extern char* decode_string(VALUE);
extern VALUE integer(int);
extern VALUE string(char*);

VALUE Env_get(VALUE args) {
  VALUE key = index_(args, 1);
  char* value = getenv(decode_string(key));
  return string(value);
}

VALUE Env_set(VALUE args) {
  VALUE key = index_(args, 1);
  VALUE value = index_(args, 2);
  setenv(decode_string(key), decode_string(value), 1);
  return value;
}