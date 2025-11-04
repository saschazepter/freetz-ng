$(call TOOLS_INIT, $(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),0.14.5,b49de1b33))
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=b9a46f2989322eb89fa4f6237e20836c57b455aa43a32545ea093b431d982f5c
$(PKG)_HASH_CURRENT:=b5baedcef96b73dbdd6ae296f7aecdddd3fe51e3f335ef8bc99643a223242e95
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION)
$(PKG)_SITE_CURRENT:=git@https://github.com/NixOS/patchelf.git
$(PKG)_SITE:=$($(PKG)_SITE_$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),ABANDON,CURRENT))
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/releases
### CVSREPO:=https://github.com/NixOS/patchelf
### VERSION:=0.14.5/0.18.0-b49de1b33

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),abandon,current)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_PATCHELF_VERSION_ABANDON

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/src/patchelf: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCHELF_HOST_DIR) all

$(TOOLS_DIR)/patchelf: $($(PKG)_DIR)/src/patchelf
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/patchelf


$(pkg)-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/patchelf

$(TOOLS_FINISH)
