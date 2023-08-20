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

Scope_FILES = $(wildcard *.m) $(shell find Controllers -name '*.m') $(shell find Classes -name '*.m') $(shell find ZipArchive/SSZipArchive -name "*.m") $(shell find ZipArchive/SSZipArchive/minizip -name "*.c")	
Scope_FRAMEWORKS = UIKit CoreGraphics
Scope_LDFLAGS = Frameworks/libbz2.1.0.tbd Frameworks/libz.1.tbd Frameworks/libiconv.2.tbd
Scope_CFLAGS = -fobjc-arc -Wno-unused-but-set-variable -I../ZipArchive -DCOCOAPODS=1 -DPRIx64=\"llx\" -DHAVE_PKCRYPT -DHAVE_STDINT_H -DHAVE_WZAES -DHAVE_ZLIB

include $(THEOS_MAKE_PATH)/application.mk
