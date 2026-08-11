ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:13.0
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = TrieuClient
TrieuClient_FILES = TrieuClient.mm
TrieuClient_FRAMEWORKS = UIKit Foundation QuartzCore
TrieuClient_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
TrieuClient_LDFLAGS = -Wl,-segalign,4000
TrieuClient_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/library.mk

after-install::
	install.exec "killall -9 SpringBoard || killall -9 AppName || true"
