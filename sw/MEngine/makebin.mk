SOURCE  = $(wildcard *.c)
OBJS    = $(STARTUPOBJ)
OBJS    += $(patsubst %.c,%.o,$(SOURCE))

PROGNAME        ?= noname
PROGFILE        ?= $(PROGNAME).elf
DUMPFILE        ?= $(PROGNAME).dump
FIRMWAREFILE    ?= $(PROGNAME).fw

LIBDEPS         = $(patsubst -l%,$(LIB)/lib%.a,$(LIBS))
.PHONY: $(TARGETS)

all: message $(FIRMWAREFILE)
$(PROGFILE): $(OBJS) $(LIBDEPS)
	$(ECHO) "   -------------------- Linking to $(LSCRIPT) ---------------------------------"
	$(ECHO) "   LD .. $(patsubst $(ROOT)/%,%,$(PROGFILE)) <- $(patsubst $(ROOT)/%.o,%.o,$(OBJS))  $(patsubst -l%,lib%.a, $(ALLLIBS))"
	$(LD) -o $(PROGFILE) $(OBJS) $(LDFLAGS)
	$(ECHO) "   ----------------------------------------------------------------------------"
	$(ECHO) "   Executable created successfully. Build No: $(BUILD_NUMBER)"
	$(ECHO) "   ----------------------------------------------------------------------------"
	$(BUILD_NO)
	$(ECHO) "   OD .. $(patsubst $(ROOT)/%,%,$(DUMPFILE))"
	$(OBJDUMP) -SD $(PROGFILE) > $(DUMPFILE)
$(FIRMWAREFILE): $(PROGFILE)
	$(RM) $(FIRMWAREFILE) $(EXTFIRMWAREFILE)
	$(ECHO) "   FW .. $(patsubst $(ROOT)/%,%,$(FIRMWAREFILE))"
	$(OBJCOPY) -O binary $(PROGFILE) $(FIRMWAREFILE)
	$(ECHO) "   CP .. $(patsubst $(ROOT)/%,%,$(FIRMWAREFILE)) -> $(FIRMWAREDIR)"
	$(CP) $(FIRMWAREFILE) $(FIRMWAREDIR)
%.o: %.c
	$(ECHO) "   CC .. $<"
	$(CC) $(CFLAGS) $< -o $@
message:
	$(ECHO) "  Making executable [ $(PROGNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
clean:
	$(ECHO) "  Cleaning executable [ $(PROGNAME) ] in [ $(patsubst $(ROOT)%,.%, $(shell pwd)) ]"
	$(RM) $(PROGFILE) $(DUMPFILE) $(FIRMWAREFILE) $(EXTFIRMWAREFILE) $(OBJS)
test:
