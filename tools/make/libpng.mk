#################################################################
## LIBPNG													  ##
#################################################################

LIBPNGVERSION := $(shell cat $(SOURCES) | jq -r '.libpng.version' )
LIBPNGARCHIVE := $(shell cat $(SOURCES) | jq -r '.libpng.archive' )
LIBPNGURI     := $(shell cat $(SOURCES) | jq -r '.libpng.uri' )


#################################################################
##                                                             ##
#################################################################

$(SOURCEDIR)/$(LIBPNGARCHIVE): $(SOURCEDIR)
	$(call box,"Downloading libpng source code")
	test -f $@ || $(DOWNLOADCMD) $@ $(LIBPNGURI) || rm -f $@


#################################################################
##                                                             ##
#################################################################

$(BUILDDIR)/libpng: $(SOURCEDIR)/$(LIBPNGARCHIVE) $(BUILDDIR)/zlib
	$(call box,"Building libpng")
	@mkdir -p $(BUILDDIR) && rm -rf $@-$(LIBPNGVERSION)
	@tar -xzf $(SOURCEDIR)/$(LIBPNGARCHIVE) -C $(BUILDDIR)
	@cd $@-$(LIBPNGVERSION)			\
	&& $(BUILDENV)					\
		./configure					\
			--prefix=$(PREFIXDIR)	\
			--disable-static		\
			--enable-shared			\
			--host=$(TARGET)		\
		&& make -j$(PROCS)			\
		&& make -j$(PROCS) install
	@rm -rf $@-$(LIBPNGVERSION)
	@touch $@


#################################################################
##                                                             ##
#################################################################
