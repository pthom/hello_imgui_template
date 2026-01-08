#!/bin/bash
set -e

echo "Building AppImage in Ubuntu 22.04 Docker container for maximum compatibility..."

# Detect host architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    PLATFORM="linux/amd64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    PLATFORM="linux/arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Clean previous build artifacts
rm -rf appimage_build
rm -f *.AppImage

# Run build inside Ubuntu 22.04 container
docker run --rm \
    --platform "$PLATFORM" \
    --device /dev/fuse \
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    -v "$(pwd):/workspace" \
    -w /workspace \
    ubuntu:22.04 \
    bash -c '
        set -e
        
        echo "=== Installing build dependencies ==="
        apt-get update
        apt-get install -y \
            build-essential \
            cmake \
            git \
            wget \
            file \
            fuse \
            libgl1-mesa-dev \
            libglfw3-dev \
            libfreetype-dev \
            libx11-dev \
            libxrandr-dev \
            libxi-dev \
            libxcursor-dev \
            libxinerama-dev \
            libxxf86vm-dev
        
        echo "=== Running build script ==="
        chmod +x build_appimage.sh
        ./build_appimage.sh
        
        echo "=== Fixing permissions ==="
        # Make sure output files are owned by the host user
        chown -R $(stat -c "%u:%g" .) appimage_build/ *.AppImage 2>/dev/null || true
    '

echo ""
echo "=== Build completed! ==="
ls -lh *.AppImage

echo ""
echo "AppImage built on Ubuntu 22.04 (glibc 2.35) for maximum compatibility"
echo "This AppImage should work on Ubuntu 22.04+ and equivalent distros"
