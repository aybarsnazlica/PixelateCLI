//
//  Pixelate.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/04/30.
//

import ArgumentParser

/// A command-line tool that applies a pixelation effect to images using Metal.
///
/// The `Pixelate` command reads an input image, applies a pixelation effect with a user-defined pixel size,
/// and writes the result to an output file. It uses a Metal compute shader to perform the pixelation efficiently.
///
/// - Parameters:
///   - input: Path to the input image file.
///   - output: Path to save the output image.
///   - pixelSize: The size of the pixelation block. Maximum value is 128.
@main
struct Pixelate: ParsableCommand {
    @Option(name: .shortAndLong, help: "Path to the input image file.")
    var input: String

    @Option(name: .shortAndLong, help: "Path to save the output image.")
    var output: String

    @Option(name: .shortAndLong, help: "Pixelation block size.")
    var pixelSize: Int = 8 {
        didSet {
            if pixelSize > 128 {
                pixelSize = 128
            }
        }
    }

    /// Executes the pixelation process.
    ///
    /// This method loads the input image, applies the pixelation effect using the specified pixel size,
    /// and saves the resulting image to the output path.
    mutating func run() throws {
        let (image, imageType) = try loadImage(from: input)
        let pixelatedImage = try pixelateImage(image: image, pixelSize: pixelSize)
        
        try saveImage(
            image: pixelatedImage,
            to: output,
            with: imageType
        )
        
        print("Image saved to \(output)")
    }
}
