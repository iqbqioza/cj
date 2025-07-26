# Build Documentation

This document provides comprehensive build instructions for the cj CSV to JSON converter.

## Quick Start

```bash
# Clone and build
git clone https://github.com/iqbqioza/cj.git
cd cj
make

# Test
make test

# Install (optional)
sudo make install
```

## Build Requirements

### Minimum Requirements

- **C99 Compiler**: GCC 4.9+, Clang 3.5+, or MSVC 2015+
- **Make**: GNU Make or compatible build tool
- **Git**: For source code management

### Platform-Specific Requirements

#### Linux
```bash
# Ubuntu/Debian
sudo apt-get install build-essential

# CentOS/RHEL/Fedora
sudo yum install gcc make
# or
sudo dnf install gcc make
```

#### macOS
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Or install full Xcode from App Store
```

#### Windows

**Option 1: MinGW-w64 (Recommended)**
```bash
# Using MSYS2
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-make

# Using Chocolatey
choco install mingw

# Using winget
winget install MinGW.MinGW
```

**Option 2: Visual Studio**
- Visual Studio 2015 or later
- Visual Studio Build Tools
- Windows SDK

## Basic Build Commands

### Native Build

```bash
# Build for current platform
make

# Show platform information
make info

# Clean build artifacts
make clean
```

### Build Targets

```bash
# Build and run tests
make test

# Install to system (Linux/macOS)
sudo make install

# Uninstall from system
sudo make uninstall

# Show all available targets
make help
```

## Cross-Platform Building

### Cross-Compilation Setup

#### Linux Cross-Compilation

```bash
# Install cross-compilers
sudo apt-get install gcc-aarch64-linux-gnu    # ARM64
sudo apt-get install gcc-mingw-w64-x86-64     # Windows x64
sudo apt-get install gcc-mingw-w64-i686       # Windows i386

# Check available tools
make check-tools
```

#### macOS Cross-Compilation

```bash
# No additional setup needed for macOS targets
# Xcode tools support both Intel and Apple Silicon
```

### Cross-Build Commands

```bash
# Linux targets
make build-linux-amd64      # Linux x86_64
make build-linux-arm64      # Linux ARM64

# macOS targets  
make build-darwin-amd64     # macOS Intel
make build-darwin-arm64     # macOS Apple Silicon

# Windows targets
make build-windows-amd64    # Windows x86_64
make build-windows-i386     # Windows i386
make build-windows-arm64    # Windows ARM64

# Build all platforms
make build-all
```

### Build Output

Cross-compiled binaries are placed in the `build/` directory:

```
build/
├── cj-linux-amd64
├── cj-linux-arm64
├── cj-darwin-amd64
├── cj-darwin-arm64
├── cj-windows-amd64.exe
├── cj-windows-i386.exe
└── cj-windows-arm64.exe
```

## Build Scripts

### Unix/Linux/macOS Build Script

```bash
# Make executable
chmod +x build.sh

# Check dependencies
./build.sh --check

# Build all platforms
./build.sh

# Build specific target
./build.sh --target linux-amd64
./build.sh --target darwin-arm64
./build.sh --target windows-amd64

# Run tests before building
./build.sh --test

# Skip distribution packages
./build.sh --no-dist
```

### Windows Build Script

```batch
# Run Windows build script
build.bat

# The script will:
# 1. Detect your Windows architecture
# 2. Find available compilers (GCC or MSVC)
# 3. Build the project
# 4. Test the executable
```

## Advanced Build Options

### Custom Compiler Flags

```bash
# Debug build
CFLAGS="-Wall -Wextra -std=c99 -g -O0" make

# Release build with optimization
CFLAGS="-Wall -Wextra -std=c99 -O3 -DNDEBUG" make

# Static linking (useful for distribution)
CFLAGS="-Wall -Wextra -std=c99 -O2 -static" make
```

### Custom Compiler

```bash
# Use specific compiler
CC=clang make
CC=gcc-9 make

# Cross-compilation with custom compiler
CC=aarch64-linux-gnu-gcc make
```

### Build Variants

```bash
# Build with specific flags for platform
make build-linux-amd64 EXTRA_CFLAGS="-march=native"
make build-darwin-arm64 EXTRA_CFLAGS="-mcpu=apple-m1"
```

## Distribution Building

### Create Distribution Packages

```bash
# Build all platforms and create packages
make dist

# This creates:
# dist/cj-linux-amd64.tar.gz
# dist/cj-darwin-arm64.tar.gz
# dist/cj-windows-amd64.tar.gz
# ... plus SHA256 checksums
```

### Manual Distribution

```bash
# Build all platforms
make build-all

# Create custom package
mkdir -p package/cj-1.0.0
cp build/cj-linux-amd64 package/cj-1.0.0/cj
cp README.md LICENSE CHANGELOG.md package/cj-1.0.0/
cd package && tar -czf cj-1.0.0-linux-amd64.tar.gz cj-1.0.0/
```

## Troubleshooting

### Common Build Issues

#### 1. Compiler Not Found

```bash
# Check available compilers
which gcc clang
gcc --version
clang --version

# Install compiler
# Ubuntu/Debian
sudo apt-get install build-essential

# macOS
xcode-select --install
```

#### 2. Cross-Compiler Not Available

```bash
# Check what's available
make check-tools

# Install missing cross-compilers
sudo apt-get install gcc-aarch64-linux-gnu gcc-mingw-w64
```

#### 3. Make Not Found (Windows)

```bash
# Install make via MSYS2
pacman -S make

# Or use build.bat instead
build.bat
```

#### 4. Permission Denied

```bash
# Make scripts executable
chmod +x build.sh

# Use sudo for system install
sudo make install
```

### Build Environment Issues

#### 1. Path Issues

```bash
# Ensure tools are in PATH
export PATH="/usr/local/bin:$PATH"

# For MinGW on Windows
export PATH="/mingw64/bin:$PATH"
```

#### 2. Architecture Detection

```bash
# Check detected platform
make info

# Override if necessary
PLATFORM=linux ARCH=amd64 make
```

#### 3. Cross-Compilation Failures

```bash
# Some cross-compilers may not be available
# The build will continue with available tools

# Check what was built
ls -la build/
```

## CI/CD Integration

### GitHub Actions

The project includes comprehensive CI/CD workflows:

- **`.github/workflows/ci.yml`**: Continuous integration
- **`.github/workflows/release.yml`**: Release automation

### Local CI Testing

```bash
# Run the same tests as CI
make test

# Static analysis (if tools available)
cppcheck --enable=all src/
clang-tidy src/*.c

# Memory testing (Linux)
valgrind --leak-check=full ./cj test/basic.csv
```

## Performance Optimization

### Compiler Optimizations

```bash
# Maximum optimization
CFLAGS="-O3 -march=native -flto" make

# Size optimization
CFLAGS="-Os -s" make

# Debug optimization (for profiling)
CFLAGS="-O2 -g" make
```

### Platform-Specific Optimizations

```bash
# ARM64 optimizations
CFLAGS="-O3 -march=armv8-a+simd" make build-linux-arm64

# x86_64 optimizations
CFLAGS="-O3 -march=x86-64 -mtune=generic" make build-linux-amd64
```

## Maintenance

### Keeping Build System Updated

1. **Check for new compiler versions**
2. **Update cross-compilation tools**
3. **Test on new platforms**
4. **Update CI/CD as needed**

### Adding New Platforms

1. **Update `platform.h`** with detection macros
2. **Add Makefile target** for new platform
3. **Update build scripts** with new target
4. **Add CI/CD support** if possible
5. **Update documentation**