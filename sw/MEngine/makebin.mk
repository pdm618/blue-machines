include $(MENGINE)/env.mk

# Sources
CSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.c'))
ASOURCE   = $(patsubst ./%, %, $(shell find . -name '*.S'))
aSOURCE   = $(patsubst ./%, %, $(shell find . -name '*.s'))

AOBJS     = $(patsubst %.S, %.o,$(ASOURCE))
AOBJS    += $(patsubst %.s, %.o,$(aSOURCE))
COBJS     = $(patsubst %.c, %.o,$(CSOURCE))
OBJS      = $(AOBJS)
OBJS     += $(COBJS)

PROGNAME        ?= noname
PROGFILE        ?= $(PROGNAME).elf
DUMPFILE        ?= $(PROGNAME).dump
FIRMWAREFILE    ?= $(PROGNAME).fw

LDFLAGS     += $(patsubst -l%,lib%.a,$(LIBFILES))

.PHONY: $(TARGETS)

all: message $(FIRMWAREFILE)
$(FIRMWAREFILE): $(PROGFILE)
	$(RM) $(FIRMWAREFILE)
	$(ECHO) "   FW .. $(patsubst $(ROOT)/%,%,$(FIRMWAREFILE))"
	$(OBJCOPY) -O binary $(PROGFILE) $(FIRMWAREFILE)
$(PROGFILE): $(OBJS) $(LIBS)
	$(ECHO) "   -------------------- Linking to $(LSCRIPT) ---------------------------------"
	$(ECHO) "   LD .. $(patsubst $(ROOT)/%,%,$(PROGFILE)) <- $(patsubst $(ROOT)/%.o,%.o,$(OBJS))  $(patsubst -l%,lib%.a, $(ALLLIBS))"
	$(LD) -o $(PROGFILE) $(OBJS) $(LDFLAGS)
	$(ECHO) "   ----------------------------------------------------------------------------"
	$(ECHO) "   Executable created successfully. Build No: $(BUILD_NUMBER)"
	$(ECHO) "   ----------------------------------------------------------------------------"
	$(ECHO) "   OD .. $(patsubst $(ROOT)/%,%,$(DUMPFILE))"
	$(OBJDUMP) -SD $(PROGFILE) > $(DUMPFILE)
%.o: %.c
	$(ECHO) "   CC .. $<"
	$(CC) $(CFLAGS) $< -o $@
message:
	$(ECHO) "  Making executable [ $(PROGNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
clean:
	$(ECHO) "  Cleaning executable [ $(PROGNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
	$(RM) $(PROGFILE) $(DUMPFILE) $(FIRMWAREFILE) $(OBJS)
