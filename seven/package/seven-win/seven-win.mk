################################################################################
#
# seven-win
#
################################################################################

SEVEN_WIN_VERSION = 0.1.0
SEVEN_WIN_SITE = $(BR2_EXTERNAL_SEVEN_PATH)/package/seven-win/files
SEVEN_WIN_SITE_METHOD = local
SEVEN_WIN_LICENSE = MIT
SEVEN_WIN_LICENSE_FILES = LICENSE

define SEVEN_WIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/seven-winexec \
		$(TARGET_DIR)/usr/bin/seven-winexec
	$(INSTALL) -D -m 0755 $(@D)/seven-wininstall \
		$(TARGET_DIR)/usr/bin/seven-wininstall
	$(INSTALL) -D -m 0644 $(@D)/70-seven-win.conf \
		$(TARGET_DIR)/usr/lib/binfmt.d/70-seven-win.conf
	$(INSTALL) -D -m 0644 $(@D)/seven-windows.conf \
		$(TARGET_DIR)/etc/seven/seven-windows.conf
endef

$(eval $(generic-package))
