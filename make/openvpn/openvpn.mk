$(call PKG_INIT_BIN, 2.4.7)
$(PKG)_SOURCE_SHA256:=a42f53570f669eaf10af68e98d65b531015ff9e12be7a62d9269ea684652f648
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=https://swupdate.openvpn.net/community/releases,http://build.openvpn.net/downloads/releases

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_WITH_TRAFFIC_OBFUSCATION)),y)
$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))/obfuscation
endif

$(PKG)_BINARY:=$($(PKG)_DIR)/src/openvpn/openvpn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/openvpn

$(PKG)_STARTLEVEL=81

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_OPENSSL),openssl)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),mbedtls)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),lzo)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZ4),lz4)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZ4
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_TRAFFIC_OBFUSCATION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_MGMNT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_USE_IPROUTE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_path_IFCONFIG=/sbin/ifconfig
$(PKG)_CONFIGURE_ENV += ac_cv_path_IPROUTE=/sbin/ip
$(PKG)_CONFIGURE_ENV += ac_cv_path_ROUTE=/sbin/route

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS|LIBS)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
$(PKG)_EXTRA_LDFLAGS += $(if $(FREETZ_PACKAGE_OPENVPN_STATIC),-all-static)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/openvpn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),--enable-lzo,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZ4),--enable-lz4,--disable-lz4)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-multihome
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += --disable-port-share
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --disable-pkcs11
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_OPENSSL),--with-crypto-library=openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_MBEDTLS),--with-crypto-library=mbedtls)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_USE_IPROUTE),--enable-iproute2)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENVPN_DIR) \
		EXTRA_CFLAGS="$(OPENVPN_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(OPENVPN_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(OPENVPN_EXTRA_LIBS)" \
		SOCKETS_LIBS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENVPN_DIR) clean
	$(RM) $(OPENVPN_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENVPN_TARGET_BINARY)

$(PKG_FINISH)
