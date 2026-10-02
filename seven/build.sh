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

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

for cmd in git make gcc g++ bc bison flex perl rsync cpio gzip patch tar wget file; do
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
    grep -qx "$required" "$KERNEL_OUT/.config" || {
        echo "[Seven] Required kernel feature missing: $required" >&2
        exit 1
    }
done

echo "[Seven] Building Seven Kernel..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" -j"$JOBS" bzImage

if [ ! -d "$BUILDROOT_SRC/.git" ]; then
    echo "[Seven] Fetching Buildroot $BUILDROOT_VERSION..."
    git clone --depth 1 --branch "$BUILDROOT_VERSION"         https://github.com/buildroot/buildroot.git "$BUILDROOT_SRC"
else
    echo "[Seven] Using existing Buildroot checkout."
fi

echo "[Seven] Configuring Seven userspace..."
make -C "$BUILDROOT_SRC"     O="$BUILDROOT_OUT"     BR2_EXTERNAL="$SEVEN_DIR"     seven_x86_64_defconfig

echo "[Seven] Building Seven userspace..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" -j"$JOBS"

IMAGES="$BUILD_ROOT/images"
mkdir -p "$IMAGES"

cp "$KERNEL_OUT/arch/x86/boot/bzImage" "$IMAGES/seven-kernel"
cp "$BUILDROOT_OUT/images/rootfs.cpio.gz" "$IMAGES/seven-initramfs.cpio.gz"

echo
echo "Seven OS boot artifacts:"
echo "  Kernel:    $IMAGES/seven-kernel"
echo "  Initramfs: $IMAGES/seven-initramfs.cpio.gz"
echo
echo "Run with:"
echo "  bash seven/run-qemu.sh"
