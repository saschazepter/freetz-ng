$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL2),1.4.11.1,$(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL3),1.4.21,$(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL4),1.6.2,1.8.11))))
$(PKG)_KERNNBR:=$(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL2),2,$(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL3),3,$(if $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL4),4,5)))
$(PKG)_SOURCE_EXT2:=bz2
$(PKG)_SOURCE_EXT3:=bz2
$(PKG)_SOURCE_EXT4:=bz2
$(PKG)_SOURCE_EXT5:=xz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$($(PKG)_SOURCE_EXT$($(PKG)_KERNNBR))
$(PKG)_HASH_KERNEL2:=170c294698ca573477b1b2a3815e1563bf9929d182efef6cf0331a6e955c9ade
$(PKG)_HASH_KERNEL3:=52004c68021da9a599feed27f65defcfb22128f7da2c0531c0f75de0f479d3e0
$(PKG)_HASH_KERNEL4:=55d02dfa46263343a401f297d44190f2a3e5113c8933946f094ed40237053733
$(PKG)_HASH_KERNEL5:=d87303d55ef8c92bcad4dd3f978b26d272013642b029425775f5bad1009fe7b2
$(PKG)_HASH:=$($(PKG)_HASH_KERNEL$($(PKG)_KERNNBR))
$(PKG)_SITE:=https://netfilter.org/projects/iptables/files
### WEBSITE:=https://netfilter.org/projects/iptables/index.html
### CHANGES:=https://netfilter.org/projects/iptables/downloads.html
### CVSREPO:=https://git.netfilter.org/iptables/
### SUPPORT:=fda77

$(PKG)_CONDITIONAL_PATCHES+=kernel$($(PKG)_KERNNBR)
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL2)),y)
$(PKG)_CONDITIONAL_PATCHES+=kernel$($(PKG)_KERNNBR)/$(KERNEL_VERSION_MAJOR)
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPTABLES_XML
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPTABLES_STATIC

$(PKG)_BINARY_NAME2 := xtables-multi
$(PKG)_BINARY_NAME3 := xtables-multi
$(PKG)_BINARY_NAME4 := xtables-multi
$(PKG)_BINARY_NAME5 := xtables-legacy-multi
$(PKG)_BINARY_NAME  := $($(PKG)_BINARY_NAME$($(PKG)_KERNNBR))
$(PKG)_BINARY := $($(PKG)_DIR)/iptables/$(if $(FREETZ_PACKAGE_IPTABLES_STATIC),,.libs/)$($(PKG)_BINARY_NAME)
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/sbin/$($(PKG)_BINARY_NAME)

$(PKG)_LIBS_SUBDIRS := libiptc/.libs/
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_VERSION_KERNEL2)),y)
$(PKG)_LIBS_SUBDIRS += iptables/.libs/
else
$(PKG)_LIBS_SUBDIRS += libxtables/.libs/
endif
ifeq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_LIBS_SUBDIRS += libiptc/.libs/
endif

ifneq ($(strip $(FREETZ_PACKAGE_IPTABLES_STATIC)),y)
$(PKG)_LIBNAMES_ALL2 := libip4tc.so.0.0.0 libxtables.so.6.0.0  libip6tc.so.0.0.0
$(PKG)_LIBNAMES_ALL3 := libip4tc.so.0.1.0 libxtables.so.10.0.0 libip6tc.so.0.1.0
$(PKG)_LIBNAMES_ALL4 := libip4tc.so.0.1.0 libxtables.so.12.0.0 libip6tc.so.0.1.0
$(PKG)_LIBNAMES_ALL5 := libip4tc.so.2.0.0 libxtables.so.12.7.0 libip6tc.so.2.0.0
$(PKG)_LIBNAMES_ALL  := $($(PKG)_LIBNAMES_ALL$($(PKG)_KERNNBR))
$(PKG)_LIBNAMES := $(filter-out $(if $(FREETZ_TARGET_IPV6_SUPPORT),,libip6tc%), $($(PKG)_LIBNAMES_ALL))
$(PKG)_LIBS_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$(join $($(PKG)_LIBS_SUBDIRS),$($(PKG)_LIBNAMES)))
$(PKG)_LIBS_TARGET_DIR := $(addprefix $($(PKG)_DEST_LIBDIR)/,$($(PKG)_LIBNAMES))
endif

$(PKG)_SYMLINKS_ALL := iptables iptables-save iptables-restore iptables-xml ip6tables ip6tables-save ip6tables-restore
$(PKG)_SYMLINKS := $(filter-out $(if $(FREETZ_TARGET_IPV6_SUPPORT),,ip6%) $(if $(FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE),,%-save %-restore) $(if $(FREETZ_PACKAGE_IPTABLES_XML),,%-xml), $($(PKG)_SYMLINKS_ALL))
$(PKG)_SYMLINKS_TARGET_DIR := $($(PKG)_SYMLINKS:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

ifneq ($(strip $(FREETZ_PACKAGE_IPTABLES_STATIC)),y)
$(PKG)_EXTENSIONS_BUILD_DIR := $($(PKG)_DIR)/extensions
$(PKG)_EXTENSIONS_TARGET_DIR := $(TARGET_SPECIFIC_ROOT_DIR)/usr/lib/xtables
$(PKG)_TARGET_EXTENSIONS := $($(PKG)_EXTENSIONS_TARGET_DIR)/.installed
endif

$(PKG)_CATEGORY:=Unstable

$(PKG)_CONFIGURE_ENV += AR="$(TARGET_AR)"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_OPTIONS += --with-ksource="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --disable-nftables
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv4
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_SAVE_RESTORE)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-save-restore
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_XML)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-xml
endif
ifeq ($(strip $(FREETZ_PACKAGE_IPTABLES_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_LDFLAGS += -all-static
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,ac_cv(_header_linux),do_not_cache_me\1,g' configure;

# touch some patched files to prevent auto*-tools from being executed
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured | kernel-source
	$(SUBMAKE) -C $(IPTABLES_DIR) LDFLAGS="$(TARGET_LDFLAGS) $(IPTABLES_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

define $(PKG)_SYMLINK_RULE
$$(filter $($(PKG)_DEST_DIR)/usr/sbin/$(1)%,$($(PKG)_SYMLINKS_TARGET_DIR)): $($(PKG)_TARGET_BINARY)
	ln -sf $$(notdir $$<) $$@
endef
$(eval $(call $(PKG)_SYMLINK_RULE,iptables))
ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(eval $(call $(PKG)_SYMLINK_RULE,ip6tables))
endif

ifneq ($(strip $(FREETZ_PACKAGE_IPTABLES_STATIC)),y)
$($(PKG)_TARGET_EXTENSIONS): $($(PKG)_BINARY)
	mkdir -p $(IPTABLES_EXTENSIONS_TARGET_DIR)
	cp $(IPTABLES_EXTENSIONS_BUILD_DIR)/*.so* $(IPTABLES_EXTENSIONS_TARGET_DIR)
	$(TARGET_STRIP) $(IPTABLES_EXTENSIONS_TARGET_DIR)/*.so*
	touch $@

$(foreach library,$($(PKG)_LIBS_BUILD_DIR),$(eval $(call INSTALL_LIBRARY_STRIP_RULE,$(library),$(FREETZ_LIBRARY_DIR))))
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARY) $($(PKG)_SYMLINKS_TARGET_DIR) $($(PKG)_TARGET_EXTENSIONS)


$(pkg)-clean:
	-$(SUBMAKE) -C $(IPTABLES_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(IPTABLES_TARGET_BINARY) \
		$(IPTABLES_DEST_LIBDIR)/lib* \
		$(IPTABLES_EXTENSIONS_TARGET_DIR)

$(PKG_FINISH)
