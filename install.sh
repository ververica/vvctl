#!/bin/bash

# Simple vvctl installer - downloads and installs the latest release or a specific version
# Usage: ./install.sh [version]
# Example: ./install.sh v1.2.3

set -e

INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
REPO="ververica/vvctl"
TEMP_DIR=$(mktemp -d)
VERSION_ARG="$1"

# Detect platform and return the target triple used in releases
detect_platform() {
    local target
    case "$(uname -s)" in
        Linux*)
            case "$(uname -m)" in
                x86_64|amd64) target="x86_64-unknown-linux-gnu";;
                *)            echo "Error: Unsupported Linux architecture $(uname -m)" >&2; exit 1;;
            esac
            ;;
        Darwin*)
            case "$(uname -m)" in
                arm64|aarch64) target="aarch64-apple-darwin";;
                x86_64|amd64)  target="x86_64-apple-darwin";;
                *)             echo "Error: Unsupported macOS architecture $(uname -m)" >&2; exit 1;;
            esac
            ;;
        *)       echo "Error: Unsupported OS $(uname -s)" >&2; exit 1;;
    esac

    echo "$target"
}

# Get latest version and download
echo "Installing vvctl..."
PLATFORM=$(detect_platform)

if [ -n "$VERSION_ARG" ]; then
    VERSION="$VERSION_ARG"
    echo "Using specified version: ${VERSION}"
else
    VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$VERSION" ]; then
        echo "Error: Failed to get latest version" >&2
        exit 1
    fi

    echo "Using latest version: ${VERSION}"
fi

echo "Downloading vvctl ${VERSION} for ${PLATFORM}..."
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/vvctl-${VERSION}-${PLATFORM}.tar.gz"

if ! curl -L -o "${TEMP_DIR}/vvctl.tar.gz" "$DOWNLOAD_URL"; then
    echo "Error: Failed to download vvctl from $DOWNLOAD_URL" >&2
    exit 1
fi

# Verify the download
if [ ! -f "${TEMP_DIR}/vvctl.tar.gz" ] || [ ! -s "${TEMP_DIR}/vvctl.tar.gz" ]; then
    echo "Error: Downloaded file is missing or empty" >&2
    exit 1
fi

# Extract the binary
echo "Extracting vvctl..."
if ! tar -xzf "${TEMP_DIR}/vvctl.tar.gz" -C "${TEMP_DIR}"; then
    echo "Error: Failed to extract vvctl" >&2
    exit 1
fi

# Find and move the binary (it's in a subdirectory)
EXTRACTED_DIR="${TEMP_DIR}/vvctl-${VERSION}-${PLATFORM}"
if [ -f "${EXTRACTED_DIR}/vvctl" ]; then
    mv "${EXTRACTED_DIR}/vvctl" "${TEMP_DIR}/vvctl"
else
    echo "Error: Could not find vvctl binary in extracted archive" >&2
    echo "Contents of ${TEMP_DIR}:" >&2
    ls -la "${TEMP_DIR}" >&2
    exit 1
fi

# Verify extraction
if [ ! -f "${TEMP_DIR}/vvctl" ] || [ ! -s "${TEMP_DIR}/vvctl" ]; then
    echo "Error: Extracted binary is missing or empty" >&2
    exit 1
fi

# Install
chmod +x "${TEMP_DIR}/vvctl"
echo "Installing to ${INSTALL_DIR}/vvctl..."

if [ -w "$INSTALL_DIR" ]; then
    cp "${TEMP_DIR}/vvctl" "${INSTALL_DIR}/vvctl"
else
    sudo cp "${TEMP_DIR}/vvctl" "${INSTALL_DIR}/vvctl"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "vvctl installed successfully!"
echo "Run 'vvctl --help' to get started"
