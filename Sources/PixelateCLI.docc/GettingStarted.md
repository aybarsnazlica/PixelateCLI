# Getting Started

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

## Troubleshooting

- Ensure Metal is supported on your macOS system.
- If `default.metallib` is not found, check that Xcode command-line tools are installed and that the Metal source is compiling correctly.
