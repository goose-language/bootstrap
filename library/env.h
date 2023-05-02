#ifndef ENV_H
#define ENV_H

#include <stdlib.h>

typedef uint64_t VALUE;

VALUE Env_get(VALUE args);
VALUE Env_set(VALUE args);


#endif