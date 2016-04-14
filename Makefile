THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 armv7s arm64
DEBUG = 0
GO_EASY_ON_ME = 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LPTwitter
LPTwitter_FILES = Tweak.xm LPTwitterViewController.m MBProgressHUD.m
LPTwitter_FRAMEWORKS = UIKit Accounts Social Foundation QuartzCore CoreGraphics
LPTwitter_LIBRARIES = lockpages 
LPTwitter_LDFLAGS += -fobjc-arc 
include $(THEOS_MAKE_PATH)/tweak.mk

clean::
	@echo Cleaning compiled NIB layout/Library/Application Support/LPTwitter/Contents/Resources/LPTwitterView.xib
	@rm -f layout/Library/Application\ Support/LPTwitter/Contents/Resources/LPTwitterView.nib

	@echo Cleaning compiled NIB layout/Library/Application Support/LPTwitter/Contents/Resources/TwitterCell.xib
	@rm -f layout/Library/Application\ Support/LPTwitter/Contents/Resources/TwitterCell.nib

before-all::
	@echo Compiling XIB layout/Library/Application Support/LPTwitter/Contents/Resources/LPTwitterView.xib
	@ibtool --compile layout/Library/Application\ Support/LPTwitter/Contents/Resources/LPTwitterView.nib layout/Library/Application\ Support/LPTwitter/Contents/Resources/LPTwitterView.xib
	@echo Compiling XIB layout/Library/Application Support/LPTwitter/Contents/Resources/TwitterCell.xib
	@ibtool --compile layout/Library/Application\ Support/LPTwitter/Contents/Resources/TwitterCell.nib layout/Library/Application\ Support/LPTwitter/Contents/Resources/TwitterCell.xib


after-install::
	install.exec "killall backboardd"
