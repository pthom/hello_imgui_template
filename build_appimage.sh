#!/bin/bash
set -e

# Detect host architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    LINUXDEPLOY_ARCH="x86_64"
elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    LINUXDEPLOY_ARCH="aarch64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi
echo "Building for architecture: $ARCH (linuxdeploy: $LINUXDEPLOY_ARCH)"

# Create dedicated folder for all AppImage build artifacts
BUILD_ROOT="appimage_build"
rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"

# Clean and create build directory
echo "Configuring build..."
mkdir -p "$BUILD_ROOT/build"
cd "$BUILD_ROOT/build"

# Configure with install directory as install prefix
cmake ../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../install
cd ../..

# Build the application
echo "Building the application..."
cd "$BUILD_ROOT/build"
cmake --build . --config Release -j
cd ../..

# Install to install directory
echo "Installing application..."
cd "$BUILD_ROOT/build"
cmake --install .
cd ../..

# Prepare AppDir structure from install directory
echo "Preparing AppDir structure..."
mkdir -p "$BUILD_ROOT/AppDir/usr/bin"
mkdir -p "$BUILD_ROOT/AppDir/usr/lib"

# Copy executable and assets (HelloImGui installs them at root level)
cp "$BUILD_ROOT/install/hello_world" "$BUILD_ROOT/AppDir/usr/bin/"
cp -r "$BUILD_ROOT/install/assets" "$BUILD_ROOT/AppDir/usr/bin/"

# Download linuxdeploy if not present
LINUXDEPLOY="$BUILD_ROOT/linuxdeploy-${LINUXDEPLOY_ARCH}.AppImage"
if [ ! -f "$LINUXDEPLOY" ]; then
    echo "Downloading linuxdeploy for ${LINUXDEPLOY_ARCH}..."
    wget -O "$LINUXDEPLOY" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${LINUXDEPLOY_ARCH}.AppImage"
    chmod +x "$LINUXDEPLOY"
fi

# Copy desktop file and icon
echo "Setting up AppImage metadata..."
cp hello_world.desktop "$BUILD_ROOT/AppDir/"
# Use icon from assets if it exists, otherwise use the larger one
if [ -f "$BUILD_ROOT/install/assets/app_settings/icon.png" ]; then
    cp "$BUILD_ROOT/install/assets/app_settings/icon.png" "$BUILD_ROOT/AppDir/hello_world.png"
elif [ -f assets/app_settings/linux/app_icon_512x512.png ]; then
    cp assets/app_settings/linux/app_icon_512x512.png "$BUILD_ROOT/AppDir/hello_world.png"
else
    echo "Warning: No icon found!"
fi

# Bundle specific libraries (glfw and freetype)
echo "Bundling libraries..."

# Find and copy libglfw
GLFW_LIB=$(ldd "$BUILD_ROOT/install/hello_world" | grep libglfw | awk '{print $3}')
if [ -n "$GLFW_LIB" ]; then
    echo "Bundling libglfw: $GLFW_LIB"
    cp "$GLFW_LIB" "$BUILD_ROOT/AppDir/usr/lib/"
fi

# Find and copy libfreetype
FREETYPE_LIB=$(ldd "$BUILD_ROOT/install/hello_world" | grep libfreetype | awk '{print $3}')
if [ -n "$FREETYPE_LIB" ]; then
    echo "Bundling libfreetype: $FREETYPE_LIB"
    cp "$FREETYPE_LIB" "$BUILD_ROOT/AppDir/usr/lib/"
    # Also copy dependencies of freetype
    FREETYPE_DEPS=$(ldd "$FREETYPE_LIB" | grep -E "libpng|libbz2|libbrotli|libz\.so" | awk '{print $3}')
    for dep in $FREETYPE_DEPS; do
        if [ -n "$dep" ] && [ -f "$dep" ]; then
            echo "Bundling freetype dependency: $dep"
            cp "$dep" "$BUILD_ROOT/AppDir/usr/lib/" 2>/dev/null || true
        fi
    done
fi

# Create AppImage
echo "Creating AppImage..."
"$LINUXDEPLOY" \
    --appdir "$BUILD_ROOT/AppDir" \
    --executable "$BUILD_ROOT/AppDir/usr/bin/hello_world" \
    --desktop-file hello_world.desktop \
    --icon-file "$BUILD_ROOT/AppDir/hello_world.png" \
    --exclude-library "libX11*" \
    --exclude-library "libxcb*" \
    --exclude-library "libGL*" \
    --exclude-library "libstdc++*" \
    --exclude-library "libgcc_s*" \
    --output appimage

# Move the final AppImage to project root for easy access
mv Hello_World-*.AppImage . 2>/dev/null || true

echo "AppImage created successfully!"
ls -lh *.AppImage
