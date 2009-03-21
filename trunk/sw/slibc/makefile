CCINCS	= $(shell $(CC) -print-search-dirs | grep install | cut -f2 -d' ')/include
INCDIRS	= include include/arch $(CCINCS)
INCLUDE	= $(foreach f, $(INCDIRS), -I$(f) )

include $(MENGINE)/makelib.mk
