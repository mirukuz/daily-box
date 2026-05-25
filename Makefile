# Makefile
APP_NAME = DailyBox
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app

.PHONY: build bundle run clean

build:
	swift build -c release

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Sources/DailyBoxLib/Resources/Info.plist $(APP_BUNDLE)/Contents/
	printf 'APPL????' > $(APP_BUNDLE)/Contents/PkgInfo

run: bundle
	open $(APP_BUNDLE)

clean:
	rm -rf .build $(APP_BUNDLE)
