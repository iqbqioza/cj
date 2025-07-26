# API Documentation

This document describes the internal API of the cj CSV to JSON converter. While cj is primarily a command-line tool, understanding its internal API is useful for contributors and those who might want to embed the functionality.

## Table of Contents

- [Data Structures](#data-structures)
- [CSV Parser API](#csv-parser-api)
- [JSON Output API](#json-output-api)
- [Utility API](#utility-api)
- [Platform API](#platform-api)
- [Error Handling](#error-handling)
- [Memory Management](#memory-management)

## Data Structures

### CSVData

The main data structure that holds parsed CSV data.

```c
typedef struct {
    char** headers;          // Array of header strings
    char*** data;           // 2D array of data values
    int num_headers;        // Number of columns
    int num_rows;          // Number of data rows
    int headers_capacity;   // Allocated capacity for headers
    int rows_capacity;     // Allocated capacity for rows
    int* field_capacities; // Per-field capacity tracking
} CSVData;
```

**Fields:**
- `headers`: Dynamically allocated array of column header strings
- `data`: 2D array where `data[row][col]` gives the value at row/column
- `num_headers`: Current number of columns
- `num_rows`: Current number of data rows (excluding header)
- `headers_capacity`: Allocated size for headers array
- `rows_capacity`: Allocated size for rows array
- `field_capacities`: Array tracking allocated capacity for each field

## CSV Parser API

### Core Functions

#### `CSVData* read_csv(const char* filename)`

Reads and parses a CSV file into a CSVData structure.

**Parameters:**
- `filename`: Path to the CSV file to read

**Returns:**
- Pointer to allocated CSVData structure on success
- `NULL` on error (file not found, memory allocation failure, etc.)

**Example:**
```c
CSVData* csv = read_csv("data.csv");
if (!csv) {
    fprintf(stderr, "Failed to read CSV file\n");
    return 1;
}
// Use csv...
free_csv(csv);
```

#### `void free_csv(CSVData* csv)`

Frees all memory associated with a CSVData structure.

**Parameters:**
- `csv`: Pointer to CSVData to free (can be NULL)

**Example:**
```c
CSVData* csv = read_csv("data.csv");
// Use csv...
free_csv(csv);  // Always call this to prevent memory leaks
```

### Helper Functions

#### `char* read_csv_line(FILE* file)`

Reads a single line from a CSV file, handling quoted multiline fields.

**Parameters:**
- `file`: Open file pointer

**Returns:**
- Pointer to allocated line string
- `NULL` on EOF or error

**Note:** This function handles RFC 4180 compliant CSV parsing including:
- Quoted fields spanning multiple lines
- Escaped quotes within fields
- Various newline formats (Unix, Windows, mixed)

#### `char** parse_csv_line(char* line, int* field_count)`

Parses a CSV line into individual fields.

**Parameters:**
- `line`: Null-terminated CSV line string
- `field_count`: Pointer to int that will receive the number of fields

**Returns:**
- Array of field strings
- `NULL` on error

**Example:**
```c
int field_count;
char** fields = parse_csv_line("a,b,c", &field_count);
// field_count will be 3
// fields[0] = "a", fields[1] = "b", fields[2] = "c"
// Remember to free fields and each field string
```

## JSON Output API

### Core Functions

#### `void print_json(CSVData* csv, int styled)`

Outputs CSV data as JSON to stdout.

**Parameters:**
- `csv`: Pointer to CSVData structure
- `styled`: 0 for compact output, non-zero for formatted output

**Output Format:**
- Compact: Single line JSON array
- Styled: Pretty-printed with 2-space indentation

**Example:**
```c
CSVData* csv = read_csv("data.csv");
print_json(csv, 0);  // Compact output
print_json(csv, 1);  // Styled output
free_csv(csv);
```

#### `void print_json_value(const char* value)`

Outputs a single value in JSON format with proper escaping.

**Parameters:**
- `value`: String value to output

**Features:**
- Automatic numeric type detection
- Proper JSON string escaping
- Null value handling

**Example:**
```c
print_json_value("123");      // Outputs: 123 (number)
print_json_value("hello");    // Outputs: "hello" (string)
print_json_value("3.14");     // Outputs: 3.14 (number)
print_json_value("");         // Outputs: "" (empty string)
```

## Utility API

### Information Functions

#### `void print_version(void)`

Prints version and platform information to stdout.

**Output Format:**
```
cj version 1.0.0
Built for: Platform: darwin, Architecture: arm64, Target: darwin-arm64
```

#### `void print_usage(void)`

Prints usage information to stdout.

**Output:**
```
Usage:
  cj [filename]           Convert CSV to JSON
  cj version              Show version
  cj --styled|-s [file]   Convert CSV to formatted JSON
  cj                      Show this help
```

### Validation Functions

#### `int is_numeric(const char* str)`

Determines if a string represents a numeric value.

**Parameters:**
- `str`: String to test

**Returns:**
- `1` if string is numeric (integer or float)
- `0` if string is not numeric

**Supported Formats:**
- Integers: `123`, `-456`
- Floats: `3.14`, `-2.718`
- Not numeric: `abc`, `123abc`, `12.34.56`

**Example:**
```c
if (is_numeric("123")) {
    printf("Number: %s\n", "123");
} else {
    printf("String: \"%s\"\n", "123");
}
```

## Platform API

### Information Functions

#### `const char* get_platform_info(void)`

Returns a string describing the current platform.

**Returns:**
- Platform string in format "platform-architecture"
- Examples: "linux-amd64", "darwin-arm64", "windows-amd64"

**Example:**
```c
const char* platform = get_platform_info();
printf("Running on: %s\n", platform);
```

### Platform Detection Macros

The platform.h header provides compile-time platform detection:

```c
#ifdef PLATFORM_LINUX
    // Linux-specific code
#endif

#ifdef PLATFORM_DARWIN
    // macOS-specific code
#endif

#ifdef PLATFORM_WINDOWS
    // Windows-specific code
#endif

#ifdef ARCH_ARM64
    // ARM64-specific optimizations
#endif
```

## Error Handling

### Error Codes

The main function returns standard exit codes:

- `0`: Success
- `1`: General error (file not found, invalid arguments, etc.)
- `2`: Memory allocation failure
- `3`: File I/O error

### Error Reporting

Functions use these patterns for error reporting:

1. **Return NULL**: For functions that allocate and return pointers
2. **Return negative**: For functions that return counts or status
3. **Set errno**: For system-level errors
4. **Print to stderr**: For user-facing error messages

**Example Error Handling:**
```c
CSVData* csv = read_csv("nonexistent.csv");
if (!csv) {
    // Error message already printed to stderr
    return 1;
}

// Success path
print_json(csv, 0);
free_csv(csv);
return 0;
```

## Memory Management

### Allocation Strategy

The library uses dynamic memory allocation throughout:

1. **String storage**: All strings are dynamically allocated
2. **Array growth**: Arrays double in size when capacity is exceeded
3. **Cleanup**: All allocations must be explicitly freed

### Memory Safety Rules

1. **Check allocations**: Always check if malloc/realloc returns NULL
2. **Free in reverse order**: Free child allocations before parent
3. **Null-safe free**: Free functions accept NULL pointers safely
4. **No double-free**: Set pointers to NULL after freeing

### Memory Layout Example

For CSV data "a,b\n1,2":

```
CSVData
├── headers[0] → "a"
├── headers[1] → "b"
├── data[0][0] → "1"
├── data[0][1] → "2"
├── num_headers = 2
├── num_rows = 1
├── headers_capacity = 16
├── rows_capacity = 16
└── field_capacities[0] = 16
```

### Best Practices

1. **Always call free_csv()**: This frees all associated memory
2. **Check for NULL**: Before dereferencing any returned pointers
3. **Use valgrind**: For memory leak detection during development
4. **Initialize pointers**: Set to NULL to enable safe cleanup

**Example Safe Usage:**
```c
CSVData* csv = NULL;

csv = read_csv(filename);
if (!csv) {
    goto cleanup;
}

print_json(csv, styled);

cleanup:
    free_csv(csv);  // Safe even if csv is NULL
    return csv ? 0 : 1;
```

## Integration Examples

### Basic Integration

```c
#include "cj.h"

int convert_csv_to_json(const char* filename, int styled) {
    CSVData* csv = read_csv(filename);
    if (!csv) {
        return 1;
    }
    
    print_json(csv, styled);
    free_csv(csv);
    return 0;
}
```

### Custom Output

```c
#include "cj.h"

void output_as_xml(CSVData* csv) {
    printf("<data>\n");
    for (int row = 0; row < csv->num_rows; row++) {
        printf("  <record>\n");
        for (int col = 0; col < csv->num_headers; col++) {
            printf("    <%s>%s</%s>\n", 
                   csv->headers[col], 
                   csv->data[row][col], 
                   csv->headers[col]);
        }
        printf("  </record>\n");
    }
    printf("</data>\n");
}
```

This API documentation provides the foundation for understanding and extending the cj CSV to JSON converter.