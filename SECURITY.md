# Security Policy

## Supported Versions

We actively support security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of cj seriously. If you discover a security vulnerability, please follow these steps:

### How to Report

1. **Do not** create a public GitHub issue for security vulnerabilities
2. Send an email to the maintainers with details about the vulnerability
3. Include as much information as possible to help us understand and reproduce the issue

### What to Include

Please include the following information in your security report:

- **Description**: A clear description of the vulnerability
- **Impact**: What could an attacker accomplish with this vulnerability?
- **Reproduction**: Step-by-step instructions to reproduce the issue
- **Platform**: Operating system, architecture, and compiler details
- **Sample Data**: If applicable, provide a minimal CSV file that demonstrates the issue
- **Suggested Fix**: If you have ideas for how to fix the issue

### Response Timeline

- **Initial Response**: We will acknowledge your report within 48 hours
- **Investigation**: We will investigate and validate the report within 1 week
- **Fix Development**: Critical issues will be addressed immediately, others within 2 weeks
- **Release**: Security fixes will be released as soon as possible after validation

### Disclosure Process

1. **Private Disclosure**: Work with us privately to understand and fix the issue
2. **Fix Development**: We develop and test a fix
3. **Coordinated Release**: Release the fix and security advisory simultaneously
4. **Public Disclosure**: After the fix is available, details may be made public

## Security Considerations

### Input Validation

cj processes user-provided CSV files and should be used with trusted input. However, we implement several security measures:

- **Memory Safety**: Dynamic memory allocation with bounds checking
- **Input Sanitization**: Proper validation of CSV content
- **Buffer Overflow Prevention**: No fixed-size buffers for user data
- **Resource Limits**: Protection against excessive memory usage

### Known Security Boundaries

- **File System Access**: cj reads files from the local filesystem
- **Memory Usage**: Large CSV files will consume proportional memory
- **Output Generation**: Generated JSON is written to stdout

### Best Practices for Users

1. **Validate Input**: Ensure CSV files come from trusted sources
2. **Resource Monitoring**: Monitor memory usage with very large files
3. **Output Validation**: Validate generated JSON if used in security-sensitive contexts
4. **File Permissions**: Use appropriate file permissions for CSV input files

## Security Features

### Memory Management
- Dynamic allocation prevents buffer overflows
- Automatic cleanup prevents memory leaks
- Null pointer checking prevents crashes

### Input Processing
- RFC 4180 compliant parsing prevents malformed input issues
- Quote handling prevents injection-style attacks
- Newline normalization handles various input formats safely

### Output Generation
- Proper JSON escaping prevents output corruption
- No code execution in output (pure data conversion)
- Deterministic output for the same input

## Vulnerability Categories

### High Priority
- Memory corruption vulnerabilities
- Arbitrary code execution
- File system traversal attacks
- Denial of service through resource exhaustion

### Medium Priority
- Information disclosure
- Input validation bypasses
- Resource exhaustion (non-critical)

### Low Priority
- Minor memory leaks
- Performance degradation
- Non-security related crashes

## Security Testing

We encourage security testing and provide the following resources:

### Test Data
```csv
# Example CSV files for security testing
test/edge_cases.csv     # Edge cases and boundary conditions
test/large.csv         # Large file for resource testing
test/special.csv       # Special characters and encoding
```

### Testing Tools
```bash
# Memory leak detection
valgrind --leak-check=full ./cj test/basic.csv

# Static analysis
cppcheck --enable=all src/
clang-tidy src/*.c

# Fuzzing (if available)
# American Fuzzy Lop or similar tools can be used
```

### Reporting Test Results
If you find issues during security testing:
1. Follow the vulnerability reporting process above
2. Include testing methodology and tools used
3. Provide reproducible test cases

## Security Updates

Security updates will be:
- Released as patch versions (e.g., 1.0.1, 1.0.2)
- Documented in CHANGELOG.md with security advisory references
- Tagged with appropriate severity levels
- Distributed through standard release channels

## Acknowledgments

We appreciate the security research community's efforts to improve software security. Security researchers who report vulnerabilities will be:

- Credited in the security advisory (unless they prefer to remain anonymous)
- Mentioned in the CHANGELOG.md
- Given advance notice of the fix and release timeline

## Contact Information

For security-related concerns:
- Create a [GitHub issue](https://github.com/iqbqioza/cj/issues) for general security questions (non-vulnerabilities)
- Check existing documentation in the `docs/` directory
- Review this security policy for updates
- Repository: https://github.com/iqbqioza/cj

## Security Resources

- [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)
- [CWE Common Weakness Enumeration](https://cwe.mitre.org/)
- [CVE Common Vulnerabilities and Exposures](https://cve.mitre.org/)

## License

This security policy is part of the cj project and is subject to the same MIT license terms.