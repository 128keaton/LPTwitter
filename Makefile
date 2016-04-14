THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 armv7s arm64
DEBUG = 0
GO_EASY_ON_ME = 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockMinder
LockMinder_FILES = Tweak.xm LockMinderViewController.m MBProgressHUD.m
LockMinder_FRAMEWORKS = UIKit EventKit Foundation QuartzCore CoreGraphics
LockMinder_LIBRARIES = lockpages 
LockMinder_LDFLAGS += -fobjc-arc 
include $(THEOS_MAKE_PATH)/tweak.mk

clean::
	@echo Cleaning compiled NIB layout/Library/Application Support/LockMinder/Contents/Resources/LockMinderView.xib
	@rm -f layout/Library/Application\ Support/LockMinder/Contents/Resources/LockMinderView.nib


before-all::
	@echo Compiling XIB layout/Library/Application Support/LockMinder/Contents/Resources/LockMinderView.xib
	@ibtool --compile layout/Library/Application\ Support/LockMinder/Contents/Resources/LockMinderView.nib layout/Library/Application\ Support/LockMinder/Contents/Resources/LockMinderView.xib
	


after-install::
	install.exec "killall backboardd"
