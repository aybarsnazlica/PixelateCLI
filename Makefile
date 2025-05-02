build:
	swift build && ./build_metal.sh

clean:
	rm -rf .build/debug/
