//
//  PixelatorTests.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/07.
//


import Testing
import CoreGraphics
import Foundation
import ImageIO
@testable import PixelateCLI

/// A suite of unit tests for the Pixelator component.
///
/// This test suite verifies that the pixelation operation produces a valid output image
/// and properly handles invalid input parameters such as a zero pixel size.
struct PixelatorTests {
    /// Tests that the pixelation output image has the same dimensions as the input image.
    @Test func testPixelateWithValidImage() throws {
        // Load a test image from the test bundle
        let testImage = try loadTestImage(named: "art.png")
        
        var pixelator = try Pixelator()
        let output = try pixelator.pixelate(image: testImage, pixelSize: 8)

        #expect(output.width == testImage.width)
        #expect(output.height == testImage.height)
    }

    /// Tests that an error is thrown when attempting to pixelate using a block size of zero.
    @Test func testPixelateRejectsZeroBlockSize() throws {
        let testImage = try loadTestImage(named: "art.png")
        var pixelator = try Pixelator()
        #expect(throws: (RuntimeError).self) {
            try pixelator.pixelate(image: testImage, pixelSize: 0)
        }
    }

    /// Loads a test image from the bundled test resources.
    ///
    /// - Parameter name: The name of the image file to load.
    /// - Returns: A `CGImage` loaded from the resource bundle.
    /// - Throws: A `RuntimeError` if the image cannot be found or decoded.
    private func loadTestImage(named name: String) throws -> CGImage {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: name, withExtension: nil) else {
            throw RuntimeError(message: "Test image not found in bundle: \(name)")
        }

        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw RuntimeError(message: "Failed to decode test image: \(name)")
        }
        return image
    }
}
