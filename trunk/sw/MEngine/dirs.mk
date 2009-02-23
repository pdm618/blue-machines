include $(MENGINE)/env.mk

.PHONY: $(TARGETS) $(SUBDIRS)

$(TARGETS):
	for dir in $(SUBDIRS) ; do   \
	    $(MAKE) -C $$dir -f makefile.tree $@ || exit 1 ;  \
	done
