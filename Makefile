.PHONY: test clean build-release build-metal

PREFIX_DIR := /usr/local/bin

build:
	swift build -c release --product PixelateCLI
	
metal:
	chmod +x build_metal.sh
	./build_metal.sh

clean:
	swift package clean
	rm -rf .build

test:
	swift test

install: build metal
	@echo "Installing the Pixelate command-line tool...\\n"
	@mkdir -p $(PREFIX_DIR) 2> /dev/null || ( echo "❌ Unable to create install directory \`$(PREFIX_DIR)\`. You might need to run \`sudo make\`\\n"; exit 126 )
	@(install .build/release/PixelateCLI $(PREFIX_DIR)/pixelate && \
	  chmod +x $(PREFIX_DIR)/pixelate && \
	  (echo \\n✅ Success! Run \`pixelate\` to get started.)) || \
	 (echo \\n❌ Installation failed. You might need to run \`sudo make\` instead.\\n)
