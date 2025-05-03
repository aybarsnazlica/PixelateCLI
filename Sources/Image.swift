//
//  Image.swift
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

import Metal
import MetalKit

func pixelateImage(
    image: CGImage
) throws -> CGImage {
    guard let device = MTLCreateSystemDefaultDevice() else {
        throw RuntimeError(
            message: "Failed to create GPU device."
        )
    }
    let textureLoader = MTKTextureLoader(
        device: device
    )
    let texture = try textureLoader.newTexture(
        cgImage: image,
        options: [MTKTextureLoader.Option.SRGB : false]
    )
    
    guard let commandQueue = device.makeCommandQueue() else {
        throw RuntimeError(
            message: "Failed to setup metal pipeline."
        )
    }
    
    let metallibURL = URL(
        fileURLWithPath: "/Users/aybars/Developer/PixelateCLI/.build/debug/default.metallib"
    )
    let library = try device.makeLibrary(
        URL: metallibURL
    )
    guard let kernel = library.makeFunction(
        name: "pixelateKernel"
    ) else {
        throw RuntimeError(
            message: "Failed to setup metal pipeline."
        )
    }
    
    let pipeline = try device.makeComputePipelineState(
        function: kernel
    )
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: texture.pixelFormat,
        width: texture.width,
        height: texture.height,
        mipmapped: false
    )
    
    descriptor.usage = [
        .shaderRead,
        .shaderWrite
    ]
    guard let outputTexture = device.makeTexture(
        descriptor: descriptor
    ) else {
        throw RuntimeError(
            message: "Failed to create output texture."
        )
    }
    
    let commandBuffer = commandQueue.makeCommandBuffer()
    let encoder = commandBuffer?.makeComputeCommandEncoder()
    encoder?
        .setComputePipelineState(
            pipeline
        )
    encoder?
        .setTexture(
            texture,
            index: 0
        )
    encoder?
        .setTexture(
            outputTexture,
            index: 1
        )
    
    let w = pipeline.threadExecutionWidth
    let h = pipeline.maxTotalThreadsPerThreadgroup / w
    let threadsPerThreadgroup = MTLSize(
        width: w,
        height: h,
        depth: 1
    )
    let threadsPerGrid = MTLSize(
        width: texture.width,
        height: texture.height,
        depth: 1
    )
    
    encoder?
        .dispatchThreads(
            threadsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
    encoder?
        .endEncoding()
    
    commandBuffer?
        .commit()
    commandBuffer?
        .waitUntilCompleted()
    
    let ciImage = CIImage(
        mtlTexture: outputTexture,
        options: nil
    )!
    let context = CIContext()
    
    let im = context.createCGImage(
        ciImage,
        from: CGRect(
            x: 0,
            y: 0,
            width: texture.width,
            height: texture.height
        )
    )!
    
    return im
}
