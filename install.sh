#!/bin/bash

# Simple vvctl installer - downloads and installs the latest release or a specific version
# Usage: ./install.sh [version]
# Usage: ./install.sh --preview (installs latest prerelease)
# Example: ./install.sh v1.2.3

set -e

if [ -z "${INSTALL_DIR:-}" ]; then
    if [ -z "${HOME:-}" ]; then
        echo "Error: HOME is not set; export HOME or pass INSTALL_DIR explicitly" >&2
        exit 1
    fi
    INSTALL_DIR="$HOME/.local/bin"
fi
REPO="ververica/vvctl"
TEMP_DIR=$(mktemp -d)
# TMP_BIN is set later, once the swap begins; referencing it before then
# expands to an empty string. Clear any value inherited from the caller's
# environment so an early failure can't delete a file it doesn't own.
TMP_BIN=""
# dash (the installer's shell on some systems) does not run EXIT traps on a
# signal, so INT and TERM get their own traps that clean up and then exit,
# instead of cleaning up and letting the script continue past the
# interruption.
cleanup() { rm -f "$TMP_BIN"; rm -rf "$TEMP_DIR"; }
trap cleanup EXIT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
VERSION_ARG="$1"
PREVIEW_MODE=false

# Parse arguments
if [ "$1" = "--preview" ]; then
    PREVIEW_MODE=true
    VERSION_ARG=""
fi

# Detect platform and return the target triple used in releases
detect_platform() {
    local target
    case "$(uname -s)" in
        Linux*)
            # Release binaries link against glibc and cannot start on musl (e.g. Alpine).
            case "$(ldd --version 2>&1 || true)" in
                *musl*) echo "Error: Unsupported Linux libc musl; vvctl requires glibc" >&2; exit 1;;
            esac
            case "$(uname -m)" in
                x86_64|amd64)  target="x86_64-unknown-linux-gnu";;
                aarch64|arm64) target="aarch64-unknown-linux-gnu";;
                *)             echo "Error: Unsupported Linux architecture $(uname -m)" >&2; exit 1;;
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
elif [ "$PREVIEW_MODE" = true ]; then
    # Get latest prerelease by fetching all releases and finding the most recent one
    echo "Fetching latest prerelease..."
    VERSION=$(curl -s "https://api.github.com/repos/${REPO}/releases" | \
        grep -E '"tag_name"|"prerelease"' | \
        paste - - | \
        grep 'true' | \
        head -1 | \
        sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

    if [ -z "$VERSION" ]; then
        echo "Error: Failed to get latest prerelease version" >&2
        exit 1
    fi

    echo "Using latest prerelease version: ${VERSION}"
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

# Swap by rename: create an unpredictable temp file in the same directory
# with `mktemp` (atomic, exclusive creation, so it never follows a
# pre-existing symlink planted at a guessable path), copy the binary into
# it, then `mv -f` it onto the target. A rename never touches the old
# file's inode, so a running vvctl (or macOS's signature cache) keeps
# reading the old bytes until it re-execs, instead of exiting 137
# mid-copy.
if mkdir -p "$INSTALL_DIR" 2>/dev/null && [ -w "$INSTALL_DIR" ]; then
    TMP_BIN=$(mktemp "${INSTALL_DIR}/.vvctl.XXXXXX")
    cp "${TEMP_DIR}/vvctl" "$TMP_BIN"
    chmod 755 "$TMP_BIN"
    mv -f "$TMP_BIN" "${INSTALL_DIR}/vvctl"
else
    # One `sudo sh -c` bundles mkdir+cp+chmod+mv so the user is prompted
    # once, not four times, and a missing privileged directory (e.g.
    # /opt/vvctl/bin) is created under the same privilege decision as the
    # swap. Paths go in as arguments, never into the command string. The
    # helper echoes the exact mktemp path it created as its first line of
    # output so a failure can clean up precisely that file instead of
    # globbing every ".vvctl.*" temp file in the directory (which could
    # belong to a concurrent install).
    if ! TMP_BIN=$(sudo sh -c '
            mkdir -p "$1" || exit 1
            tmp=$(mktemp "$1/.vvctl.XXXXXX") || exit 1
            echo "$tmp"
            cp "$2" "$tmp" && chmod 755 "$tmp" && mv -f "$tmp" "$1/vvctl"
        ' sh "$INSTALL_DIR" "${TEMP_DIR}/vvctl"); then
        [ -n "$TMP_BIN" ] && sudo rm -f "$TMP_BIN"
        exit 1
    fi
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "vvctl installed successfully!"

# Check if INSTALL_DIR is in PATH
case ":$PATH:" in
    *":${INSTALL_DIR}:"*) ;;
    *)
        echo ""
        echo "WARNING: ${INSTALL_DIR} is not in your PATH."
        echo "Add it by appending the following line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo ""
        echo "  export PATH=\"${INSTALL_DIR}:\$PATH\""
        echo ""
        echo "Then restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
        ;;
esac

echo "Run 'vvctl --help' to get started"
