# Usage

## Example

To run the application pass the input image and output image paths and a pixel size.

```shell
pixelate --input path/to/input.png --output path/to/output.png --pixel-size 12
```

## Options

- `--input`, `-i`: Path to the input image (required)
- `--output`, `-o`: Path where the output image will be saved (required)
- `--pixel-size`, `-p`: Size of the pixelation block (default: 8, max: 128)

The `--pixel-size` option accepts integers from 1 to 128. Lower values apply finer pixelation, while higher values create larger blocky effects. The default is 8.

### Notes

- Input images must be readable by CoreGraphics (e.g., PNG, JPEG).
- Output files will be overwritten if they already exist.
- Ensure the Metal shader file `default.metallib` is present in `.build/release/`.
