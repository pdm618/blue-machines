#ifndef _STDLIB_H
#define _STDLIB_H

#include <stddef.h>

unsigned long strtoul(const char *cp,char **endp,unsigned int base);
long strtol(const char *cp,char **endp,unsigned int base);
unsigned long long strtoull(const char *cp,char **endp,unsigned int base);
long long strtoll(const char *cp,char **endp,unsigned int base);

int atoi(const char *nptr);
long atol(const char *nptr);
long long atoll(const char *nptr);

void *malloc(int size);
void free(void *);
#endif /* _STDLIB_H */
