#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEVEN_DIR="$ROOT_DIR/seven"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
KERNEL_OUT="$BUILD_ROOT/kernel"
BUILDROOT_SRC="$BUILD_ROOT/buildroot"
BUILDROOT_OUT="$BUILD_ROOT/rootfs"
BUILDROOT_VERSION="${BUILDROOT_VERSION:-2026.08}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 2)}"

LLVM_MINGW_VERSION="20260922"
LLVM_MINGW_ARCHIVE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-x86_64.tar.xz"
LLVM_MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/${LLVM_MINGW_ARCHIVE}"
LLVM_MINGW_SHA256="bb7bb7654b33d5aa8712acb837c963b2e0c56352560c76105270a3268c665c21"
LLVM_MINGW_DEFAULT_DIR="$BUILD_ROOT/${LLVM_MINGW_ARCHIVE%.tar.xz}"
LLVM_MINGW_DIR="${SEVEN_LLVM_MINGW_DIR:-$LLVM_MINGW_DEFAULT_DIR}"
DOWNLOAD_DIR="$BUILD_ROOT/downloads"

die() {
    echo "[Seven] $*" >&2
    exit 1
}

require() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

verify_sha256() {
    local file="$1"
    local expected="$2"
    printf '%s  %s\n' "$expected" "$file" | sha256sum -c - >/dev/null 2>&1
}

prepare_llvm_mingw() {
    if [ -n "${SEVEN_LLVM_MINGW_DIR:-}" ]; then
        echo "[Seven] Using custom LLVM-MinGW: $LLVM_MINGW_DIR"
    else
        local archive="$DOWNLOAD_DIR/$LLVM_MINGW_ARCHIVE"

        mkdir -p "$DOWNLOAD_DIR"

        if [ -f "$archive" ] && ! verify_sha256 "$archive" "$LLVM_MINGW_SHA256"; then
            echo "[Seven] Cached LLVM-MinGW checksum mismatch; downloading it again."
            rm -f "$archive"
        fi

        if [ ! -f "$archive" ]; then
            echo "[Seven] Fetching LLVM-MinGW $LLVM_MINGW_VERSION..."
            rm -f "$archive.part"
            wget -O "$archive.part" "$LLVM_MINGW_URL"
            mv "$archive.part" "$archive"
        fi

        verify_sha256 "$archive" "$LLVM_MINGW_SHA256" || {
            rm -f "$archive"
            die "LLVM-MinGW SHA-256 verification failed."
        }

        if [ ! -x "$LLVM_MINGW_DIR/bin/i686-w64-mingw32-clang" ] || \
           [ ! -x "$LLVM_MINGW_DIR/bin/x86_64-w64-mingw32-clang" ]; then
            echo "[Seven] Extracting LLVM-MinGW..."
            rm -rf "$LLVM_MINGW_DIR"
            tar -xJf "$archive" -C "$BUILD_ROOT"
        fi
    fi

    [ -x "$LLVM_MINGW_DIR/bin/i686-w64-mingw32-clang" ] || \
        die "LLVM-MinGW i686 compiler not found in $LLVM_MINGW_DIR"
    [ -x "$LLVM_MINGW_DIR/bin/x86_64-w64-mingw32-clang" ] || \
        die "LLVM-MinGW x86_64 compiler not found in $LLVM_MINGW_DIR"

    export PATH="$LLVM_MINGW_DIR/bin:$PATH"
}

for cmd in git make gcc g++ bc bison flex perl python3 rsync cpio gzip patch tar wget file sha256sum xz; do
    require "$cmd"
done

mkdir -p "$BUILD_ROOT" "$KERNEL_OUT" "$BUILDROOT_OUT"

echo "[Seven] Configuring kernel..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" x86_64_defconfig

"$ROOT_DIR/scripts/config" --file "$KERNEL_OUT/.config" \
    -e BLK_DEV_INITRD \
    -e DEVTMPFS \
    -e DEVTMPFS_MOUNT \
    -e TMPFS \
    -e PROC_FS \
    -e SYSFS \
    -e TTY \
    -e SERIAL_8250 \
    -e SERIAL_8250_CONSOLE \
    -e UNIX \
    -e INET \
    -e PACKET \
    -e VIRTIO \
    -e VIRTIO_PCI \
    -e VIRTIO_NET \
    -e BINFMT_SCRIPT \
    -e BINFMT_MISC \
    -e NTSYNC

make -C "$ROOT_DIR" O="$KERNEL_OUT" olddefconfig

for required in CONFIG_BINFMT_MISC=y CONFIG_NTSYNC=y; do
    grep -qx "$required" "$KERNEL_OUT/.config" || \
        die "Required kernel feature missing: $required"
done

echo "[Seven] Building Seven Kernel..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" -j"$JOBS" bzImage

if [ ! -d "$BUILDROOT_SRC/.git" ]; then
    echo "[Seven] Fetching Buildroot $BUILDROOT_VERSION..."
    git clone --depth 1 --branch "$BUILDROOT_VERSION" \
        https://github.com/buildroot/buildroot.git "$BUILDROOT_SRC"
else
    echo "[Seven] Using existing Buildroot checkout."
fi

prepare_llvm_mingw

echo "[Seven] Enabling Wine 11 new WoW64 support..."
python3 "$SEVEN_DIR/scripts/patch-buildroot-wine.py" "$BUILDROOT_SRC"

echo "[Seven] Configuring Seven userspace..."
make -C "$BUILDROOT_SRC" \
    O="$BUILDROOT_OUT" \
    BR2_EXTERNAL="$SEVEN_DIR" \
    seven_x86_64_defconfig

for required in BR2_PACKAGE_SEVEN_WIN=y BR2_PACKAGE_WINE=y; do
    grep -qx "$required" "$BUILDROOT_OUT/.config" || \
        die "Required userspace feature missing: $required"
done

echo "[Seven] Building Seven userspace..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" -j"$JOBS"

for required_file in \
    "$BUILDROOT_OUT/target/usr/bin/wine" \
    "$BUILDROOT_OUT/target/usr/bin/seven-winexec"; do
    [ -x "$required_file" ] || die "Required runtime file missing: $required_file"
done

IMAGES="$BUILD_ROOT/images"
mkdir -p "$IMAGES"

cp "$KERNEL_OUT/arch/x86/boot/bzImage" "$IMAGES/seven-kernel"
cp "$BUILDROOT_OUT/images/rootfs.cpio.gz" "$IMAGES/seven-initramfs.cpio.gz"

echo
echo "Seven OS boot artifacts:"
echo "  Kernel:    $IMAGES/seven-kernel"
echo "  Initramfs: $IMAGES/seven-initramfs.cpio.gz"
echo
echo "Windows compatibility:"
echo "  Wine:      $BUILDROOT_OUT/target/usr/bin/wine"
echo "  WinExec:   $BUILDROOT_OUT/target/usr/bin/seven-winexec"
echo
echo "Run with:"
echo "  bash seven/run-qemu.sh"
