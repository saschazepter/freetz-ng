$(call TOOLS_INIT, 3.5.1)
$(PKG)_LIB_VERSION:=3
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f
$(PKG)_SITE:=https://www.openssl.org/source,https://github.com/openssl/openssl/releases/download/openssl-$($(PKG)_VERSION)
### WEBSITE:=https://www.openssl.org/source/
### MANPAGE:=https://www.openssl.org/docs/
### CHANGES:=https://www.openssl.org/news/changelog.html
### CVSREPO:=https://github.com/openssl/openssl
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=patchelf-host

$(PKG)_TARGET_BINARY      := $(TOOLS_DIR)/openssl
$(PKG)_DESTDIR            := $(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)/freetz
$(PKG)_INSTALLDIR         := $(OPENSSL_HOST_DIR)/installdir

# Makefile is regenerated by configure
$(PKG)_PATCH_POST_CMDS += $(RM) Makefile Makefile.bak;
$(PKG)_PATCH_POST_CMDS += ln -s Configure configure;

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(OPENSSL_HOST_INSTALLDIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(OPENSSL_HOST_DIR) all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(OPENSSL_HOST_DIR) install_sw
	@[ -d $(OPENSSL_HOST_INSTALLDIR)/lib ] || ln -sf lib64 $(OPENSSL_HOST_INSTALLDIR)/lib
	@mkdir -p $(OPENSSL_HOST_DESTDIR)/
	cp -a $(OPENSSL_HOST_DIR)/{libcrypto,libssl}.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_DESTDIR)/
	cp -a $(OPENSSL_HOST_DIR)/apps/openssl $(OPENSSL_HOST_TARGET_BINARY)
	$(call OPENSSL_HOST_FIXHARDCODED)
	@touch $@

define $(PKG)_FIXHARDCODED
	@$(PATCHELF) --replace-needed $(1)libcrypto.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_DESTDIR)/libcrypto.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_DESTDIR)/libssl.so.$(OPENSSL_HOST_LIB_VERSION)
	@for libfile in libcrypto libssl; do \
	$(PATCHELF) --replace-needed $(1)$${libfile}.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_DESTDIR)/$${libfile}.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_TARGET_BINARY) ;\
	done ;
endef

$(pkg)-fixhardcoded:
	$(call OPENSSL_HOST_FIXHARDCODED,$(TOOLS_HARDCODED_DIR)/freetz/)

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(OPENSSL_HOST_DIR) clean
	$(RM) $(OPENSSL_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(OPENSSL_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(OPENSSL_HOST_DESTDIR)/{libcrypto,libssl}.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
