# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub OSS project structure reorganization
- Comprehensive documentation in `docs/` directory
- GitHub Issue and Pull Request templates
- CI/CD workflows for automated testing and releases
- Example CSV files in `examples/` directory
- Build scripts organized in `scripts/` directory
- Security policy documentation

### Changed
- Reorganized project structure following GitHub OSS best practices
- Improved README with updated directory structure
- Enhanced build system documentation

## [1.0.0] - 2025-07-26

### Added
- Initial release of cj CSV to JSON converter
- Command-line interface with basic and styled output options
- Cross-platform support (Linux, macOS, Windows)
- Multiple architecture support (x86_64, ARM64, i386)
- Dynamic memory management for unlimited file sizes
- RFC 4180 compliant CSV parsing
- Multiline field support with proper quote handling
- Automatic numeric type detection
- Special character escaping in JSON output
- Comprehensive test suite (37 tests)
- Cross-platform build system with Makefile
- Build scripts for Unix/Linux/macOS (`build.sh`) and Windows (`build.bat`)
- Memory leak detection and prevention
- Error handling with clear user messages

### Features
- **CSV Parsing**: 
  - RFC 4180 compliance with extensions
  - Multiline fields within quotes
  - Mixed quote type support (single and double)
  - Various newline format support (Unix, Windows, mixed)
  - Escaped quote handling
  - Large file support with dynamic memory allocation

- **JSON Output**:
  - Compact and styled (pretty-printed) output modes
  - Automatic numeric type detection
  - Proper JSON string escaping
  - UTF-8 encoding support

- **Cross-Platform Support**:
  - Linux x86_64 (AMD64) and ARM64 (AArch64)
  - macOS Intel (x86_64) and Apple Silicon (ARM64)
  - Windows x86_64 (AMD64), i386 (32-bit), and ARM64 (AArch64)
  - Native compilation and cross-compilation support

- **Build System**:
  - Comprehensive Makefile with platform detection
  - Cross-compilation targets for all supported platforms
  - Build scripts with dependency checking
  - Distribution package creation
  - CI/CD integration ready

- **Testing**:
  - 37 comprehensive tests covering all functionality
  - Edge case testing (empty fields, special characters, large files)
  - Memory leak testing integration
  - Cross-platform test validation

### Technical Details
- **Language**: C99 standard
- **Dependencies**: None (standard C library only)
- **Memory Management**: Dynamic allocation with automatic cleanup
- **Performance**: Optimized for both speed and memory efficiency
- **Security**: Input validation and safe string handling

### Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|---------|
| Linux | x86_64 (AMD64) | ✅ Full support |
| Linux | ARM64 (AArch64) | ✅ Full support |
| macOS | Intel (x86_64) | ✅ Full support |
| macOS | Apple Silicon (ARM64) | ✅ Full support |
| Windows | x86_64 (AMD64) | ✅ Full support |
| Windows | i386 (32-bit) | ✅ Full support |
| Windows | ARM64 (AArch64) | ✅ Full support |

### Command Line Interface

```bash
# Basic usage
./cj input.csv                    # Convert to compact JSON
./cj --styled input.csv           # Convert to formatted JSON
./cj -s input.csv                 # Short form of --styled
./cj version                      # Show version information
./cj                              # Show usage help
```

### Build Requirements
- C99 compiler (GCC 4.9+, Clang 3.5+, MSVC 2015+)
- Make (GNU Make or compatible)
- Cross-compilation tools (optional)

### Installation
```bash
# Build from source
git clone https://github.com/iqbqioza/cj.git
cd cj
make
sudo make install

# Cross-platform builds
make build-all
```

---

## Release Notes

### v1.0.0 Release Highlights

This initial release provides a robust, cross-platform CSV to JSON converter with the following key features:

1. **Universal Compatibility**: Works on all major platforms and architectures
2. **RFC 4180 Compliance**: Handles complex CSV scenarios correctly
3. **Memory Efficient**: No limits on file size, dynamic memory management
4. **Developer Friendly**: Comprehensive test suite and build system
5. **Production Ready**: Error handling, validation, and proper resource cleanup

The tool has been extensively tested across platforms and is ready for production use in data processing pipelines, ETL workflows, and general CSV to JSON conversion tasks.

---

## Upgrading

### From Development to v1.0.0
- No breaking changes
- All existing functionality preserved
- New features are additive

### Future Upgrades
- This project follows semantic versioning
- Breaking changes will increment major version
- New features increment minor version
- Bug fixes increment patch version

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for information on contributing to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.