#################################################################
## WGET													       ##
#################################################################

WGETVERSION := $(shell cat $(SOURCES) | jq -r '.wget.version' )
WGETARCHIVE := $(shell cat $(SOURCES) | jq -r '.wget.archive' )
WGETURI     := $(shell cat $(SOURCES) | jq -r '.wget.uri' )


#################################################################
##                                                             ##
#################################################################

$(SOURCEDIR)/$(WGETARCHIVE): $(SOURCEDIR)
	$(call box,"Downloading wget source code")
	test -f $@ || $(DOWNLOADCMD) $@ $(WGETURI) || rm -f $@


#################################################################
##                                                             ##
#################################################################

$(BUILDDIR)/wget: $(SOURCEDIR)/$(WGETARCHIVE) $(BUILDDIR)/openssl $(BUILDDIR)/zlib $(BUILDDIR)/pcre
	$(call box,"Building wget")
	@mkdir -p $(BUILDDIR) && rm -rf $@-$(WGETVERSION)
	@tar -xzf $(SOURCEDIR)/$(WGETARCHIVE) -C $(BUILDDIR)
	@cd $@-$(WGETVERSION)			          \
	&& $(BUILDENV)						      \
	CPPFLAGS="-I$(PREFIXDIR)/include/openssl -I$(PREFIXDIR)/include -L$(PREFIXDIR)/lib" \
	LDFLAGS=" -I$(PREFIXDIR)/include/openssl -I$(PREFIXDIR)/include -L$(PREFIXDIR)/lib -Wl,-rpath -Wl,/tmp/sd/firmware/lib -Wl,--enable-new-dtags" \
		./configure					   	      \
			--host=$(TARGET)		   	      \
			--prefix=$(PREFIXDIR)	   	      \
			--with-libssl-prefix=$(PREFIXDIR) \
			--with-ssl=openssl                \
			--with-openssl=yes                \
			--with-zlib                       \
			--with-metalink                   \
			--without-included-regex          \
			--enable-nls                      \
			--enable-dependency-tracking      \
			--disable-ipv6                    \
		&& make -j$(PROCS)				      \
		&& make -j$(PROCS) install
	@rm -rf $@-$(WGETVERSION)
	@touch $@


#################################################################
##                                                             ##
#################################################################
