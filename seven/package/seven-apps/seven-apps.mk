################################################################################
#
# seven-apps
#
################################################################################

SEVEN_APPS_VERSION = 0.1.0
SEVEN_APPS_SITE = $(BR2_EXTERNAL_SEVEN_PATH)/package/seven-apps/files
SEVEN_APPS_SITE_METHOD = local
SEVEN_APPS_LICENSE = MIT
SEVEN_APPS_LICENSE_FILES = LICENSE
SEVEN_APPS_DEPENDENCIES = qt6base qt6declarative foot

define SEVEN_APPS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/seven-app $(TARGET_DIR)/usr/bin/seven-app
	ln -sf seven-app $(TARGET_DIR)/usr/bin/seven-files
	ln -sf seven-app $(TARGET_DIR)/usr/bin/seven-settings
	ln -sf seven-app $(TARGET_DIR)/usr/bin/seven-store
	ln -sf seven-app $(TARGET_DIR)/usr/bin/seven-monitor
	$(INSTALL) -D -m 0755 $(@D)/seven-terminal $(TARGET_DIR)/usr/bin/seven-terminal
endef

$(eval $(cmake-package))
