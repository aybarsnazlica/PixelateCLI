//
//  IO.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

import Foundation
import ImageIO

struct RuntimeError: LocalizedError {
    let message: String
    var errorDescription: String? {
        message
    }
}

func loadImage(
    from path: String
) throws -> (
    CGImage,
    CFString
) {
    let inputURL = URL(
        fileURLWithPath: path
    )
    
    guard let imageSource = CGImageSourceCreateWithURL(
        inputURL as CFURL,
        nil
    ) else {
        throw RuntimeError(
            message: "Could not load image source."
        )
    }
    
    guard let imageType = CGImageSourceGetType(
        imageSource
    ) else {
        throw RuntimeError(
            message: "Could not determine image type."
        )
    }
    
    guard let image = CGImageSourceCreateImageAtIndex(
        imageSource,
        0,
        nil
    ) else {
        throw RuntimeError(
            message: "Could not create image from source."
        )
    }
    
    return (
        image,
        imageType
    )
}

func saveImage(
    image: CGImage,
    to path: String,
    with type: CFString
) throws {
    let outputURL = URL(
        fileURLWithPath: path
    )
    
    guard let destination = CGImageDestinationCreateWithURL(
        outputURL as CFURL,
        type,
        1,
        nil
    ) else {
        throw RuntimeError(
            message: "Could not create image destination."
        )
    }
    
    CGImageDestinationAddImage(
        destination,
        image,
        nil
    )
    
    if !CGImageDestinationFinalize(
        destination
    ) {
        throw RuntimeError(
            message: "Failed to write image."
        )
    }
}
