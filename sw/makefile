include config.mk
include $(MENGINE)/env.mk
#include projconf.mk

export BUILDDIR = $(ROOT).build/
export OBJDIR   = $(BUILDDIR).objs/
export LIBDIR   = $(BUILDDIR).libs/
BINDIR          = $(BUILDDIR).bin/

DIRTARGETS := $(BUILDDIR) $(OBJDIR) $(LIBDIR) $(BINDIR)

# To be moved to "projconf.mk"
LIBS       := boot os slibc app
ELF        := $(BINDIR)$(PROGNAME).elf
FW         := $(BINDIR)$(PROGNAME).fw
HEX        := $(BINDIR)$(PROGNAME).hex

CRT0       := $(OBJDIR)boot/crt0.o
LIBTARGETS := $(patsubst %,$(LIBDIR)lib%.a,$(LIBS))
LDFLAGS    := -Tlinker/lpc2378.lds -nostdlib -nostartfiles
EXTRACTDIR = $(patsubst lib%.a,%,$(notdir $@))

.PHONY: all clean

all: $(FW)
$(FW): $(ELF)
	$(OBJCOPY) -O binary $(ELF) $(FW)
	$(OBJCOPY) -O ihex $(ELF) $(HEX)
  
$(ELF): $(DIRTARGETS) $(LIBTARGETS)
	$(LD) $(LDFLAGS) -o $@ $(CRT0) $(filter %.a,$^) 

$(DIRTARGETS):
	$(MKDIR) -p $@

$(LIBTARGETS):
	$(MAKE) -C $(EXTRACTDIR) LIB=$(notdir $@) OBJDIR=$(OBJDIR)$(EXTRACTDIR)/|| exit 1

clean:
	$(ECHO) "Cleaning..."
	$(RM) -r $(DIRTARGETS)
	$(ECHO) "... done"

veryclean:
	find -type d -name .obj -exec rm -rf '{}' \;; find -type d -name .lib -exec rm -rf '{}' \;; \
  find -type f -name *.o -exec  rm  -f '{}' \;; find -type f -name *.a  -exec rm  -f '{}' \;;
