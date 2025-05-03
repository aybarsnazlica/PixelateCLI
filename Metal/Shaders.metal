//
//  Shaders.metal
//  PixelateCLI
//
//  Created by Aybars Nazlica on 2025/05/02.
//

#include <metal_stdlib>
using namespace metal;

kernel void pixelateKernel(
    texture2d<float, access::read> inTexture [[ texture(0) ]],
    texture2d<float, access::write> outTexture [[ texture(1) ]],
    uint2 gid [[ thread_position_in_grid ]]
) {
    uint2 size = uint2(inTexture.get_width(), inTexture.get_height());
    if (gid.x >= size.x || gid.y >= size.y) return;

    constexpr uint pixelSize = 8; // block size for pixelation
    
    uint2 blockOrigin = (gid / pixelSize) * pixelSize;

    float4 color = inTexture
        .read(uint2(min(blockOrigin.x, size.x - 1), min(blockOrigin.y, size.y - 1)));
    outTexture
        .write(color, gid);
}
