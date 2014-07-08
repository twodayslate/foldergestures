THEOS_DEVICE_IP ?= 192.168.2.7
THEOS_DEVICE_PORT ?= 22

THEOS_PACKAGE_DIR_NAME = debs
TARGET := iphone:clang
ARCHS := armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = tap2folder
tap2folder_FILES = Tweak.xm
tap2folder_ARCHS = armv7 arm64


include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
