//
//  Image.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

import Metal
import MetalKit

/// A utility structure for configuring the Metal environment required for compute operations.
///
/// The `MetalContext` encapsulates the Metal device, command queue, compute pipeline state,
/// and a texture loader. It simplifies the initialization of Metal resources necessary for
/// executing GPU-based image processing tasks.
struct MetalContext {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipeline: MTLComputePipelineState
    let textureLoader: MTKTextureLoader

    /// Initializes the Metal context using the specified Metal library and compute function name.
    ///
    /// - Parameters:
    ///   - libraryPath: The file system path to the `.metallib` file.
    ///   - kernelFunction: The name of the compute shader function to use.
    /// - Throws: A `RuntimeError` if any part of the Metal setup fails.
    init(libraryPath: String, kernelFunction: String) throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw RuntimeError(
                message: "Failed to create GPU device."
            )
        }

        let libraryURL = URL(fileURLWithPath: libraryPath)
        let library = try device.makeLibrary(URL: libraryURL)

        guard
            let kernel = library.makeFunction(
                name: kernelFunction
            )
        else {
            throw RuntimeError(
                message: "Failed to load kernel '\(kernelFunction)'"
            )
        }

        let pipeline = try device.makeComputePipelineState(function: kernel)

        self.device = device
        self.commandQueue = device.makeCommandQueue()!
        self.pipeline = pipeline
        self.textureLoader = MTKTextureLoader(device: device)
    }
}

/// A GPU-accelerated image pixelator using Metal.
///
/// The `Pixelator` struct encapsulates the setup and execution of a Metal compute pipeline
/// that applies a pixelation effect to a given image. It manages the GPU device, command
/// queue, compute pipeline state, and texture loading utilities.
struct Pixelator {
    private let context: MetalContext
    private lazy var ciContext: CIContext = {
        CIContext(
            options: [
                .outputColorSpace: CGColorSpaceCreateDeviceRGB(),
                .workingColorSpace: CGColorSpaceCreateDeviceRGB(),
            ]
        )
    }()

    /// Initializes a new `Pixelator` instance and sets up the Metal compute pipeline.
    ///
    /// - Throws: A `RuntimeError` if the Metal device, command queue, or shader pipeline cannot be initialized.
    init() throws {
        let path =
            FileManager.default.currentDirectoryPath
            + "/.build/release/default.metallib"
        self.context = try MetalContext(
            libraryPath: path,
            kernelFunction: "pixelateKernel"
        )
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
    /// - Throws: A `RuntimeError` if pixelSize is not valid or Metal command encoding or output image creation fails.
    mutating func pixelate(image: CGImage, pixelSize: Int) throws -> CGImage {
        guard pixelSize > 0 && pixelSize <= 128 else {
            throw RuntimeError(message: "Pixel size must be between 1 and 128.")
        }
        let inputTexture = try context.textureLoader.newTexture(
            cgImage: image,
            options: [MTKTextureLoader.Option.SRGB: false]
        )

        let outputTexture = try makeOutputTexture(from: inputTexture)
        try encodePixelation(
            input: inputTexture,
            output: outputTexture,
            pixelSize: pixelSize
        )
        return try createImage(from: outputTexture)
    }

    /// Creates an output texture with the same dimensions as the input texture.
    ///
    /// - Parameter input: The input `MTLTexture` from which to copy dimensions.
    /// - Returns: A writable `MTLTexture` to use as the output.
    /// - Throws: A `RuntimeError` if the texture could not be created.
    private func makeOutputTexture(from input: MTLTexture) throws -> MTLTexture
    {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: input.width,
            height: input.height,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead, .shaderWrite]

        guard let texture = context.device.makeTexture(descriptor: descriptor)
        else {
            throw RuntimeError(message: "Failed to create output texture.")
        }
        return texture
    }

    /// Encodes the pixelation compute command into a Metal command buffer.
    ///
    /// This method configures and dispatches the Metal compute kernel that performs the pixelation.
    ///
    /// - Parameters:
    ///   - input: The input texture to read from.
    ///   - output: The output texture to write to.
    ///   - pixelSize: The size of each pixel block.
    /// - Throws: A `RuntimeError` if the command buffer or encoder cannot be created.
    private func encodePixelation(
        input: MTLTexture,
        output: MTLTexture,
        pixelSize: Int
    ) throws {
        guard let commandBuffer = context.commandQueue.makeCommandBuffer(),
            let encoder = commandBuffer.makeComputeCommandEncoder()
        else {
            throw RuntimeError(
                message: "Failed to create Metal resources."
            )
        }

        encoder.setComputePipelineState(context.pipeline)
        encoder.setTexture(input, index: 0)
        encoder.setTexture(output, index: 1)

        var blockSize = UInt32(pixelSize)
        encoder.setBytes(
            &blockSize,
            length: MemoryLayout<UInt32>.size,
            index: 0
        )

        let w = context.pipeline.threadExecutionWidth
        let h = context.pipeline.maxTotalThreadsPerThreadgroup / w
        encoder
            .dispatchThreads(
                MTLSize(
                    width: input.width,
                    height: input.height,
                    depth: 1
                ),
                threadsPerThreadgroup: MTLSize(
                    width: w,
                    height: h,
                    depth: 1
                )
            )

        encoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    /// Converts a Metal texture to a `CGImage` using Core Image.
    ///
    /// - Parameter texture: The Metal texture containing the pixelated image.
    /// - Returns: A `CGImage` representation of the texture.
    /// - Throws: A `RuntimeError` if the conversion fails.
    private mutating func createImage(from texture: MTLTexture) throws
        -> CGImage
    {
        guard
            let ciImage = CIImage(
                mtlTexture: texture,
                options: nil
            ),
            let cgImage = ciContext.createCGImage(
                ciImage,
                from: CGRect(
                    x: 0,
                    y: 0,
                    width: texture.width,
                    height: texture.height
                )
            )
        else {
            throw RuntimeError(
                message: "Failed to convert output texture to CGImage."
            )
        }
        return cgImage
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
    var pixelator = try Pixelator()
    return
        try pixelator
        .pixelate(
            image: image,
            pixelSize: pixelSize
        )
}
