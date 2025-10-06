#!/usr/bin/env bash
# Bootstrap script - Download Telegram Bot API specification files
# This script fetches the latest API documentation from core.telegram.org

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TELEGRAM_BASE_URL="https://core.telegram.org/bots"
REFERENCE_DIR="reference"
CACHE_FILE="${REFERENCE_DIR}/.version_cache"

# Files to download
declare -A FILES=(
    ["api.html"]="${TELEGRAM_BASE_URL}/api"
    ["features.html"]="${TELEGRAM_BASE_URL}/features"
    ["tutorial.html"]="${TELEGRAM_BASE_URL}/tutorial"
)

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if curl is available
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed."
        log_error "Install with: brew install curl (macOS) or apt-get install curl (Linux)"
        exit 1
    fi
}

# Create reference directory if it doesn't exist
setup_directories() {
    if [ ! -d "$REFERENCE_DIR" ]; then
        log_info "Creating reference directory..."
        mkdir -p "$REFERENCE_DIR"
    fi
}

# Download a single file
download_file() {
    local filename=$1
    local url=$2
    local output_path="${REFERENCE_DIR}/${filename}"

    log_info "Downloading ${filename} from ${url}..."

    # Download with curl, following redirects, with timeout
    if curl -L -f -s -S --max-time 30 -o "${output_path}" "${url}"; then
        log_info "✓ Successfully downloaded ${filename}"
        return 0
    else
        log_error "✗ Failed to download ${filename}"
        return 1
    fi
}

# Extract Bot API version from api.html if possible
extract_version() {
    local api_file="${REFERENCE_DIR}/api.html"

    if [ -f "$api_file" ]; then
        # Try to extract version from HTML (format may vary)
        # Look for patterns like "Bot API 7.0" or version number
        local version=$(grep -oE 'Bot API [0-9]+\.[0-9]+' "$api_file" | head -1 || echo "unknown")
        echo "$version"
    else
        echo "unknown"
    fi
}

# Save download metadata
save_metadata() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local version=$(extract_version)

    cat > "$CACHE_FILE" <<EOF
# Telegram Bot API Specification Download Metadata
# This file tracks when the specification was last downloaded

download_timestamp: $timestamp
bot_api_version: $version
files_downloaded: ${!FILES[@]}

# To update the specification, run:
#   ./scripts/bootstrap.sh
# Then regenerate types with:
#   ./scripts/regenerate.sh
EOF

    log_info "Metadata saved to ${CACHE_FILE}"
    log_info "Bot API version: ${version}"
}

# Check if files need updating
check_freshness() {
    if [ ! -f "$CACHE_FILE" ]; then
        return 1  # Need update
    fi

    # Check if cache is older than 7 days
    if [ "$(uname)" = "Darwin" ]; then
        # macOS
        cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))
    else
        # Linux
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    fi

    local days_old=$((cache_age / 86400))

    if [ $days_old -gt 7 ]; then
        log_warn "Specification is ${days_old} days old (recommended: update weekly)"
        return 1
    fi

    return 0
}

# Main bootstrap function
bootstrap() {
    log_info "Telegram Bot API Specification Bootstrap"
    log_info "========================================"

    check_dependencies
    setup_directories

    # Check if we should skip download
    if [ "${FORCE_DOWNLOAD:-0}" != "1" ] && check_freshness; then
        log_info "Specification is up to date (use FORCE_DOWNLOAD=1 to force update)"
        return 0
    fi

    # Download all files
    local failed=0
    for filename in "${!FILES[@]}"; do
        if ! download_file "$filename" "${FILES[$filename]}"; then
            failed=$((failed + 1))
        fi
    done

    if [ $failed -gt 0 ]; then
        log_error "Failed to download ${failed} file(s)"
        exit 1
    fi

    # Save metadata
    save_metadata

    log_info "========================================"
    log_info "Bootstrap complete! All files downloaded successfully."
    log_info ""
    log_info "Next steps:"
    log_info "  1. Review changes: diff reference/api.html (if git tracked)"
    log_info "  2. Regenerate types: ./scripts/regenerate.sh"
    log_info "  3. Run tests: dune runtest"
    log_info "  4. Update CHANGELOG.md with Bot API version"
}

# Run bootstrap
bootstrap
