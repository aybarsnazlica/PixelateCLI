//
//  Pixelate.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/04/30.
//

import ArgumentParser

@main
struct Pixelate: ParsableCommand {
    @Argument var inputFile: String
    @Argument var outputFile: String
    
    mutating func run() throws {
        let (image, imageType) = try loadImage(from: inputFile)
        let pixelatedImage = try pixelateImage(image: image)
        try saveImage(image: pixelatedImage, to: outputFile, with: imageType)
        print("Image saved to \(outputFile)")
    }
}
