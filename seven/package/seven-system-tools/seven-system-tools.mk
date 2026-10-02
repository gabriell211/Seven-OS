################################################################################
#
# seven-system-tools
#
################################################################################

SEVEN_SYSTEM_TOOLS_VERSION = 0.1.0
SEVEN_SYSTEM_TOOLS_SITE = $(BR2_EXTERNAL_SEVEN_PATH)/package/seven-system-tools/files
SEVEN_SYSTEM_TOOLS_SITE_METHOD = local
SEVEN_SYSTEM_TOOLS_LICENSE = MIT
SEVEN_SYSTEM_TOOLS_LICENSE_FILES = LICENSE

define SEVEN_SYSTEM_TOOLS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/seven-doctor $(TARGET_DIR)/usr/bin/seven-doctor
	$(INSTALL) -D -m 0755 $(@D)/seven-recovery $(TARGET_DIR)/usr/bin/seven-recovery
	$(INSTALL) -D -m 0755 $(@D)/seven-image-install $(TARGET_DIR)/usr/bin/seven-image-install
	$(INSTALL) -D -m 0755 $(@D)/seven-image-verify $(TARGET_DIR)/usr/bin/seven-image-verify
endef

$(eval $(generic-package))
