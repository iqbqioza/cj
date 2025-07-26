# cj - Command-line CSV to JSON converter

[![GitHub release](https://img.shields.io/github/release/iqbqioza/cj.svg)](https://github.com/iqbqioza/cj/releases)
[![GitHub issues](https://img.shields.io/github/issues/iqbqioza/cj.svg)](https://github.com/iqbqioza/cj/issues)
[![GitHub license](https://img.shields.io/github/license/iqbqioza/cj.svg)](https://github.com/iqbqioza/cj/blob/main/LICENSE)
[![CI](https://github.com/iqbqioza/cj/workflows/CI/badge.svg)](https://github.com/iqbqioza/cj/actions)

A fast, robust CSV to JSON converter written in C that handles complex CSV scenarios including multiline fields, quoted data, and various newline formats.

## Features

- **Dynamic Memory Management**: Handles CSV files of any size (unlimited rows, fields, and field length)
- **Multiline Field Support**: Properly parses fields containing newlines within quotes
- **Quote Handling**: Supports both single and double quotes with proper escaping
- **Newline Format Support**: Handles Unix (LF), Windows (CRLF), and mixed newline formats
- **Automatic Type Detection**: Automatically detects numeric values vs. text
- **JSON Escaping**: Properly escapes special characters in JSON output
- **Styled Output**: Optional formatted JSON with indentation
- **Zero Dependencies**: Pure C implementation with no external libraries

## Installation

### Build from Source

#### Quick Build (Current Platform)
```bash
git clone https://github.com/iqbqioza/cj.git
cd cj
make
```

#### Cross-Platform Build
```bash
# Build for all supported platforms
make build-all

# Build for specific platforms
make build-linux-amd64    # Linux x86_64
make build-linux-arm64    # Linux ARM64
make build-darwin-amd64   # macOS Intel
make build-darwin-arm64   # macOS Apple Silicon
make build-windows-amd64  # Windows x86_64
make build-windows-i386   # Windows i386
make build-windows-arm64  # Windows ARM64

# Using the build script (recommended)
./scripts/build.sh                # Build all platforms
./scripts/build.sh --target linux-amd64   # Build specific target
./scripts/build.sh --target windows-amd64 # Build for Windows x64
./scripts/build.sh --target windows-arm64 # Build for Windows ARM64
./scripts/build.sh --test         # Run tests before building

# Or use symlinks in project root for backward compatibility
./build.sh                # Same as scripts/build.sh
```

#### Windows Build
```batch
REM On Windows systems
scripts\build.bat         # Build using batch script
REM Or using make (if available)
make                      # Build for current Windows platform

REM Or use symlinks in project root
build.bat                 # Same as scripts\build.bat
```

#### Check Platform Support
```bash
make info          # Show current platform
make check-tools   # Check available compilers
make help          # Show all available targets
```

### Project Structure

```
cj/
├── .github/                    # GitHub-specific files
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   │   ├── bug_report.yml      # Bug report template
│   │   └── feature_request.yml # Feature request template
│   ├── workflows/              # GitHub Actions workflows
│   │   ├── ci.yml              # Continuous integration
│   │   └── release.yml         # Release automation
│   └── pull_request_template.md # Pull request template
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md         # Architecture documentation
│   ├── BUILD.md                # Build instructions
│   └── API.md                  # API documentation
├── examples/                   # Example CSV files
│   ├── basic.csv               # Basic usage example
│   ├── multiline.csv           # Multiline fields example
│   ├── numeric.csv             # Numeric data example
│   └── README.md               # Examples documentation
├── scripts/                    # Build and utility scripts
│   ├── build.sh                # Unix/Linux/macOS build script
│   ├── build.bat               # Windows build script
│   └── README.md               # Scripts documentation
├── src/                        # Source code
│   ├── cj.h                    # Header file with declarations
│   ├── main.c                  # Main program entry point
│   ├── utils.c                 # Utility functions
│   ├── csv_parser.c            # CSV parsing logic
│   ├── json_output.c           # JSON formatting and output
│   ├── platform.h              # Platform detection
│   ├── platform.c              # Platform-specific code
│   └── *.o                     # Object files (generated)
├── test/                       # Test suite and data
│   ├── test_cj.c               # Test suite
│   ├── *.csv                   # Test data files
│   └── test_cj                 # Test executable (generated)
├── build/                      # Cross-compiled binaries (generated)
│   ├── cj-linux-amd64         # Linux x86_64 binary
│   ├── cj-linux-arm64         # Linux ARM64 binary
│   ├── cj-darwin-amd64        # macOS Intel binary
│   ├── cj-darwin-arm64        # macOS Apple Silicon binary
│   ├── cj-windows-amd64.exe   # Windows x86_64 binary
│   ├── cj-windows-i386.exe    # Windows i386 binary
│   └── cj-windows-arm64.exe   # Windows ARM64 binary
├── dist/                       # Distribution packages (generated)
│   ├── *.tar.gz                # Distribution packages
│   └── *.sha256                # Checksums
├── build.sh                    # Build script (symlink to scripts/build.sh)
├── build.bat                   # Build script (symlink to scripts/build.bat)
├── Makefile                    # Build configuration
├── CHANGELOG.md                # Change log
├── CONTRIBUTING.md             # Contributing guidelines
├── LICENSE                     # MIT License
├── README.md                   # This file
├── SECURITY.md                 # Security policy
├── VERSION                     # Version file
├── .gitignore                  # Git ignore rules
└── cj                          # Main executable (generated)
```

### System Installation (Optional)

```bash
make install    # Install to /usr/local/bin/
make uninstall  # Remove from system
```

## Usage

### Basic Usage

```bash
# Convert CSV to compact JSON
./cj data.csv

# Convert CSV to formatted JSON
./cj --styled data.csv
./cj -s data.csv

# Show version
./cj version

# Show help
./cj
```

### Command Options

| Option | Description |
|--------|-------------|
| `filename` | Convert specified CSV file to JSON |
| `--styled`, `-s` | Output formatted JSON with indentation |
| `version` | Display version information |
| (no args) | Display usage help |

## Examples

### Basic CSV

**Input CSV (`data.csv`):**
```csv
no,name,title,memo,datetime
1,Joe,Hello World,,2025-07-26 10:24:00
2,Jack,Lorem Ipsum,,2025-10-24 10:24:00
```

**Command:**
```bash
./cj data.csv
```

**Output:**
```json
[{"no": 1,"name": "Joe","title": "Hello World","memo": "","datetime": "2025-07-26 10:24:00"},{"no": 2,"name": "Jack","title": "Lorem Ipsum","memo": "","datetime": "2025-10-24 10:24:00"}]
```

### Styled Output

**Command:**
```bash
./cj --styled data.csv
```

**Output:**
```json
[
  {
    "no": 1,
    "name": "Joe",
    "title": "Hello World",
    "memo": "",
    "datetime": "2025-07-26 10:24:00"
  },
  {
    "no": 2,
    "name": "Jack",
    "title": "Lorem Ipsum",
    "memo": "",
    "datetime": "2025-10-24 10:24:00"
  }
]
```

### Complex CSV with Multiline Fields

**Input CSV (`complex.csv`):**
```csv
no,name,title,memo,datetime
1,Joe,Hello World,,2025-07-26 10:24:00
2,Jack,Lorem Ipsum,,2025-10-24 10:24:00
3,"Alice","Multiline
description with
special chars: ""quoted""","Complex, data"
```

**Command:**
```bash
./cj --styled complex.csv
```

**Output:**
```json
[
  {
    "no": 1,
    "name": "Joe",
    "title": "Hello World",
    "memo": "",
    "datetime": "2025-07-26 10:24:00"
  },
  {
    "no": 2,
    "name": "Jack",
    "title": "Lorem Ipsum",
    "memo": "",
    "datetime": "2025-10-24 10:24:00"
  },
  {
    "no": 3,
    "name": "Alice",
    "title": "Multiline\ndescription with\nspecial chars: \"quoted\"",
    "memo": "Complex, data"
  }
]
```

### Quoted Fields and Special Characters

**Input CSV (`quotes.csv`):**
```csv
id,name,description,quote
1,"John Doe","A, B, C","He said ""Hello"""
2,'Jane Smith',"Line 1
Line 2","She said 'Hi'"
```

**Features Demonstrated:**
- Comma-separated values within quoted fields
- Escaped quotes (`""` becomes `"`)
- Mixed quote types (single and double)
- Multiline content within quotes

### Numeric Type Detection

**Input CSV (`numbers.csv`):**
```csv
integer,float,negative,text,mixed
42,3.14,-10,abc123,123abc
100,2.718,-5.5,hello,456def
```

**Output:**
```json
[
  {
    "integer": 42,
    "float": 3.14,
    "negative": -10,
    "text": "abc123",
    "mixed": "123abc"
  },
  {
    "integer": 100,
    "float": 2.718,
    "negative": -5.5,
    "text": "hello",
    "mixed": "456def"
  }
]
```

## Advanced Features

### Multiline Field Handling

The tool correctly handles CSV fields that span multiple lines when properly quoted:

```csv
id,notes
1,"First line
Second line
Third line"
2,"Single line"
```

**Special Characters in JSON Output:**
- Newlines (`\n`) → `\\n`
- Carriage returns (`\r`) → `\\r`
- Tabs (`\t`) → `\\t`
- Quotes (`"`) → `\\"`
- Backslashes (`\`) → `\\\\`

### Cross-Platform Newline Support

The tool handles various newline formats:
- **Unix/Linux**: LF (`\n`)
- **Windows**: CRLF (`\r\n`)
- **Mixed**: Combination of both
- **Quoted fields**: Newlines preserved within quotes

### Large File Support

No built-in limits on:
- Number of rows
- Number of columns
- Field content length
- Line length

Memory usage grows dynamically as needed.

## Testing

The project includes a comprehensive test suite:

```bash
# Run all tests
make test

# Clean build files
make clean
```

**Test Coverage:**
- Basic CSV conversion (4 tests)
- Styled output formatting (3 tests)
- Quoted field parsing (3 tests)
- Numeric type detection (4 tests)
- Large file processing (1 test)
- Empty field handling (2 tests)
- Command line interface (3 tests)
- Error handling (1 test)
- Special characters (3 tests)
- Multiline fields (4 tests)
- Complex newlines (5 tests)
- Edge cases (4 tests)

**Total: 37 tests**

## Error Handling

The tool provides clear error messages for common issues:

```bash
# File not found
$ ./cj nonexistent.csv
Error: Cannot open file 'nonexistent.csv'

# Invalid arguments
$ ./cj --invalid-option
Usage:
  cj [filename]           Convert CSV to JSON
  cj version              Show version
  cj --styled|-s [file]   Convert CSV to formatted JSON
  cj                      Show this help
```

## Supported Platforms

| Platform | Architecture | Status | Notes |
|----------|-------------|---------|-------|
| **Linux** | x86_64 (AMD64) | ✅ Supported | Native and cross-compilation |
| **Linux** | ARM64 (AArch64) | ✅ Supported | Cross-compilation available |
| **macOS** | Intel (x86_64) | ✅ Supported | Cross-compilation from Apple Silicon |
| **macOS** | Apple Silicon (ARM64) | ✅ Supported | Native compilation |
| **Windows** | x86_64 (AMD64) | ✅ Supported | MinGW-w64 cross-compilation, MSVC native |
| **Windows** | i386 (32-bit) | ✅ Supported | MinGW-w64 cross-compilation, MSVC native |
| **Windows** | ARM64 (AArch64) | ✅ Supported | MinGW-w64 cross-compilation, MSVC native |

### Build Requirements

#### Basic Requirements
- **C99 Compiler**: GCC 4.9+, Clang 3.5+, or MSVC 2015+
- **Make**: GNU Make or compatible (optional on Windows)

#### Cross-compilation Tools (optional)
- **Linux ARM64**: `aarch64-linux-gnu-gcc`
- **macOS targets**: Xcode Command Line Tools
- **Windows targets**: MinGW-w64 (`x86_64-w64-mingw32-gcc`, `i686-w64-mingw32-gcc`, `aarch64-w64-mingw32-gcc`)

#### Windows-specific
- **MinGW-w64**: For cross-compilation from Unix/Linux/macOS
- **MSVC**: Visual Studio Build Tools or Visual Studio
- **Windows SDK**: For native Windows development

## Performance

- **Memory Efficient**: Dynamic allocation prevents waste
- **Fast Processing**: Optimized C implementation
- **Minimal Dependencies**: No external libraries required
- **Cross-Platform**: Native binaries for multiple architectures
- **Static Linking**: Self-contained executables

## Limitations

1. **Quote Character Consistency**: Within a single field, the opening quote character (single or double) must match the closing quote character.

2. **CSV Standard Compliance**: Follows RFC 4180 with extensions for multiline fields and mixed quote types.

3. **Memory**: For extremely large files, memory usage will grow proportionally to file size.

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Start
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `make test`
5. Submit a pull request

### Documentation
- [Architecture Documentation](docs/ARCHITECTURE.md)
- [Build Instructions](docs/BUILD.md)
- [API Documentation](docs/API.md)
- [Branch Protection Setup](docs/BRANCH_PROTECTION.md)
- [Security Policy](SECURITY.md)

### Development Workflow

This project uses comprehensive CI/CD with branch protection:

- **All PRs require CI checks to pass** before merging
- **Automated testing** on Ubuntu, macOS, and Windows
- **Cross-platform compilation** verification
- **Memory leak detection** with Valgrind
- **Static code analysis** with cppcheck and clang-tidy

See [Contributing Guidelines](CONTRIBUTING.md) for detailed development workflow.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Version History

- **v0.1.0**: Initial release with basic CSV to JSON conversion
  - Dynamic memory management
  - Multiline field support
  - Cross-platform newline handling
  - Comprehensive test suite
  - Styled output option