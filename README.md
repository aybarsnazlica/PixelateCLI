# PixelateCLI

**PixelateCLI** is a Swift-based command-line tool that applies a pixelation effect to an image using Metal for GPU acceleration.

## Features

- Adjustable pixelation block size using `--pixel-size`
- Preserves image color fidelity (avoids sRGB color shift)
- Accepts input and output paths with `--input` and `--output`
- Uses Metal compute shaders for performance

## Requirements

- macOS with Metal support
- Swift 5.9 or later
- Xcode command-line tools

## Build Instructions

From the project root directory, simply run:

```shell
make all
```

This will build the Swift project and compile the Metal shader into `.build/release/default.metallib`.

## Usage

```shell
.build/release/PixelateCLI --input path/to/input.png --output path/to/output.png --pixel-size 12
```

### Options

- `--input`, `-i`: Path to the input image (required)
- `--output`, `-o`: Path where the output image will be saved (required)
- `--pixel-size`, `-p`: Size of the pixelation block (default: 8, max: 128)

## License

MIT License
