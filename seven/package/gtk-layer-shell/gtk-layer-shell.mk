################################################################################
#
# gtk-layer-shell
#
################################################################################

GTK_LAYER_SHELL_VERSION = 0.10.1
GTK_LAYER_SHELL_SITE = $(call github,wmww,gtk-layer-shell,v$(GTK_LAYER_SHELL_VERSION))
GTK_LAYER_SHELL_LICENSE = LGPL-3.0+
GTK_LAYER_SHELL_LICENSE_FILES = LICENSE_LGPL.txt LICENSE_GPL.txt
GTK_LAYER_SHELL_INSTALL_STAGING = YES
GTK_LAYER_SHELL_DEPENDENCIES = 	host-pkgconf 	host-wayland 	libgtk3 	wayland 	wayland-protocols

GTK_LAYER_SHELL_CONF_OPTS = 	-Dexamples=false 	-Ddocs=false 	-Dtests=false 	-Dintrospection=false 	-Dvapi=false

$(eval $(meson-package))
