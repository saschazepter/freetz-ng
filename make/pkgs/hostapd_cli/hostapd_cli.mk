$(call PKG_INIT_BIN, 2.7)
$(PKG)_SOURCE := hostapd-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE   := https://w1.fi/releases
$(PKG)_HASH   := 21b0dda3cc3abe75849437f6b9746da461f88f0ea49dd621216936f87440a141

$(PKG)_BINARY         := $($(PKG)_DIR)/hostapd/hostapd_cli
$(PKG)_TARGET_BINARY  := $($(PKG)_DEST_DIR)/usr/sbin/hostapd_cli

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Internal variabeles
HOSTAPD_CLI_DIR := $($(PKG)_DIR)
HOSTAPD_SRC_DIR := $(HOSTAPD_CLI_DIR)/src

# Correct include paths for submodules
HOSTAPD_CLI_CFLAGS := \
	$(TARGET_CFLAGS) \
	-ffunction-sections -fdata-sections \
	-I../src \
	-I../src/utils \
	-I../src/common \
	-I../src/drivers \
	-I../src/l2_packet \
	-I../src/crypto \
	-I../src/ap
# force ignored .config options
HOSTAPD_CLI_CFLAGS += \
        -DCONFIG_CTRL_IFACE \
        -DCONFIG_CTRL_IFACE_UNIX \
        -DCONFIG_WPA_CTRL_IFACE \
        -DCONFIG_CTRL_IFACE_SOCKET \
        -DCONFIG_WPA \
        -DCONFIG_WPA2 \
        -DCONFIG_WPA_CLI \
        -DCONFIG_DEBUG_FILE \
        -DHOSTAPD_CLI_BUILD

HOSTAPD_CLI_LDFLAGS := $(TARGET_LDFLAGS) -Wl,--gc-sections

# It is not clear when the .config file is used, and where.  So we make it similar to HOSTAPD_CLI_FLAGS above
$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	@echo ">>> Building hostapd_cli ..."
	echo "CONFIG_CTRL_IFACE=y"          >  $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_CTRL_IFACE_UNIX=y"          >  $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_WPA_CTRL_IFACE=y"      >> $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_DEBUG_FILE=y"          >> $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_CTRL_IFACE_SOCKET=y"   >> $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_WPA=y"                 >> $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_WPA_CLI=y"                 >> $(HOSTAPD_CLI_DIR)/.config
	echo "CONFIG_WPA2=y"                >> $(HOSTAPD_CLI_DIR)/.config
	cat $(HOSTAPD_CLI_DIR)/.config > $(HOSTAPD_CLI_DIR)/hostapd/.config
	$(SUBMAKE) -C $(HOSTAPD_CLI_DIR)/hostapd \
		CC="$(TARGET_CC)" \
		CFLAGS="$(HOSTAPD_CLI_CFLAGS)" \
		LDFLAGS="$(HOSTAPD_CLI_LDFLAGS)" \
		hostapd_cli

# Install
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $($(PKG)_DIR)/hostapd clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
