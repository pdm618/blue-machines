#
# Library builder:
# 
# Input params:  LIBNAME         - library name (f.e. 'foo')
# Input files:   *.c *.s *.S     - source files
# Output:        lib$(LIBNAME).a - compiled library (f.e. 'libfoo.a')
#
include $(MENGINE)/env.mk

# Globals
LIBNAME  ?= noname

# Sources
CSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.c'))
ASOURCE   = $(patsubst ./%, %, $(shell find . -name '*.S'))
aSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.s'))

AOBJS     = $(patsubst %.S, %.o,$(ASOURCE))
AOBJS    += $(patsubst %.s, %.o,$(aSOURCE))
COBJS     = $(patsubst %.c, %.o,$(CSOURCE))
OBJS      = $(AOBJS)
OBJS     += $(COBJS)

# Targets
.PHONY: $(TARGETS)
LIBTARGET = lib$(LIBNAME).a

all: message $(LIBTARGET)

$(LIBTARGET): $(OBJS)
	$(ECHO) "   AR .. $(LIBTARGET)"
	$(AR) ru $(LIBTARGET) $(OBJS) $(TONULL)
	cd ..

%.o: %.c
	$(ECHO) "   CC .. $<"
	$(CC) $(CFLAGS) $< -o $@
  
%.o: %.s
	$(ECHO) "   As .. $<"
	$(CC) -E $< -o a.s
	$(AS) a.s $(ASFLAGS) -o $@
#	$(RM) a.s

%.o: %.S
	$(ECHO) "   AS .. $<"
	$(CC) -E $< > a.s
	$(AS) a.s $(ASFLAGS) -o $@
	$(RM) a.s
  
message:
	$(ECHO) "  Making library [ $(LIBNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"

clean:
	$(ECHO) "  Cleaning library [ $(LIBNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
	$(RM) $(LIBTARGET) $(OBJS) a.s
