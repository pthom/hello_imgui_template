# AppImage Build and Distribution Guide

This document describes how to build and distribute the Hello World application as an AppImage for Linux systems.

## What is AppImage?

AppImage is a portable application format for Linux that bundles an application with all its dependencies. Users can download and run it without installation, similar to a portable .exe on Windows.

## Building the AppImage

### Prerequisites

- Linux system (x86_64 or ARM64/aarch64)
- CMake 3.12+
- Build essentials (gcc, g++, make)
- X11 development libraries
- GLFW3 and FreeType development libraries

### Option 1: Native Build (Current System)

Build directly on your system:

```bash
./build_appimage.sh
```

**Note**: The AppImage will be built against your current system's glibc version. It will only work on systems with the same or newer glibc.

### Option 2: Docker Build (Recommended for Distribution)

Build inside an Ubuntu 22.04 container for maximum compatibility:

```bash
./build_appimage_docker.sh
```

**Advantages**:
- Builds against glibc 2.35 (Ubuntu 22.04)
- Works on Ubuntu 22.04+ and equivalent distros from 2022 onwards
- Reproducible builds regardless of your host system
- Isolated environment with all dependencies

**Requirements**:
- Docker installed and running
- User must be in the docker group: `sudo usermod -aG docker $USER`

## Build Output

After building, you'll get:

- `Hello_World-{arch}.AppImage` - The distributable AppImage file
- `appimage_build/` - Build artifacts directory (can be deleted, included in .gitignore)

## Running the AppImage

Simply make it executable and run:

```bash
chmod +x Hello_World-*.AppImage
./Hello_World-*.AppImage
```

Or double-click it in a file manager.

## Testing the AppImage

### Quick Dependency Check

Extract and inspect the AppImage without running:

```bash
./Hello_World-*.AppImage --appimage-extract
ldd squashfs-root/usr/bin/hello_world
ls -R squashfs-root/usr/bin/assets/
rm -rf squashfs-root
```

### Test in Clean Environment (Docker)

Test on Ubuntu 22.04:

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --device /dev/dri \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  ubuntu:22.04 bash

# Inside container:
apt update && apt install -y libgl1 libxcb1 libxcursor1 libxi6 libxrandr2 fuse
cd /app
./Hello_World-*.AppImage
```

Test on Ubuntu 24.04 (or newer):

```bash
# Same command but with ubuntu:24.04
```

## Desktop Integration

By default, AppImages don't integrate with the system (no menu entry or taskbar icon). Users have two options:

### Option 1: Manual Desktop Entry

Users can create a desktop entry manually:

```bash
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/hello_world.desktop << EOF
[Desktop Entry]
Type=Application
Name=Hello World
Comment=HelloImGui Demo Application
Exec=/full/path/to/Hello_World-*.AppImage
Icon=/full/path/to/icon.png
Categories=Utility;Graphics;
Terminal=false
EOF
```

### Option 2: AppImageLauncher

Recommend users install [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher), which automatically integrates AppImages when first run.

## Distribution

### Compatibility

The AppImage is compatible with:
- **Built with docker**: Ubuntu 22.04+ and equivalent distributions (2022 onwards)
- **Built natively**: Systems with glibc version ≥ your build system

### Bundled Libraries

The AppImage bundles:
- ✅ libglfw (window/input handling)
- ✅ libfreetype (font rendering)
- ✅ libpng, libbz2, libbrotli, libz (freetype dependencies)
- ❌ X11 libraries (expected to be present on target system)
- ❌ OpenGL libraries (expected to be present on target system)

### File Size

Typical AppImage size: ~20-30 MB (includes all bundled libraries and assets)

## Architecture Support

The build scripts automatically detect the host architecture:
- **x86_64**: Intel/AMD 64-bit systems
- **aarch64/arm64**: ARM 64-bit systems (Apple Silicon via VM, Raspberry Pi 4+, etc.)

Cross-compilation is not currently supported - build on the target architecture.

## Troubleshooting

### FUSE errors

If you see "Cannot mount AppImage, please check your FUSE setup":

```bash
# Extract and run directly
./Hello_World-*.AppImage --appimage-extract
./squashfs-root/AppRun
```

### glibc version errors

If you see "version `GLIBC_X.XX' not found":
- The AppImage was built on a newer system than the target
- Solution: Rebuild using `build_appimage_docker.sh` for Ubuntu 22.04 compatibility

### Missing libraries

If you see "cannot open shared object file":
- Install the missing library on your system
- Common: `libgl1`, `libxcb1`, `libxcursor1`, `libxi6`, `libxrandr2`

## Build Artifacts

All build artifacts are organized in the `appimage_build/` directory:
- `appimage_build/build/` - CMake build directory
- `appimage_build/install/` - Installation directory
- `appimage_build/AppDir/` - AppImage directory structure
- `appimage_build/linuxdeploy-*.AppImage` - LinuxDeploy tool

This directory is gitignored and can be safely deleted. It will be recreated on each build.

## Technical Details

### Build Process

1. Configure CMake with Release build type
2. Build the hello_world executable
3. Install to `appimage_build/install/`
4. Create AppDir structure with executable, assets, and libraries
5. Download linuxdeploy tool (architecture-specific)
6. Bundle dependencies and create AppImage
7. Move final AppImage to project root

### Assets

Assets are copied from the installation directory and placed next to the executable inside the AppImage:
```
AppDir/
└── usr/
    └── bin/
        ├── hello_world
        └── assets/
            ├── app_settings/
            ├── fonts/
            └── world.jpg
```

The application expects assets to be in this relative location.

## Further Reading

- [AppImage Documentation](https://docs.appimage.org/)
- [LinuxDeploy Documentation](https://github.com/linuxdeploy/linuxdeploy)
- [HelloImGui Documentation](https://pthom.github.io/hello_imgui/)
