//
//  Shaders.metal
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

#include <metal_stdlib>
using namespace metal;

/// A Metal compute kernel that applies a pixelation effect to an image.
///
/// This kernel reads from an input texture and writes a pixelated version of it to an output texture.
/// It computes the origin of a pixel block based on `pixelSize`, samples the color once for the block,
/// and applies that color to the current thread’s output position. The image is flipped vertically to
/// match Core Graphics coordinate conventions.
///
/// - Parameters:
///   - inTexture: The input texture containing the original image.
///   - outTexture: The output texture where the pixelated result will be written.
///   - pixelSize: The size of the pixel block used to apply the pixelation.
///   - gid: The global thread ID, representing the pixel position being processed.
kernel void pixelateKernel(
    texture2d<float, access::read> inTexture [[ texture(0) ]],
    texture2d<float, access::write> outTexture [[ texture(1) ]],
    constant uint& pixelSize [[ buffer(0) ]],
    uint2 gid [[ thread_position_in_grid ]]
) {
    uint2 size = uint2(inTexture.get_width(), inTexture.get_height());
    if (gid.x >= size.x || gid.y >= size.y) return;

    uint2 blockOrigin = (gid / pixelSize) * pixelSize;

    float4 color = inTexture.read(uint2(min(blockOrigin.x, size.x - 1),
                                        min(blockOrigin.y, size.y - 1)));

    uint flippedY = size.y - 1 - gid.y;
    outTexture.write(color, uint2(gid.x, flippedY));
}
