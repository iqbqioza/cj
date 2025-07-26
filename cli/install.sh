#!/usr/bin/env bash
# cj installer script
# Based on the Bun installer pattern but adapted for cj

set -euo pipefail

# Configuration
GITHUB_REPO="iqbqioza/cj"
INSTALL_DIR="${CJ_INSTALL:-$HOME/.cj}"
BIN_DIR="$INSTALL_DIR/bin"
BINARY_NAME="cj"

# Helper functions
error() {
    printf '\033[0;31merror\033[0m: %s\n' "$1" >&2
    exit 1
}

info() {
    printf '\033[0;34minfo\033[0m: %s\n' "$1" >&2
}

success() {
    printf '\033[0;32msuccess\033[0m: %s\n' "$1" >&2
}

warning() {
    printf '\033[1;33mwarning\033[0m: %s\n' "$1" >&2
}

# Detect platform
detect_platform() {
    local os
    local arch
    local platform

    # Detect OS
    case "$(uname -s)" in
        Darwin)
            os="darwin"
            ;;
        Linux)
            os="linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            os="windows"
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac

    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64)
            arch="amd64"
            ;;
        arm64|aarch64)
            arch="arm64"
            ;;
        i386|i686)
            arch="i386"
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            ;;
    esac

    # Special case for macOS Rosetta 2
    if [[ "$os" == "darwin" && "$arch" == "amd64" ]]; then
        if [[ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" == "1" ]]; then
            warning "Running on Apple Silicon under Rosetta 2 emulation"
            warning "Consider using native arm64 build for better performance"
        fi
    fi

    platform="${os}-${arch}"
    echo "$platform"
}

# Get latest release version
get_latest_version() {
    local version
    version=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    
    if [[ -z "$version" ]]; then
        error "Failed to fetch latest version"
    fi
    
    echo "$version"
}

# Download binary
download_binary() {
    local version="$1"
    local platform="$2"
    local binary_name="cj-${platform}"
    
    # Add .exe extension for Windows
    if [[ "$platform" == windows-* ]]; then
        binary_name="${binary_name}.exe"
    fi
    
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v${version}/${binary_name}"
    local temp_file
    temp_file="$(mktemp)"
    
    info "Downloading cj v${version} for ${platform}..."
    info "From: $download_url"
    
    if ! curl -fsSL "$download_url" -o "$temp_file" 2>&1; then
        rm -f "$temp_file"
        error "Failed to download cj binary from $download_url"
    fi
    
    echo "$temp_file"
}

# Install binary
install_binary() {
    local binary_path="$1"
    local target_path="$BIN_DIR/$BINARY_NAME"
    
    # Create directory
    mkdir -p "$BIN_DIR"
    
    # Copy binary
    cp "$binary_path" "$target_path"
    chmod +x "$target_path"
    
    success "Installed cj to $target_path"
}

# Configure shell
configure_shell() {
    local shell_name
    shell_name="$(basename "$SHELL")"
    local config_file
    local export_string="export PATH=\"$BIN_DIR:\$PATH\""
    
    case "$shell_name" in
        bash)
            config_file="$HOME/.bashrc"
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            export_string="set -gx PATH \"$BIN_DIR\" \$PATH"
            ;;
        *)
            warning "Unknown shell: $shell_name"
            warning "Please manually add $BIN_DIR to your PATH"
            return
            ;;
    esac
    
    # Check if PATH is already configured
    if [[ -f "$config_file" ]] && grep -q "$BIN_DIR" "$config_file"; then
        info "PATH already configured in $config_file"
        return
    fi
    
    # Ask user before modifying shell config
    printf '\n\033[1mWould you like to add cj to your PATH automatically?\033[0m\n' >&2
    printf 'This will add the following line to %s:\n' "$config_file" >&2
    printf '  %s\n' "$export_string" >&2
    printf 'Proceed? (y/N) ' >&2
    
    # Read from original stdin
    local response
    if [[ -t 0 ]]; then
        read -r response
    else
        # If not running interactively (e.g., piped), default to no
        response="n"
    fi
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        {
            echo ""
            echo "# Added by cj installer"
            echo "$export_string"
        } >> "$config_file"
        success "Added cj to PATH in $config_file"
        printf '\n\033[1mTo start using cj, run:\033[0m\n' >&2
        printf '  source %s\n' "$config_file" >&2
    else
        printf '\n\033[1mTo manually add cj to your PATH, add this to your shell config:\033[0m\n' >&2
        printf '  %s\n' "$export_string" >&2
    fi
}

# Verify installation
verify_installation() {
    local test_path="$BIN_DIR/$BINARY_NAME"
    
    if [[ ! -f "$test_path" ]]; then
        error "Binary not found at $test_path"
    fi
    
    if [[ ! -x "$test_path" ]]; then
        error "Binary is not executable"
    fi
    
    # Try to run version command
    if "$test_path" version &>/dev/null; then
        local version
        version=$("$test_path" version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        success "cj v${version} installed successfully!"
    else
        warning "Binary installed but version check failed"
    fi
}

# Main installation flow
main() {
    printf '\033[1mcj installer\033[0m\n' >&2
    printf 'Installing cj - CSV to JSON converter\n\n' >&2
    
    # Parse arguments
    local version=""
    local skip_path_setup=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version)
                version="$2"
                shift 2
                ;;
            --skip-path-setup)
                skip_path_setup=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]" >&2
                echo "" >&2
                echo "Options:" >&2
                echo "  --version VERSION    Install specific version (default: latest)" >&2
                echo "  --skip-path-setup    Skip PATH configuration" >&2
                echo "  --help               Show this help message" >&2
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done
    
    # Check dependencies
    if ! command -v curl &> /dev/null; then
        error "curl is required but not installed"
    fi
    
    # Detect platform
    local platform
    platform=$(detect_platform)
    info "Detected platform: $platform"
    
    # Get version
    if [[ -z "$version" ]]; then
        version=$(get_latest_version)
        info "Latest version: v$version"
    else
        info "Installing specified version: v$version"
    fi
    
    # Download binary
    local temp_binary
    temp_binary=$(download_binary "$version" "$platform")
    
    # Install binary
    install_binary "$temp_binary"
    
    # Cleanup
    rm -f "$temp_binary"
    
    # Configure shell PATH
    if [[ "$skip_path_setup" != true ]]; then
        configure_shell
    fi
    
    # Verify installation
    verify_installation
    
    printf '\n\033[1mNext steps:\033[0m\n' >&2
    printf '  • Run '\''cj --help'\'' to see available commands\n' >&2
    printf '  • Visit https://github.com/%s for documentation\n' "$GITHUB_REPO" >&2
    printf '  • Report issues at https://github.com/%s/issues\n' "$GITHUB_REPO" >&2
}

# Run main function
main "$@"