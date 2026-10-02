#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEVEN_DIR="$ROOT_DIR/seven"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
IMAGES="$BUILD_ROOT/images"
ISO_ROOT="$BUILD_ROOT/iso-root"
OUTPUT="$IMAGES/seven-os-live.iso"

die() {
    echo "[Seven ISO] $*" >&2
    exit 1
}

command -v grub-mkrescue >/dev/null 2>&1 || die "grub-mkrescue is required."
command -v xorriso >/dev/null 2>&1 || die "xorriso is required."

[ -f "$IMAGES/seven-kernel" ] || die "Run bash seven/build.sh first."
[ -f "$IMAGES/seven-initramfs.cpio.gz" ] || die "Run bash seven/build.sh first."

rm -rf "$ISO_ROOT"
mkdir -p "$ISO_ROOT/boot/grub"

cp "$IMAGES/seven-kernel" "$ISO_ROOT/boot/seven-kernel"
cp "$IMAGES/seven-initramfs.cpio.gz" "$ISO_ROOT/boot/seven-initramfs.cpio.gz"
cp "$SEVEN_DIR/board/seven/grub-live.cfg" "$ISO_ROOT/boot/grub/grub.cfg"

echo "[Seven ISO] Building $OUTPUT..."
grub-mkrescue -o "$OUTPUT" "$ISO_ROOT"

echo "[Seven ISO] Created: $OUTPUT"
