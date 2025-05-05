# PixelateCLI

**PixelateCLI** is a Swift-based command-line tool that applies a pixelation effect to an image using Metal for GPU acceleration.

## Features

- Adjustable pixelation block size using `--pixel-size`
- Preserves image color fidelity (avoids sRGB color shift)
- Accepts input and output paths with `--input` and `--output`
- Uses Metal compute shaders for performance

## Requirements

- macOS with Metal support
- Swift 5.7 or later
- Xcode command-line tools

## Build Instructions

From the project root directory, simply run:

```bash
make build
```

This will build the Swift project and compile the Metal shader into `.build/debug/default.metallib`.

## Usage

```bash
.build/debug/pixelate --input path/to/input.png --output path/to/output.png --pixel-size 12
```

### Options

- `--input`, `-i`: Path to the input image (required)
- `--output`, `-o`: Path where the output image will be saved (required)
- `--pixel-size`, `-p`: Size of the pixelation block (default: 8, max: 128)

## Example

```bash
.build/debug/pixelate -i art.png -o art_pixelated.png -p 16
```

This command pixelates the image with a block size of 16 pixels.

## License

MIT License
