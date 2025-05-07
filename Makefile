.PHONY: test clean build-release build-metal

build-release:
	swift build --configuration release
	
build-metal:
	chmod +x build_metal.sh
	./build_metal.sh

clean:
	swift package clean
	rm -rf .build

test:
	swift test

all: build-release build-metal
