#!/bin/sh

SOURCE="Metal/Shaders.metal"
BUILD=".build/debug"
AIR="$BUILD/Shaders.air"
LIB="$BUILD/default.metallib"


# Exit immediately on error
set -e

xcrun -sdk macosx metal -c "$SOURCE" -o "$AIR"
xcrun -sdk macosx metallib "$AIR" -o "$LIB"

echo "Metal build complete."
