THEOS_DEVICE_IP = localhost
TARGET := iphone:clang:latest:14.0
SDKVERSION = 14.4
INSTALL_TARGET_PROCESSES = Scope
THEOS_DEVICE_PORT = 22
ARCHS = arm64 arm64e
DEBUG = 1
FINALPACKAGE = 0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Scope

Scope_FILES = $(wildcard *.m) $(shell find Controllers -name '*.m') $(shell find Classes -name '*.m')
Scope_FRAMEWORKS = UIKit CoreGraphics
Scope_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
