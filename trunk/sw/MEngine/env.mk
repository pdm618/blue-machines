# Standard output control
#.SUFFIXES:
SILENT  = @
#@
TONULL  = 2> /dev/null

# Cross compilation definitions
CROSS   = $(TOOLCHAINPATH)arm-elf-

# Binutils and compilator
AS      = $(CROSS)as
CC      = $(CROSS)gcc
AR      = $(CROSS)ar
LD      = $(CROSS)ld
OBJDUMP = $(CROSS)objdump
OBJCOPY = $(CROSS)objcopy

# Shell commands
RM      = $(SILENT)rm -f
RMDIR   = $(SILENT)rmdir
MKDIR   = $(SILENT)mkdir
CP      = $(SILENT)cp -f
ECHO    = $(SILENT)echo

# TODO: remove this to separate file (e.g. platform specific file)
# Compiler options section
CFLAGS  = -nostdinc -fno-builtin -c
CFLAGS += $(INCLUDE)

# Silent output implemetation
ifneq   ($(SILENT),)
.SILENT:
endif
