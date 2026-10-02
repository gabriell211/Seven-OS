#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEVEN_DIR="$ROOT_DIR/seven"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
BUILDROOT_SRC="$BUILD_ROOT/buildroot"
BUILDROOT_OUT="$BUILD_ROOT/rootfs"
HOST="$BUILDROOT_OUT/host"
IMAGES="$BUILD_ROOT/images"
ISO_ROOT="$BUILD_ROOT/iso-root"
OUTPUT="$IMAGES/seven-os-live.iso"

die() {
    echo "[Seven ISO] $*" >&2
    exit 1
}

[ -d "$BUILDROOT_SRC" ] || die "Buildroot source is missing. Run bash seven/build.sh first."
[ -f "$IMAGES/seven-kernel" ] || die "Seven kernel is missing. Run bash seven/build.sh first."
[ -f "$IMAGES/seven-initramfs.cpio.gz" ] || die "Seven initramfs is missing. Run bash seven/build.sh first."
[ -f "$IMAGES/seven-os.img" ] || die "Seven UEFI install image is missing. Run bash seven/build.sh first."

echo "[Seven ISO] Building host GRUB and xorriso..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" host-grub2 host-xorriso

GRUB_MKRESCUE="$HOST/bin/grub-mkrescue"
XORRISO="$HOST/bin/xorriso"

[ -x "$GRUB_MKRESCUE" ] || die "Buildroot grub-mkrescue was not generated."
[ -x "$XORRISO" ] || die "Buildroot xorriso was not generated."

rm -rf "$ISO_ROOT"
mkdir -p "$ISO_ROOT/boot/grub" "$ISO_ROOT/seven"

cp "$IMAGES/seven-kernel" "$ISO_ROOT/boot/seven-kernel"
cp "$IMAGES/seven-initramfs.cpio.gz" "$ISO_ROOT/boot/seven-initramfs.cpio.gz"
cp "$IMAGES/seven-os.img" "$ISO_ROOT/seven/seven-os.img"
cp "$SEVEN_DIR/board/seven/grub-live.cfg" "$ISO_ROOT/boot/grub/grub.cfg"

(
    cd "$ISO_ROOT/seven"
    sha256sum seven-os.img > seven-os.img.sha256
)

echo "[Seven ISO] Building $OUTPUT..."
PATH="$HOST/bin:$PATH" \
    "$GRUB_MKRESCUE" \
    -o "$OUTPUT" \
    "$ISO_ROOT" \
    -- \
    -volid SEVEN_OS

[ -f "$OUTPUT" ] || die "Live ISO was not generated."

echo "[Seven ISO] Created: $OUTPUT"
echo "[Seven ISO] Embedded installer payload: /seven/seven-os.img"
