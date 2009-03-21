#
# Library builder:
# 
# Input params:  LIBTARGET       - target file
# Input files:   *.c *.s *.S     - source files
#
include $(MENGINE)/env.mk

# Globals
ifeq ($(LIB),)
$(error LIB is not specified)
endif
LIBTARGET := $(addprefix $(LIBDIR),$(LIB))
# Sources
CSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.c'))
ASOURCE   = $(patsubst ./%, %, $(shell find . -name '*.S'))
aSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.s'))

AOBJS     = $(patsubst %.S, %.o,$(ASOURCE))
AOBJS    += $(patsubst %.s, %.o,$(aSOURCE))
COBJS     = $(patsubst %.c, %.o,$(CSOURCE))
OBJS      = $(AOBJS)
OBJS     += $(COBJS)

OBJTARGETS = $(addprefix $(OBJDIR), $(OBJS))
OBJDIRTARGETS = $(sort $(foreach dir,$(OBJTARGETS),$(dir $(OBJTARGETS))))
CFLAGS   += -c $(INCLUDE)

LIBNAME = $(patsubst lib%.a,%,$(notdir $(LIBTARGET)))

# Targets
.PHONY: message

all: message $(LIBTARGET)

$(LIBTARGET): $(OBJDIRTARGETS) $(OBJTARGETS)
	$(ECHO) "   AR .. $(LIBTARGET)"
	$(AR) ru $(LIBTARGET) $(filter %.a %.o,$^) $(TONULL)

$(OBJDIRTARGETS):
	$(ECHO) "   MKDIR .. $@"
	$(MKDIR) -p $@

$(OBJDIR)%.o: %.c
	$(ECHO) "   CC .. $<"
	$(CC) $(CFLAGS) $< -o $@
  
$(OBJDIR)%.o: %.s
	$(ECHO) "   As .. $<"
	$(CC) -E $< -o a.s
	$(AS) a.s $(ASFLAGS) -o $@
	$(RM) a.s

$(OBJDIR)%.o: %.S
	$(ECHO) "   AS .. $<"
	$(CC) -E $< > a.s
	$(AS) a.s $(ASFLAGS) -o $@
	$(RM) a.s
  
message:
	$(ECHO) "  Making library [ $(LIBNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]" 

clean:
	$(ECHO) "  Cleaning library [ $(LIBNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
	$(RM) $(LIBTARGET) $(OBJS) a.s
