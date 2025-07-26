# cj Installer Scripts

This directory contains installation scripts for the cj CSV to JSON converter.

## Quick Install

### macOS and Linux

```bash
curl -fsSL https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.ps1 | iex
```

## Manual Installation

### macOS and Linux

1. Download the script:
   ```bash
   curl -O https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.sh
   chmod +x install.sh
   ```

2. Run with options:
   ```bash
   # Install latest version
   ./install.sh
   
   # Install specific version
   ./install.sh --version 0.1.0
   
   # Skip PATH setup
   ./install.sh --skip-path-setup
   ```

### Windows

1. Download the script:
   ```powershell
   Invoke-WebRequest -Uri https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.ps1 -OutFile install.ps1
   ```

2. Run with options:
   ```powershell
   # Install latest version
   .\install.ps1
   
   # Install specific version
   .\install.ps1 -Version 0.1.0
   
   # Skip PATH setup
   .\install.ps1 -SkipPathSetup
   ```

## Installation Details

### Default Installation Location

- **macOS/Linux**: `~/.cj/bin/cj`
- **Windows**: `%USERPROFILE%\.cj\bin\cj.exe`

### Custom Installation Directory

Set the `CJ_INSTALL` environment variable before running the installer:

```bash
# macOS/Linux
export CJ_INSTALL=/usr/local/cj
curl -fsSL https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.sh | bash

# Windows
$env:CJ_INSTALL = "C:\Program Files\cj"
irm https://raw.githubusercontent.com/iqbqioza/cj/main/cli/install.ps1 | iex
```

### PATH Configuration

The installer will offer to automatically add cj to your PATH by modifying:
- **bash**: `~/.bashrc`
- **zsh**: `~/.zshrc`
- **fish**: `~/.config/fish/config.fish`
- **Windows**: User environment variable

## Supported Platforms

The installer automatically detects and downloads the appropriate binary for:

### Operating Systems
- macOS (Darwin)
- Linux
- Windows

### Architectures
- x86_64 / amd64
- arm64 / aarch64
- i386 (Windows only)

## Uninstallation

To uninstall cj:

1. Remove the installation directory:
   ```bash
   # macOS/Linux
   rm -rf ~/.cj
   
   # Windows
   Remove-Item -Recurse -Force "$env:USERPROFILE\.cj"
   ```

2. Remove PATH entry from your shell configuration file

## Troubleshooting

### Permission Denied

If you get a permission error on macOS/Linux:
```bash
chmod +x ~/.cj/bin/cj
```

### Command Not Found

If `cj` is not found after installation:
1. Restart your terminal, or
2. Source your shell configuration:
   ```bash
   source ~/.bashrc  # for bash
   source ~/.zshrc   # for zsh
   ```

### Windows Security Warning

Windows may show a security warning when downloading. To bypass:
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

## Development

To test the installer locally:

```bash
# macOS/Linux
./install.sh --version 0.1.0

# Windows
.\install.ps1 -Version 0.1.0
```

## License

These installation scripts are part of the cj project and are licensed under the MIT License.