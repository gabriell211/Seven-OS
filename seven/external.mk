# Seven OS Buildroot external packages.
include $(sort $(wildcard $(BR2_EXTERNAL_SEVEN_PATH)/package/*/*.mk))
