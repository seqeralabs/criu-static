# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a CMake-based build system for creating a statically linked version of CRIU (Checkpoint/Restore In Userspace) along with all its dependencies. The project builds CRIU v4.1 with all necessary libraries statically compiled to produce a self-contained binary and libcriu.o object file.

## Build Commands

### Configure the build
```bash
cmake --preset static-release
```

### Build the project
```bash
cmake --build --preset static-release
```

### Install or package
```bash
# Install directly
sudo cmake --install build

# Create package
cpack --config build/CPackConfig.cmake --verbose -B dist -G STGZ
```

### Alternative presets
- `static-debug` - Debug build with debug symbols
- `static-release` - Release build (default, optimized)

## Architecture

### Build System Structure

The project uses a sophisticated CMake build system that:

1. **External Dependencies**: Downloads and builds all CRIU dependencies from source as static libraries:
   - Protocol Buffers (protobuf & protobuf-c)
   - Network libraries (libnet, libnl, libmnl, libnftnl, libnftables)
   - System libraries (libcap, libaio, zlib, util-linux uuid, libintl)

2. **Dependency Management**: Each dependency is managed via individual CMake files in `dependencies/` directory, using the `register_dependency()` macro from `macros/dependencies.cmake`

3. **CRIU Integration**: The main CRIU build is handled as an ExternalProject that:
   - Downloads CRIU source code
   - Applies patches from `patch/` directory for static building
   - Compiles with all dependencies statically linked
   - Includes CUDA plugin compilation

### Key Components

- **CMakeLists.txt**: Main build configuration, sets up all dependencies and CRIU build
- **CMakePresets.json**: Defines build presets for different configurations  
- **dependencies/*.cmake**: Individual dependency build configurations
- **macros/dependencies.cmake**: Macro for registering dependencies with license tracking
- **patch/**: Contains patches applied to CRIU for static building support
- **jreleaser.yml**: Release configuration for GitHub releases

### Build Process Flow

1. Configure phase downloads and builds all static dependencies in order
2. CRIU source is downloaded and patched for static plugin support
3. CRIU is built with custom CFLAGS/LDFLAGS pointing to static dependencies
4. Final artifacts are installed: `criu` binary, `libcriu.o` object file, headers, and CUDA plugin

### Static Plugin Architecture

The build enables static plugins (STATIC_PLUGINS=y) and specifically compiles the CUDA plugin statically into the main binary rather than as a shared library, controlled by patches in `patch/criu-static-plugin.patch`.

### License Management

The build system automatically tracks all dependency licenses and consolidates them into `THIRD-PARTY-LICENSES.txt` for distribution compliance.