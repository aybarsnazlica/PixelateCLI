build:
	swift build && ./build_metal.sh

clean:
	rm -rf .build/debug/
	
test:
	.build/debug/pixelate --input art.png --output out.png --pixel-size 8
