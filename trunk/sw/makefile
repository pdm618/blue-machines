include config.mk

PROGNAME      = blue-machines

export OBJDIR = ./.obj/
#export LIBDIR = $(ROOT)/.lib/

TARGETS ?= all clean message
export TARGETS

#APPDIR       = app
INCDIR       = include
SUBDIRS      = boot libs os/freertos
include $(MENGINE)/env.mk
include $(MENGINE)/dirs.mk

veryclean:
	find -type d -name .obj -exec rm -rf '{}' \;; find -type d -name .lib -exec rm -rf '{}' \;; \
  find -type f -name *.o -exec  rm  -f '{}' \;; find -type f -name *.a  -exec rm  -f '{}' \;;
