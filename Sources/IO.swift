//
//  IO.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

import Foundation
import ImageIO

/// A basic error type for representing runtime failures in the command-line tool.
///
/// `RuntimeError` is used throughout the application to represent errors encountered
/// during file I/O or Metal operations. It conforms to `LocalizedError` to provide
/// readable error descriptions.
///
/// Use this error type when you want to throw a descriptive message as an error.
struct RuntimeError: LocalizedError {
    /// A message describing the error.
    let message: String

    /// A user-readable description of the error.
    var errorDescription: String? {
        message
    }
}

/// Loads an image from the given file path and returns it as a `CGImage` along with its image type.
///
/// This function reads image data from disk using ImageIO and creates a `CGImage` representation.
///
/// - Parameter path: The file path to the image to load.
/// - Returns: A tuple containing the loaded `CGImage` and its image type (`CFString`).
/// - Throws: A `RuntimeError` if the image cannot be loaded or its type cannot be determined.
func loadImage(from path: String) throws -> (CGImage, CFString) {
    let inputURL = URL(fileURLWithPath: path)
    
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
    
    return (image, imageType)
}

/// Saves a `CGImage` to disk at the specified path with the given image type.
///
/// This function uses ImageIO to write a `CGImage` to a file on disk.
///
/// - Parameters:
///   - image: The `CGImage` to save.
///   - path: The file path to write the image to.
///   - type: The image type (e.g., kUTTypePNG or kUTTypeJPEG).
/// - Throws: A `RuntimeError` if the image cannot be written to disk.
func saveImage(
    image: CGImage,
    to path: String,
    with type: CFString
) throws {
    let outputURL = URL(fileURLWithPath: path)
    
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
    
    CGImageDestinationAddImage(destination, image, nil)
    
    if !CGImageDestinationFinalize(destination) {
        throw RuntimeError(
            message: "Failed to write image."
        )
    }
}
