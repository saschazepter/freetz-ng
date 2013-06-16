$(call PKG_INIT_BIN, 2.1.0-rc1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=51282c0d174974c0314e68d8ad8214af7e3fb7a6
$(PKG)_SITE:=http://downloads.asterisk.org/pub/telephony/asterisk-gui

$(PKG)_TARGET:=$($(PKG)_DEST_DIR)/usr/share/asterisk/static-http/index.html

$(PKG)_CONFIGURE_PRE_CMDS += (cd debian/images; for f in *.uu; do uudecode -o ../../config/images/$$$${f/%.uu/} $$$$f; done);

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ASTERISK_GUI_DIR)
	@touch $@

$($(PKG)_TARGET): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ASTERISK_GUI_DIR) \
		DESTDIR="$(abspath $(ASTERISK_GUI_DEST_DIR))" \
		ASTVARLIBDIR="$(abspath $(ASTERISK_GUI_DEST_DIR))/usr/share/asterisk" \
		install
	(cd $(ASTERISK_GUI_DEST_DIR); $(RM) -r etc usr/share/asterisk/gui_backups usr/share/asterisk/static-http/config/private)
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ASTERISK_GUI_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(ASTERISK_GUI_DEST_DIR)/usr/share/asterisk

$(PKG_FINISH)
