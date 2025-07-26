# Contributing to cj

Thank you for your interest in contributing to cj! This document provides guidelines for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Release Process](#release-process)

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

- C99-compatible compiler (GCC 4.9+, Clang 3.5+, or MSVC 2015+)
- GNU Make or compatible
- Git

### Quick Start

```bash
git clone https://github.com/iqbqioza/cj.git
cd cj
make
make test
```

## Development Setup

### Building

```bash
# Build for current platform
make

# Build for all supported platforms
make build-all

# Cross-compilation (if tools available)
make build-linux-amd64
make build-windows-arm64
```

### Using Build Scripts

```bash
# Unix/Linux/macOS
./build.sh --test

# Windows
build.bat
```

## Making Changes

### Branch Naming

- `feat/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation changes
- `refactor/description` - Code refactoring
- `test/description` - Test improvements

### Commit Messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add support for custom delimiters
fix: handle empty CSV files correctly
docs: update installation instructions
test: add edge cases for multiline fields
chore: update build dependencies
```

**Types:**
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code formatting
- `refactor:` Code refactoring
- `test:` Test additions/modifications
- `chore:` Build system, dependencies

## Testing

### Running Tests

```bash
# Run all tests
make test

# Check available build tools
make check-tools

# Show platform information
make info
```

### Test Categories

Our test suite covers:
- Basic CSV parsing and JSON output
- Complex scenarios (multiline fields, quotes, special characters)
- Cross-platform compatibility
- Error handling
- Memory management
- Performance with large files

### Adding Tests

When adding new features:

1. Add test cases to `test/test_cj.c`
2. Create sample CSV files in `test/` directory if needed
3. Ensure all existing tests continue to pass
4. Test on multiple platforms if possible

## Submitting Changes

### Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch from `main`
3. **Make** your changes following our coding standards
4. **Add** or update tests as needed
5. **Ensure** all tests pass: `make test`
6. **Update** documentation if needed
7. **Commit** using conventional commit format
8. **Push** to your fork
9. **Create** a Pull Request

### Pull Request Template

```markdown
## Summary
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring

## Testing
- [ ] All existing tests pass
- [ ] New tests added for new functionality
- [ ] Tested on multiple platforms (if applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## Coding Standards

### C Code Style

- **Standard**: C99
- **Indentation**: 4 spaces, no tabs
- **Line length**: 120 characters maximum
- **Naming**: `snake_case` for functions and variables
- **Comments**: Use `//` for single-line, `/* */` for multi-line

### Memory Management

- Always free allocated memory
- Check for allocation failures
- Use dynamic allocation for scalability
- Avoid fixed-size buffers when possible

### Error Handling

- Check return values from system calls
- Provide meaningful error messages
- Use consistent error codes
- Clean up resources on error paths

### Platform Compatibility

- Use platform detection macros (`src/platform.h`)
- Test on multiple platforms when possible
- Handle different newline formats
- Consider endianness for binary operations

## Architecture Guidelines

### File Organization

```
cj/
├── src/           # Source code
├── test/          # Test files and data
├── docs/          # Documentation
├── scripts/       # Build and utility scripts
└── .github/       # GitHub-specific files
```

### Module Structure

- `src/main.c` - Entry point and CLI handling
- `src/csv_parser.c` - CSV parsing logic
- `src/json_output.c` - JSON generation
- `src/utils.c` - Utility functions
- `src/platform.c` - Platform-specific code

## Release Process

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- `MAJOR`: Breaking changes
- `MINOR`: New features (backward compatible)
- `PATCH`: Bug fixes

### Release Checklist

1. Update version in source code
2. Update CHANGELOG.md
3. Run full test suite on all platforms
4. Create release builds
5. Tag release: `git tag v1.0.0`
6. Create GitHub release with binaries

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/iqbqioza/cj/issues)
- **Discussions**: [GitHub Discussions](https://github.com/iqbqioza/cj/discussions)
- **Documentation**: Check `README.md` and `docs/` directory

## Recognition

Contributors are recognized in:
- `CONTRIBUTORS.md`
- GitHub contributor graphs
- Release notes for significant contributions

Thank you for contributing to cj! 🚀