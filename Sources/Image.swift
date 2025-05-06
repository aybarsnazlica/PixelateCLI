//
//  Image.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

import Metal
import MetalKit

/// A GPU-accelerated image pixelator using Metal.
///
/// The `Pixelator` struct encapsulates the setup and execution of a Metal compute pipeline
/// that applies a pixelation effect to a given image. It manages the GPU device, command
/// queue, compute pipeline state, and texture loading utilities.
struct Pixelator {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let library: MTLLibrary
    let pipeline: MTLComputePipelineState
    let textureLoader: MTKTextureLoader

    /// Initializes a new `Pixelator` instance and sets up the Metal compute pipeline.
    ///
    /// - Throws: A `RuntimeError` if the Metal device, command queue, or shader pipeline cannot be initialized.
    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw RuntimeError(message: "Failed to create GPU device.")
        }
        guard let commandQueue = device.makeCommandQueue() else {
            throw RuntimeError(message: "Failed to setup metal pipeline.")
        }

        let currentDir = FileManager.default.currentDirectoryPath
        let metallibURL = URL(fileURLWithPath: currentDir)
            .appendingPathComponent(".build")
            .appendingPathComponent("debug")
            .appendingPathComponent("default.metallib")

        let library = try device.makeLibrary(URL: metallibURL)
        guard let kernel = library.makeFunction(name: "pixelateKernel") else {
            throw RuntimeError(message: "Failed to setup metal pipeline.")
        }

        self.device = device
        self.commandQueue = commandQueue
        self.library = library
        self.pipeline = try device.makeComputePipelineState(function: kernel)
        self.textureLoader = MTKTextureLoader(device: device)
    }

    /// Applies a pixelation effect to the provided image.
    ///
    /// This method uses a Metal compute kernel to read the input image as a texture and write a pixelated
    /// version to an output texture. The `pixelSize` parameter determines the granularity of the effect.
    ///
    /// - Parameters:
    ///   - image: A `CGImage` to be pixelated.
    ///   - pixelSize: The block size used for pixelation.
    /// - Returns: A new `CGImage` with the pixelation effect applied.
    /// - Throws: A `RuntimeError` if Metal command encoding or output image creation fails.
    func pixelate(image: CGImage, pixelSize: Int) throws -> CGImage {
        let inputTexture = try textureLoader.newTexture(cgImage: image, options: [MTKTextureLoader.Option.SRGB : false])

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]

        guard let outputTexture = device.makeTexture(descriptor: descriptor) else {
            throw RuntimeError(message: "Failed to create output texture.")
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            throw RuntimeError(message: "Failed to create command buffer or encoder.")
        }

        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(inputTexture, index: 0)
        encoder.setTexture(outputTexture, index: 1)

        var pixelSizeUInt32 = UInt32(pixelSize)
        encoder.setBytes(&pixelSizeUInt32, length: MemoryLayout<UInt32>.size, index: 0)

        let w = pipeline.threadExecutionWidth
        let h = pipeline.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSize(
            width: w,
            height: h,
            depth: 1
        )
        let threadsPerGrid = MTLSize(
            width: inputTexture.width,
            height: inputTexture.height,
            depth: 1
        )

        encoder
            .dispatchThreads(
                threadsPerGrid,
                threadsPerThreadgroup: threadsPerThreadgroup
            )
        encoder
            .endEncoding()
        commandBuffer
            .commit()
        commandBuffer
            .waitUntilCompleted()
        
        let ciImage = CIImage(
            mtlTexture: outputTexture,
            options: nil
        )!
        let context = CIContext(
            options: [
                .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
                .workingColorSpace: CGColorSpaceCreateDeviceRGB()
            ]
        )

        guard let outputImage = context.createCGImage(
            ciImage,
            from: CGRect(
                x: 0,
                y: 0,
                width: inputTexture.width,
                height: inputTexture.height
            )
        ) else {
            throw RuntimeError(
                message: "Failed to create CGImage from output texture."
            )
        }

        return outputImage
    }
}

/// Pixelates a CGImage using the Metal-based `Pixelator`.
///
/// This convenience function creates a `Pixelator` and applies the pixelation effect.
///
/// - Parameters:
///   - image: The input image to process.
///   - pixelSize: The size of the pixels for the effect.
/// - Returns: The resulting pixelated image.
/// - Throws: Errors thrown from the `Pixelator` initializer or pixelation process.
func pixelateImage(image: CGImage, pixelSize: Int) throws -> CGImage {
    let pixelator = try Pixelator()
    return try pixelator
        .pixelate(
            image: image,
            pixelSize: pixelSize
        )
}
