# Build Scripts

This directory contains build automation scripts for the cj project.

## Scripts

### build.sh
Cross-platform build script for Unix-like systems (Linux, macOS).

**Features:**
- Automatic dependency checking
- Cross-platform compilation support
- Colored output and progress reporting
- Comprehensive error handling
- Distribution package creation

**Usage:**
```bash
# Make executable (first time)
chmod +x scripts/build.sh

# Check dependencies only
./scripts/build.sh --check

# Build all supported platforms
./scripts/build.sh

# Build specific target
./scripts/build.sh --target linux-amd64
./scripts/build.sh --target darwin-arm64
./scripts/build.sh --target windows-amd64

# Run tests before building
./scripts/build.sh --test

# Skip distribution package creation
./scripts/build.sh --no-dist

# Show help
./scripts/build.sh --help
```

**Supported Targets:**
- `linux-amd64` - Linux x86_64
- `linux-arm64` - Linux ARM64
- `darwin-amd64` - macOS Intel
- `darwin-arm64` - macOS Apple Silicon
- `windows-amd64` - Windows x86_64
- `windows-i386` - Windows i386
- `windows-arm64` - Windows ARM64

### build.bat
Windows-specific build script for Windows environments.

**Features:**
- Automatic compiler detection (GCC/MSVC)
- Architecture detection
- Colored console output
- Binary testing and validation

**Usage:**
```batch
REM Run from Windows command prompt or PowerShell
scripts\build.bat

REM Or from project root (using symlink)
build.bat
```

**Requirements:**
- MinGW-w64 or Visual Studio Build Tools
- Windows SDK (for MSVC builds)

### release.sh
Release automation script for creating and publishing releases.

**Features:**
- Version validation and tagging
- Automatic VERSION file updates
- CHANGELOG.md verification
- Git status checking
- Dry-run support for testing

**Usage:**
```bash
# Create and push a release tag
./scripts/release.sh 1.0.1

# Preview what would happen (dry run)
./scripts/release.sh 1.1.0-beta.1 --dry-run

# Create tag locally but don't push
./scripts/release.sh 1.0.2 --no-push

# Force overwrite existing tag
./scripts/release.sh 1.0.1 --force

# Show help
./scripts/release.sh --help
```

**Release Process:**
1. Validates version format (semantic versioning)
2. Checks git working directory is clean
3. Optionally updates VERSION file
4. Creates annotated git tag with release notes
5. Pushes tag to trigger GitHub Actions release workflow
6. GitHub Actions builds all platform binaries and creates release

**Supported Version Formats:**
- `1.0.0` - Standard release
- `1.1.0-beta.1` - Pre-release
- `2.0.0-rc.1` - Release candidate

## Backward Compatibility

For backward compatibility, symlinks are provided in the project root:
- `build.sh` → `scripts/build.sh`
- `build.bat` → `scripts/build.bat`

This allows existing documentation and workflows to continue working without changes.

## Adding New Scripts

When adding new build or utility scripts:

1. **Place in scripts/ directory**
2. **Make executable** (for shell scripts): `chmod +x scripts/newscript.sh`
3. **Add documentation** to this README
4. **Test on target platforms**
5. **Update CI/CD** if needed

## Script Development Guidelines

### Shell Scripts (Unix/Linux/macOS)

```bash
#!/bin/bash
set -e  # Exit on error
set -u  # Exit on undefined variable

# Use consistent error handling
log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# Check dependencies
check_dependencies() {
    command -v make >/dev/null 2>&1 || {
        log_error "make is required but not installed"
        exit 1
    }
}
```

### Batch Scripts (Windows)

```batch
@echo off
setlocal enabledelayedexpansion

REM Use consistent error handling
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)

REM Check for required tools
where gcc >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] GCC not found
    exit /b 1
)
```

## Integration with Make

The scripts integrate with the Makefile build system:

```bash
# Makefile can call scripts
make build-all    # Uses native Make targets
./scripts/build.sh  # Uses build script with additional features
```

**When to use scripts vs Make:**
- **Make**: Simple, single-platform builds
- **Scripts**: Complex workflows, dependency checking, package creation

## CI/CD Integration

The scripts are designed to work in CI/CD environments:

### GitHub Actions
```yaml
- name: Build all platforms
  run: |
    chmod +x scripts/build.sh
    ./scripts/build.sh --check
    ./scripts/build.sh
```

### Local Development
```bash
# Quick development build
make

# Full release build with packages
./scripts/build.sh --test
```

## Troubleshooting

### Common Issues

1. **Permission denied**
   ```bash
   chmod +x scripts/build.sh
   ```

2. **Cross-compiler not found**
   ```bash
   # Check what's available
   ./scripts/build.sh --check
   
   # Install missing tools (Ubuntu/Debian)
   sudo apt-get install gcc-aarch64-linux-gnu gcc-mingw-w64
   ```

3. **Windows script execution policy**
   ```powershell
   # Allow script execution
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

4. **Make not found on Windows**
   ```bash
   # Use batch script instead
   scripts\build.bat
   ```

### Debug Mode

Enable debug output in scripts:

```bash
# For build.sh
DEBUG=1 ./scripts/build.sh

# For detailed Make output
VERBOSE=1 make
```

## Platform-Specific Notes

### Linux
- Requires build-essential package
- Cross-compilation tools optional but recommended
- Works with most distributions

### macOS
- Requires Xcode Command Line Tools
- Supports both Intel and Apple Silicon
- Universal binary creation possible

### Windows
- Supports MinGW-w64 and MSVC
- Batch script handles both 32-bit and 64-bit
- PowerShell support for advanced features

## Future Enhancements

Planned script improvements:

1. **Docker support**: Containerized builds
2. **Package managers**: Integration with apt, brew, choco
3. **Code signing**: For release binaries
4. **Benchmarking**: Performance measurement scripts
5. **Documentation**: Auto-generated docs from source