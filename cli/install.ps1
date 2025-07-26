# cj installer script for Windows
# PowerShell version

param(
    [string]$Version = "",
    [switch]$SkipPathSetup = $false,
    [switch]$Help = $false
)

# Configuration
$GITHUB_REPO = "iqbqioza/cj"
$INSTALL_DIR = if ($env:CJ_INSTALL) { $env:CJ_INSTALL } else { "$env:USERPROFILE\.cj" }
$BIN_DIR = "$INSTALL_DIR\bin"
$BINARY_NAME = "cj.exe"
$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Error-Custom {
    Write-ColorOutput Red "error: $args"
    exit 1
}

function Write-Info {
    Write-ColorOutput Cyan "info: $args"
}

function Write-Success {
    Write-ColorOutput Green "success: $args"
}

function Write-Warning {
    Write-ColorOutput Yellow "warning: $args"
}

# Show help
if ($Help) {
    Write-Host "cj installer for Windows"
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Version VERSION     Install specific version (default: latest)"
    Write-Host "  -SkipPathSetup       Skip PATH configuration"
    Write-Host "  -Help                Show this help message"
    exit 0
}

Write-Host "cj installer" -ForegroundColor Cyan
Write-Host "Installing cj - CSV to JSON converter`n"

# Detect architecture
function Get-Architecture {
    $arch = $env:PROCESSOR_ARCHITECTURE
    switch ($arch) {
        "AMD64" { return "amd64" }
        "x86" { return "i386" }
        "ARM64" { return "arm64" }
        default { Write-Error-Custom "Unsupported architecture: $arch" }
    }
}

# Get latest version
function Get-LatestVersion {
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$GITHUB_REPO/releases/latest"
        $version = $release.tag_name -replace '^v', ''
        return $version
    }
    catch {
        Write-Error-Custom "Failed to fetch latest version: $_"
    }
}

# Download binary
function Download-Binary {
    param(
        [string]$Version,
        [string]$Architecture
    )
    
    $binaryName = "cj-windows-$Architecture.exe"
    $downloadUrl = "https://github.com/$GITHUB_REPO/releases/download/v$Version/$binaryName"
    $tempFile = [System.IO.Path]::GetTempFileName()
    
    Write-Info "Downloading cj v$Version for windows-$Architecture..."
    Write-Info "From: $downloadUrl"
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile -UseBasicParsing
        return $tempFile
    }
    catch {
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
        Write-Error-Custom "Failed to download cj binary: $_"
    }
}

# Install binary
function Install-Binary {
    param(
        [string]$BinaryPath
    )
    
    # Create directory
    if (!(Test-Path $BIN_DIR)) {
        New-Item -ItemType Directory -Path $BIN_DIR -Force | Out-Null
    }
    
    $targetPath = "$BIN_DIR\$BINARY_NAME"
    
    # Copy binary
    Copy-Item -Path $BinaryPath -Destination $targetPath -Force
    
    Write-Success "Installed cj to $targetPath"
}

# Configure PATH
function Configure-Path {
    if ($SkipPathSetup) {
        return
    }
    
    # Check if already in PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -like "*$BIN_DIR*") {
        Write-Info "PATH already contains $BIN_DIR"
        return
    }
    
    Write-Host "`nWould you like to add cj to your PATH automatically?" -ForegroundColor Yellow
    Write-Host "This will add: $BIN_DIR"
    $response = Read-Host "Proceed? (y/N)"
    
    if ($response -match "^[Yy]$") {
        $newPath = "$BIN_DIR;$currentPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Success "Added cj to PATH"
        Write-Host "`nTo start using cj in new terminals, they will automatically have the updated PATH." -ForegroundColor Green
        Write-Host "For the current terminal, run:" -ForegroundColor Green
        Write-Host "  `$env:Path = `"$BIN_DIR;`$env:Path`""
    }
    else {
        Write-Host "`nTo manually add cj to your PATH:" -ForegroundColor Yellow
        Write-Host "  1. Open System Properties > Environment Variables"
        Write-Host "  2. Edit the 'Path' variable for your user"
        Write-Host "  3. Add: $BIN_DIR"
    }
}

# Verify installation
function Verify-Installation {
    $testPath = "$BIN_DIR\$BINARY_NAME"
    
    if (!(Test-Path $testPath)) {
        Write-Error-Custom "Binary not found at $testPath"
    }
    
    try {
        $output = & $testPath version 2>&1
        if ($output -match '(\d+\.\d+\.\d+)') {
            $installedVersion = $matches[1]
            Write-Success "cj v$installedVersion installed successfully!"
        }
        else {
            Write-Warning "Binary installed but version check failed"
        }
    }
    catch {
        Write-Warning "Binary installed but could not verify: $_"
    }
}

# Main installation
try {
    # Get architecture
    $architecture = Get-Architecture
    Write-Info "Detected architecture: windows-$architecture"
    
    # Get version
    if ([string]::IsNullOrEmpty($Version)) {
        $Version = Get-LatestVersion
        Write-Info "Latest version: v$Version"
    }
    else {
        Write-Info "Installing specified version: v$Version"
    }
    
    # Download binary
    $tempBinary = Download-Binary -Version $Version -Architecture $architecture
    
    # Install binary
    Install-Binary -BinaryPath $tempBinary
    
    # Cleanup
    Remove-Item -Path $tempBinary -ErrorAction SilentlyContinue
    
    # Configure PATH
    Configure-Path
    
    # Verify installation
    Verify-Installation
    
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  • Run 'cj --help' to see available commands"
    Write-Host "  • Visit https://github.com/$GITHUB_REPO for documentation"
    Write-Host "  • Report issues at https://github.com/$GITHUB_REPO/issues"
}
catch {
    Write-Error-Custom $_
}