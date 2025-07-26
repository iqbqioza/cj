# Architecture

This document describes the architecture and design of the cj CSV to JSON converter.

## Overview

cj is designed as a modular C application with clear separation of concerns. The architecture follows these principles:

- **Modularity**: Each functionality is separated into its own module
- **Cross-platform compatibility**: Platform-specific code is isolated
- **Memory safety**: Dynamic allocation with proper cleanup
- **Performance**: Optimized for both speed and memory usage

## Module Structure

```
src/
├── cj.h            # Main header with shared definitions
├── platform.h      # Platform detection and compatibility
├── main.c          # Entry point and CLI handling
├── csv_parser.c    # CSV parsing logic
├── json_output.c   # JSON formatting and output
├── utils.c         # Utility functions
└── platform.c      # Platform-specific implementations
```

## Core Components

### 1. Main Module (`main.c`)

**Responsibilities:**
- Command-line argument parsing
- Program flow control
- Error handling and exit codes
- Integration of all modules

**Key Functions:**
- `main()` - Entry point
- Argument validation and routing

### 2. CSV Parser (`csv_parser.c`)

**Responsibilities:**
- File I/O operations
- CSV format parsing according to RFC 4180
- Memory management for dynamic data structures
- Handling quoted fields and escape sequences

**Key Functions:**
- `read_csv()` - Main parsing function
- `read_csv_line()` - Line-by-line reading
- `parse_csv_line()` - Field parsing with quote handling
- `free_csv()` - Memory cleanup

**Data Structures:**
```c
typedef struct {
    char** headers;          // Column headers
    char*** data;           // Row data (2D array)
    int num_headers;        // Number of columns
    int num_rows;          // Number of data rows
    int headers_capacity;   // Allocated header capacity
    int rows_capacity;     // Allocated row capacity
    int* field_capacities; // Per-field capacity tracking
} CSVData;
```

### 3. JSON Output (`json_output.c`)

**Responsibilities:**
- JSON formatting and serialization
- Special character escaping
- Numeric type detection
- Styled output formatting

**Key Functions:**
- `print_json()` - Main JSON output function
- `print_json_value()` - Individual value formatting
- Type detection and appropriate JSON representation

### 4. Utilities (`utils.c`)

**Responsibilities:**
- Version information display
- Usage help text
- Numeric validation
- Common helper functions

**Key Functions:**
- `print_version()` - Version and platform info
- `print_usage()` - Help text
- `is_numeric()` - Number detection

### 5. Platform Layer (`platform.c`, `platform.h`)

**Responsibilities:**
- Platform detection at compile time
- Cross-platform compatibility
- Architecture-specific optimizations
- Build target information

**Features:**
- Automatic platform/architecture detection
- Compiler-specific compatibility macros
- Runtime platform information

## Data Flow

```
CSV File Input
     ↓
File Reading (csv_parser.c)
     ↓
Line Parsing (csv_parser.c)
     ↓
Data Structure Population (CSVData)
     ↓
JSON Conversion (json_output.c)
     ↓
Output Formatting
     ↓
Console Output
```

## Memory Management

### Dynamic Allocation Strategy

- **Headers**: Dynamically allocated array of strings
- **Data Rows**: Dynamically allocated 2D array
- **Field Content**: Each field dynamically allocated
- **Growth Strategy**: Double capacity when needed

### Memory Safety

- All allocations checked for failure
- Proper cleanup on error paths
- No fixed-size buffers for content
- Leak prevention through structured cleanup

## Error Handling

### Error Categories

1. **File Errors**: File not found, permission denied
2. **Memory Errors**: Allocation failures
3. **Parse Errors**: Malformed CSV content
4. **System Errors**: Platform-specific issues

### Error Reporting

- Clear, user-friendly error messages
- Appropriate exit codes
- Resource cleanup on all error paths

## Cross-Platform Support

### Supported Platforms

| Platform | Architecture | Status |
|----------|-------------|---------|
| Linux | x86_64, ARM64 | ✅ Full support |
| macOS | Intel, Apple Silicon | ✅ Full support |
| Windows | x86_64, i386, ARM64 | ✅ Full support |

### Platform Abstraction

- Compile-time platform detection
- Conditional compilation for platform-specific code
- Unified API across all platforms

## Build System

### Makefile Architecture

- Cross-platform build targets
- Automatic platform detection
- Fallback compilation strategies
- Comprehensive test integration

### Build Scripts

- `build.sh` - Unix/Linux/macOS comprehensive build
- `build.bat` - Windows-specific build
- CI/CD integration

## Testing Architecture

### Test Categories

1. **Unit Tests**: Individual function testing
2. **Integration Tests**: End-to-end workflow
3. **Platform Tests**: Cross-platform compatibility
4. **Performance Tests**: Large file handling
5. **Memory Tests**: Leak detection

### Test Data

- Curated CSV files covering edge cases
- Automated test execution
- Cross-platform test validation

## Performance Considerations

### Optimization Strategies

1. **Memory Efficiency**:
   - Dynamic allocation prevents waste
   - Capacity doubling reduces reallocations
   - String interning not implemented (simplicity over optimization)

2. **I/O Efficiency**:
   - Line-by-line reading for memory efficiency
   - Buffered I/O through standard library

3. **CPU Efficiency**:
   - Minimal string copying
   - Direct JSON output (no intermediate representation)
   - Platform-specific compiler optimizations

### Scalability

- No hard limits on file size
- Memory usage grows linearly with data size
- Suitable for both small and large CSV files

## Security Considerations

### Input Validation

- File path validation
- CSV content validation
- Memory bounds checking

### Memory Safety

- No buffer overflows (dynamic allocation)
- Proper input sanitization
- Safe string handling

## Future Architecture Considerations

### Extensibility Points

1. **Output Formats**: Easy to add new output formats
2. **Input Formats**: Modular parser design
3. **Platforms**: Well-defined platform abstraction
4. **Features**: Modular design supports feature addition

### Potential Improvements

1. **Streaming**: For extremely large files
2. **Configuration**: External configuration files
3. **Plugins**: Dynamic module loading
4. **Optimization**: Memory pooling, SIMD operations