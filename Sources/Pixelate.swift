//
//  Pixelate.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/04/30.
//

import ArgumentParser

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

    mutating func run() throws {
        let (
            image,
            imageType
        ) = try loadImage(
            from: input
        )
        let pixelatedImage = try pixelateImage(
            image: image,
            pixelSize: pixelSize
        )
        try saveImage(
            image: pixelatedImage,
            to: output,
            with: imageType
        )
        print(
            "Image saved to \(output)"
        )
    }
}
