# PixelateCLI

**PixelateCLI** is a Swift-based command-line tool that applies a pixelation effect to an image using Metal for GPU acceleration.

## Features

- Adjustable pixelation block size using `--pixel-size`
- Preserves image color fidelity (avoids sRGB color shift)
- Accepts input and output paths with `--input` and `--output`
- Uses Metal compute shaders for performance

## Build Instructions

From the project root directory run:

```shell
make install
```

## License

MIT License
