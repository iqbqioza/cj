#!/bin/bash

# Release script for cj
# This script helps create and push release tags that trigger the release workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_usage() {
    echo "Usage: $0 <version> [options]"
    echo ""
    echo "Arguments:"
    echo "  version    Version number (e.g., 1.0.0, 1.1.0-beta.1)"
    echo ""
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -n, --dry-run   Show what would be done without actually doing it"
    echo "  -f, --force     Force tag creation even if it exists"
    echo "  --no-push       Create tag locally but don't push to remote"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.1                    # Create and push v1.0.1 tag"
    echo "  $0 1.1.0-beta.1 --dry-run   # Preview what would happen"
    echo "  $0 1.0.2 --no-push          # Create tag locally only"
}

validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\.-]+)?$ ]]; then
        log_error "Invalid version format: $version"
        log_info "Expected format: MAJOR.MINOR.PATCH[-PRERELEASE]"
        log_info "Examples: 1.0.0, 1.2.3, 2.0.0-beta.1, 1.0.0-rc.1"
        return 1
    fi
    return 0
}

check_git_status() {
    if ! git diff-index --quiet HEAD --; then
        log_error "Working directory is not clean. Please commit or stash changes."
        git status --porcelain
        return 1
    fi
    return 0
}

check_version_file() {
    local version=$1
    local version_file="VERSION"
    
    if [ -f "$version_file" ]; then
        local current_version=$(cat "$version_file")
        if [ "$current_version" != "$version" ]; then
            log_warning "VERSION file contains '$current_version' but you're releasing '$version'"
            read -p "Do you want to update the VERSION file? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "$version" > "$version_file"
                git add "$version_file"
                git commit -m "chore: bump version to $version"
                log_success "Updated VERSION file and committed"
            fi
        fi
    else
        log_warning "VERSION file not found"
    fi
}

check_changelog() {
    local version=$1
    if [ -f "CHANGELOG.md" ]; then
        if ! grep -q "$version" CHANGELOG.md; then
            log_warning "CHANGELOG.md doesn't mention version $version"
            log_info "Consider updating CHANGELOG.md before releasing"
        else
            log_success "Found version $version in CHANGELOG.md"
        fi
    fi
}

create_tag() {
    local version=$1
    local tag="v$version"
    local dry_run=$2
    local force=$3
    
    # Check if tag already exists
    if git tag -l | grep -q "^$tag$"; then
        if [ "$force" = true ]; then
            log_warning "Tag $tag already exists, but --force specified"
            if [ "$dry_run" = false ]; then
                git tag -d "$tag"
                log_info "Deleted existing local tag $tag"
            fi
        else
            log_error "Tag $tag already exists. Use --force to overwrite."
            return 1
        fi
    fi
    
    # Create annotated tag with release notes
    local tag_message="Release $version

See CHANGELOG.md for detailed changes.

This release includes:
- Cross-platform binaries for Linux, macOS, and Windows
- Source archives (tar.gz and zip)
- SHA256 checksums for all assets

Download: https://github.com/iqbqioza/cj/releases/tag/$tag"
    
    if [ "$dry_run" = true ]; then
        log_info "Would create tag: $tag"
        echo "Tag message:"
        echo "$tag_message"
    else
        git tag -a "$tag" -m "$tag_message"
        log_success "Created tag $tag"
    fi
}

push_tag() {
    local version=$1
    local tag="v$version"
    local dry_run=$2
    local no_push=$3
    
    if [ "$no_push" = true ]; then
        log_info "Skipping push (--no-push specified)"
        return 0
    fi
    
    if [ "$dry_run" = true ]; then
        log_info "Would push tag: $tag"
    else
        git push origin "$tag"
        log_success "Pushed tag $tag to origin"
        log_info "Release workflow should start automatically"
        log_info "Monitor at: https://github.com/iqbqioza/cj/actions"
    fi
}

main() {
    local version=""
    local dry_run=false
    local force=false
    local no_push=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --no-push)
                no_push=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
            *)
                if [ -z "$version" ]; then
                    version="$1"
                else
                    log_error "Too many arguments"
                    print_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if version is provided
    if [ -z "$version" ]; then
        log_error "Version number is required"
        print_usage
        exit 1
    fi
    
    log_info "Creating release for version: $version"
    if [ "$dry_run" = true ]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi
    
    # Validate version format
    if ! validate_version "$version"; then
        exit 1
    fi
    
    # Check git status
    if ! check_git_status; then
        exit 1
    fi
    
    # Check if we're on main branch
    local current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        log_warning "You're on branch '$current_branch', not 'main'"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted"
            exit 0
        fi
    fi
    
    # Run checks
    check_version_file "$version"
    check_changelog "$version"
    
    # Create and push tag
    if create_tag "$version" "$dry_run" "$force"; then
        push_tag "$version" "$dry_run" "$no_push"
        
        if [ "$dry_run" = false ] && [ "$no_push" = false ]; then
            echo ""
            log_success "Release process initiated for version $version"
            log_info "The GitHub Actions workflow will:"
            log_info "  1. Build binaries for all supported platforms"
            log_info "  2. Create source archives"
            log_info "  3. Generate checksums"
            log_info "  4. Create a GitHub release with all assets"
            echo ""
            log_info "Monitor progress at: https://github.com/iqbqioza/cj/actions"
            log_info "Release will be available at: https://github.com/iqbqioza/cj/releases/tag/v$version"
        fi
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"