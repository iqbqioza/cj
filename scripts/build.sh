#!/bin/bash

# Cross-platform build script for cj CSV to JSON converter

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERSION="0.1.0"
BUILD_DIR="build"
DIST_DIR="dist"
TARGETS=("linux-amd64" "linux-arm64" "darwin-amd64" "darwin-arm64" "windows-amd64" "windows-i386" "windows-arm64")

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking build dependencies..."
    
    # Check for make
    if ! command -v make &> /dev/null; then
        log_error "make is required but not installed"
        exit 1
    fi
    
    # Check for compilers
    COMPILERS_FOUND=0
    
    if command -v gcc &> /dev/null; then
        log_success "gcc found"
        COMPILERS_FOUND=$((COMPILERS_FOUND + 1))
    fi
    
    if command -v clang &> /dev/null; then
        log_success "clang found"
        COMPILERS_FOUND=$((COMPILERS_FOUND + 1))
    fi
    
    if command -v aarch64-linux-gnu-gcc &> /dev/null; then
        log_success "aarch64-linux-gnu-gcc found (ARM64 Linux cross-compiler)"
    else
        log_warning "aarch64-linux-gnu-gcc not found (ARM64 Linux builds may fail)"
    fi
    
    if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
        log_success "x86_64-w64-mingw32-gcc found (Windows x64 cross-compiler)"
    else
        log_warning "x86_64-w64-mingw32-gcc not found (Windows x64 builds may fail)"
    fi
    
    if command -v i686-w64-mingw32-gcc &> /dev/null; then
        log_success "i686-w64-mingw32-gcc found (Windows i386 cross-compiler)"
    else
        log_warning "i686-w64-mingw32-gcc not found (Windows i386 builds may fail)"
    fi
    
    if command -v aarch64-w64-mingw32-gcc &> /dev/null; then
        log_success "aarch64-w64-mingw32-gcc found (Windows ARM64 cross-compiler)"
    else
        log_warning "aarch64-w64-mingw32-gcc not found (Windows ARM64 builds may fail)"
    fi
    
    if [ $COMPILERS_FOUND -eq 0 ]; then
        log_error "No C compilers found (gcc or clang required)"
        exit 1
    fi
    
    log_success "Dependencies check completed"
}

build_target() {
    local target=$1
    log_info "Building for $target..."
    
    if make "build-$target" 2>/dev/null; then
        log_success "Successfully built $target"
        return 0
    else
        log_warning "Failed to build $target (cross-compiler may not be available)"
        return 1
    fi
}

build_all() {
    log_info "Starting cross-platform build process..."
    
    # Clean previous builds
    log_info "Cleaning previous builds..."
    make clean-all 2>/dev/null || true
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    local success_count=0
    local total_count=${#TARGETS[@]}
    
    # Build for each target
    for target in "${TARGETS[@]}"; do
        if build_target "$target"; then
            ((success_count++))
        fi
    done
    
    log_info "Build summary: $success_count/$total_count targets built successfully"
    
    if [ $success_count -eq 0 ]; then
        log_error "No targets were built successfully"
        exit 1
    fi
}

create_checksums() {
    log_info "Creating checksums..."
    
    if [ -d "$BUILD_DIR" ]; then
        cd "$BUILD_DIR"
        for binary in cj-*; do
            if [ -f "$binary" ]; then
                sha256sum "$binary" > "$binary.sha256"
                log_success "Created checksum for $binary"
            fi
        done
        cd ..
    fi
}

create_packages() {
    log_info "Creating distribution packages..."
    
    if make dist 2>/dev/null; then
        log_success "Distribution packages created"
    else
        log_warning "Failed to create distribution packages"
    fi
    
    # Create checksums for packages
    if [ -d "$DIST_DIR" ]; then
        cd "$DIST_DIR"
        for package in *.tar.gz; do
            if [ -f "$package" ]; then
                sha256sum "$package" > "$package.sha256"
                log_success "Created checksum for $package"
            fi
        done
        cd ..
    fi
}

show_results() {
    log_info "Build results:"
    
    if [ -d "$BUILD_DIR" ]; then
        echo ""
        echo "Binaries in $BUILD_DIR/:"
        ls -la "$BUILD_DIR/" | grep -E "^-.*cj-" || log_warning "No binaries found"
    fi
    
    if [ -d "$DIST_DIR" ]; then
        echo ""
        echo "Packages in $DIST_DIR/:"
        ls -la "$DIST_DIR/" | grep -E "\.(tar\.gz|sha256)$" || log_warning "No packages found"
    fi
}

run_tests() {
    log_info "Running tests on native build..."
    
    if make test 2>/dev/null; then
        log_success "All tests passed"
    else
        log_error "Tests failed"
        exit 1
    fi
}

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -t, --test     Run tests before building"
    echo "  -c, --check    Only check dependencies"
    echo "  --no-dist      Skip creating distribution packages"
    echo "  --target TARGET Build only specific target (linux-amd64, linux-arm64, darwin-amd64, darwin-arm64, windows-amd64, windows-i386, windows-arm64)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build all targets"
    echo "  $0 --test             # Run tests then build all targets"
    echo "  $0 --target linux-amd64  # Build only Linux AMD64"
    echo "  $0 --check            # Check dependencies only"
}

# Main script
main() {
    local run_tests=false
    local check_only=false
    local create_dist=true
    local specific_target=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            -t|--test)
                run_tests=true
                shift
                ;;
            -c|--check)
                check_only=true
                shift
                ;;
            --no-dist)
                create_dist=false
                shift
                ;;
            --target)
                specific_target="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    log_info "cj Cross-Platform Build Script v$VERSION"
    echo ""
    
    # Check dependencies
    check_dependencies
    echo ""
    
    if [ "$check_only" = true ]; then
        log_success "Dependency check completed successfully"
        exit 0
    fi
    
    # Run tests if requested
    if [ "$run_tests" = true ]; then
        run_tests
        echo ""
    fi
    
    # Build specific target or all targets
    if [ -n "$specific_target" ]; then
        log_info "Building specific target: $specific_target"
        if build_target "$specific_target"; then
            log_success "Build completed successfully"
        else
            log_error "Build failed"
            exit 1
        fi
    else
        build_all
    fi
    
    echo ""
    
    # Create checksums
    create_checksums
    echo ""
    
    # Create distribution packages
    if [ "$create_dist" = true ]; then
        create_packages
        echo ""
    fi
    
    # Show results
    show_results
    echo ""
    
    log_success "Build process completed!"
}

# Run main function with all arguments
main "$@"