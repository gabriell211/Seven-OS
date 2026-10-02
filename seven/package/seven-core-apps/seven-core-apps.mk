################################################################################
#
# seven-core-apps
#
################################################################################

SEVEN_CORE_APPS_VERSION = 0.1.0
SEVEN_CORE_APPS_SITE = $(BR2_EXTERNAL_SEVEN_PATH)/package/seven-core-apps/files
SEVEN_CORE_APPS_SITE_METHOD = local
SEVEN_CORE_APPS_LICENSE = MIT
SEVEN_CORE_APPS_LICENSE_FILES = LICENSE
SEVEN_CORE_APPS_DEPENDENCIES = qt6base qt6declarative

define SEVEN_CORE_APPS_INSTALL_TERMINAL
	$(INSTALL) -D -m 0755 $(@D)/seven-terminal \
		$(TARGET_DIR)/usr/bin/seven-terminal
endef
SEVEN_CORE_APPS_POST_INSTALL_TARGET_HOOKS += SEVEN_CORE_APPS_INSTALL_TERMINAL

$(eval $(cmake-package))
