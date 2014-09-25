# Standard output control
#SILENT  = @
TONULL  = 2> /dev/null

# Cross compilation definitions
CROSS   := $(TOOLCHAINPATH)arm-elf-

# Binutils and compilator
AS      := $(CROSS)as
CC      := $(CROSS)gcc
AR      := $(CROSS)ar
LD      := $(CROSS)ld
OBJDUMP := $(CROSS)objdump
OBJCOPY := $(CROSS)objcopy

# Shell commands
RM     := $(SILENT)rm -f
RMDIR  := $(SILENT)rmdir
MKDIR  := $(SILENT)mkdir
CP     := $(SILENT)cp -f
ECHO   := $(SILENT)echo

# Silent output implemetation
ifneq   ($(SILENT),)
.SILENT:
endif
