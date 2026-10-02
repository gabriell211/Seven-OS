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
SEVEN_DESKTOP_DEPENDENCIES = qt6base qt6declarative qt6wayland qt6svg dbus pipewire wireplumber

define SEVEN_DESKTOP_USERS
	- - video -1 - - - - -
	- - render -1 - - - - -
	- - input -1 - - - - -
	- - audio -1 - - - - -
	seven 1000 seven 1000 * /home/seven /bin/sh video,render,input,audio Seven Desktop User
endef

define SEVEN_DESKTOP_INSTALL_SESSION
	$(INSTALL) -D -m 0755 $(@D)/seven-session \
		$(TARGET_DIR)/usr/bin/seven-session
endef
SEVEN_DESKTOP_POST_INSTALL_TARGET_HOOKS += SEVEN_DESKTOP_INSTALL_SESSION

define SEVEN_DESKTOP_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(@D)/S70seven-desktop \
		$(TARGET_DIR)/etc/init.d/S70seven-desktop
endef

define SEVEN_DESKTOP_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 $(@D)/seven-session-runtime.service \
		$(TARGET_DIR)/usr/lib/systemd/system/seven-session-runtime.service
	$(INSTALL) -D -m 0644 $(@D)/seven-desktop.service \
		$(TARGET_DIR)/usr/lib/systemd/system/seven-desktop.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/graphical.target.wants
	ln -sf /usr/lib/systemd/system/seven-session-runtime.service \
		$(TARGET_DIR)/etc/systemd/system/graphical.target.wants/seven-session-runtime.service
	ln -sf /usr/lib/systemd/system/seven-desktop.service \
		$(TARGET_DIR)/etc/systemd/system/graphical.target.wants/seven-desktop.service
endef

$(eval $(cmake-package))
