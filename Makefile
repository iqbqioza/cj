# Cross-platform Makefile for cj CSV to JSON converter

# Default compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2

# Target executable name
TARGET = cj
SRC_DIR = src
SOURCES = $(SRC_DIR)/main.c $(SRC_DIR)/utils.c $(SRC_DIR)/csv_parser.c $(SRC_DIR)/json_output.c $(SRC_DIR)/platform.c
OBJECTS = $(SOURCES:.c=.o)
TEST_TARGET = test/test_cj
TEST_SRC = test/test_cj.c

# Platform detection
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Platform-specific settings
ifeq ($(UNAME_S),Linux)
    PLATFORM = linux
    ifeq ($(UNAME_M),x86_64)
        ARCH = amd64
        CFLAGS += -march=x86-64
    else ifeq ($(UNAME_M),aarch64)
        ARCH = arm64
        CFLAGS += -march=armv8-a
    else ifeq ($(UNAME_M),arm64)
        ARCH = arm64
        CFLAGS += -march=armv8-a
    else
        ARCH = $(UNAME_M)
    endif
else ifeq ($(UNAME_S),Darwin)
    PLATFORM = darwin
    ifeq ($(UNAME_M),arm64)
        ARCH = arm64
        CFLAGS += -arch arm64 -target arm64-apple-macos11
        CC = clang
    else ifeq ($(UNAME_M),x86_64)
        ARCH = amd64
        CFLAGS += -arch x86_64 -target x86_64-apple-macos10.12
        CC = clang
    else
        ARCH = $(UNAME_M)
        CC = clang
    endif
else ifeq ($(findstring CYGWIN,$(UNAME_S)),CYGWIN)
    PLATFORM = windows
    ARCH = amd64
    CFLAGS += -D_GNU_SOURCE
    TARGET = cj.exe
else ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
    PLATFORM = windows
    ARCH = amd64
    CFLAGS += -D_GNU_SOURCE
    TARGET = cj.exe
else
    PLATFORM = unknown
    ARCH = $(UNAME_M)
endif

# Build directory for cross-compilation
BUILD_DIR = build
DIST_DIR = dist

# Default target
all: $(TARGET)

# Show platform information
info:
	@echo "Platform: $(PLATFORM)"
	@echo "Architecture: $(ARCH)"
	@echo "Compiler: $(CC)"
	@echo "Flags: $(CFLAGS)"

# Standard build
$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)

# Object file compilation
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Cross-compilation targets
build-linux-amd64:
	@echo "Building for Linux AMD64..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -march=x86-64" $(MAKE) $(TARGET)
	@mv $(TARGET) $(BUILD_DIR)/$(TARGET)-linux-amd64
	@echo "Built: $(BUILD_DIR)/$(TARGET)-linux-amd64"

build-linux-arm64:
	@echo "Building for Linux ARM64..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=aarch64-linux-gnu-gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -march=armv8-a" $(MAKE) $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2" $(MAKE) $(TARGET)
	@mv $(TARGET) $(BUILD_DIR)/$(TARGET)-linux-arm64
	@echo "Built: $(BUILD_DIR)/$(TARGET)-linux-arm64"

build-darwin-amd64:
	@echo "Building for macOS Intel..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=clang CFLAGS="-Wall -Wextra -std=c99 -O2 -arch x86_64 -target x86_64-apple-macos10.12" $(MAKE) $(TARGET) 2>/dev/null || \
	CC=clang CFLAGS="-Wall -Wextra -std=c99 -O2 -arch x86_64" $(MAKE) $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2" $(MAKE) $(TARGET)
	@mv $(TARGET) $(BUILD_DIR)/$(TARGET)-darwin-amd64
	@echo "Built: $(BUILD_DIR)/$(TARGET)-darwin-amd64"

build-darwin-arm64:
	@echo "Building for macOS Apple Silicon..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=clang CFLAGS="-Wall -Wextra -std=c99 -O2 -arch arm64 -target arm64-apple-macos11" $(MAKE) $(TARGET) 2>/dev/null || \
	CC=clang CFLAGS="-Wall -Wextra -std=c99 -O2 -arch arm64" $(MAKE) $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2" $(MAKE) $(TARGET)
	@mv $(TARGET) $(BUILD_DIR)/$(TARGET)-darwin-arm64
	@echo "Built: $(BUILD_DIR)/$(TARGET)-darwin-arm64"

build-windows-amd64:
	@echo "Building for Windows AMD64..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=x86_64-w64-mingw32-gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -static" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -D_WIN32" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	echo "Windows cross-compiler not available, skipping..."
	@if [ -f cj.exe ]; then mv cj.exe $(BUILD_DIR)/cj-windows-amd64.exe; echo "Built: $(BUILD_DIR)/cj-windows-amd64.exe"; fi

build-windows-i386:
	@echo "Building for Windows i386..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=i686-w64-mingw32-gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -static -m32" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -D_WIN32 -m32" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	echo "Windows i386 cross-compiler not available, skipping..."
	@if [ -f cj.exe ]; then mv cj.exe $(BUILD_DIR)/cj-windows-i386.exe; echo "Built: $(BUILD_DIR)/cj-windows-i386.exe"; fi

build-windows-arm64:
	@echo "Building for Windows ARM64..."
	@mkdir -p $(BUILD_DIR)
	$(MAKE) clean
	CC=aarch64-w64-mingw32-gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -static" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	CC=clang CFLAGS="-Wall -Wextra -std=c99 -O2 -target aarch64-pc-windows-msvc" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	CC=gcc CFLAGS="-Wall -Wextra -std=c99 -O2 -D_WIN32 -D_ARM64_" $(MAKE) TARGET=cj.exe $(TARGET) 2>/dev/null || \
	echo "Windows ARM64 cross-compiler not available, skipping..."
	@if [ -f cj.exe ]; then mv cj.exe $(BUILD_DIR)/cj-windows-arm64.exe; echo "Built: $(BUILD_DIR)/cj-windows-arm64.exe"; fi

# Build all platforms (if possible on current system)
build-all: build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64 build-windows-amd64 build-windows-i386 build-windows-arm64

# Create distribution packages
dist: build-all
	@echo "Creating distribution packages..."
	@mkdir -p $(DIST_DIR)
	@for binary in $(BUILD_DIR)/*; do \
		if [ -f "$$binary" ]; then \
			basename_bin=$$(basename $$binary); \
			echo "Packaging $$basename_bin..."; \
			mkdir -p $(DIST_DIR)/$$basename_bin; \
			cp $$binary $(DIST_DIR)/$$basename_bin/$(TARGET); \
			cp README.md $(DIST_DIR)/$$basename_bin/; \
			cp LICENSE $(DIST_DIR)/$$basename_bin/; \
			cd $(DIST_DIR) && tar -czf $$basename_bin.tar.gz $$basename_bin && rm -rf $$basename_bin; \
			cd ..; \
		fi \
	done
	@echo "Distribution packages created in $(DIST_DIR)/"

# Native build for current platform
native:
	@echo "Building for native platform: $(PLATFORM)-$(ARCH)"
	$(MAKE) $(TARGET)
	@echo "Native build complete: $(TARGET)"

# Test suite
test: $(TARGET) $(TEST_TARGET)
	cd test && ./test_cj

$(TEST_TARGET): $(TEST_SRC)
	$(CC) $(CFLAGS) -o $(TEST_TARGET) $(TEST_SRC)

# Installation
install: $(TARGET)
	@echo "Installing $(TARGET) to /usr/local/bin/"
	@cp $(TARGET) /usr/local/bin/
	@chmod +x /usr/local/bin/$(TARGET)

uninstall:
	@echo "Removing $(TARGET) from /usr/local/bin/"
	@rm -f /usr/local/bin/$(TARGET)

# Cleanup
clean:
	rm -f $(TARGET) $(TEST_TARGET) $(OBJECTS)

clean-all: clean
	rm -rf $(BUILD_DIR) $(DIST_DIR)

# Check if cross-compilation tools are available
check-tools:
	@echo "Checking available compilers..."
	@which gcc >/dev/null 2>&1 && echo "✓ gcc available" || echo "✗ gcc not found"
	@which clang >/dev/null 2>&1 && echo "✓ clang available" || echo "✗ clang not found"
	@which aarch64-linux-gnu-gcc >/dev/null 2>&1 && echo "✓ aarch64-linux-gnu-gcc available" || echo "✗ aarch64-linux-gnu-gcc not found"
	@which x86_64-linux-gnu-gcc >/dev/null 2>&1 && echo "✓ x86_64-linux-gnu-gcc available" || echo "✗ x86_64-linux-gnu-gcc not found"
	@which x86_64-w64-mingw32-gcc >/dev/null 2>&1 && echo "✓ x86_64-w64-mingw32-gcc available" || echo "✗ x86_64-w64-mingw32-gcc not found"
	@which i686-w64-mingw32-gcc >/dev/null 2>&1 && echo "✓ i686-w64-mingw32-gcc available" || echo "✗ i686-w64-mingw32-gcc not found"
	@which aarch64-w64-mingw32-gcc >/dev/null 2>&1 && echo "✓ aarch64-w64-mingw32-gcc available" || echo "✗ aarch64-w64-mingw32-gcc not found"

# Help
help:
	@echo "Available targets:"
	@echo "  all              - Build for current platform"
	@echo "  native           - Build for current platform (explicit)"
	@echo "  info             - Show platform information"
	@echo "  build-linux-amd64    - Cross-compile for Linux x86_64"
	@echo "  build-linux-arm64    - Cross-compile for Linux ARM64"
	@echo "  build-darwin-amd64   - Cross-compile for macOS Intel"
	@echo "  build-darwin-arm64   - Cross-compile for macOS Apple Silicon"
	@echo "  build-windows-amd64  - Cross-compile for Windows x86_64"
	@echo "  build-windows-i386   - Cross-compile for Windows i386"
	@echo "  build-windows-arm64  - Cross-compile for Windows ARM64"
	@echo "  build-all        - Build for all supported platforms"
	@echo "  dist             - Create distribution packages"
	@echo "  test             - Run test suite"
	@echo "  install          - Install to /usr/local/bin"
	@echo "  uninstall        - Remove from /usr/local/bin"
	@echo "  clean            - Remove build artifacts"
	@echo "  clean-all        - Remove all build and dist artifacts"
	@echo "  check-tools      - Check available cross-compilation tools"
	@echo "  help             - Show this help"

.PHONY: all native info build-linux-amd64 build-linux-arm64 build-darwin-amd64 build-darwin-arm64 build-windows-amd64 build-windows-i386 build-windows-arm64 build-all dist test install uninstall clean clean-all check-tools help