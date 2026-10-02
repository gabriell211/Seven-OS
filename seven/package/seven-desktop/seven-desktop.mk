################################################################################
#
# seven-desktop
#
################################################################################

SEVEN_DESKTOP_VERSION = 0.1.0
SEVEN_DESKTOP_SITE = $(BR2_EXTERNAL_SEVEN_PATH)/package/seven-desktop/files
SEVEN_DESKTOP_SITE_METHOD = local
SEVEN_DESKTOP_LICENSE = MIT
SEVEN_DESKTOP_LICENSE_FILES = LICENSE
SEVEN_DESKTOP_DEPENDENCIES = qt6base qt6declarative qt6wayland qt6svg

define SEVEN_DESKTOP_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/S70seven-desktop 		$(TARGET_DIR)/etc/init.d/S70seven-desktop
endef

$(eval $(cmake-package))
