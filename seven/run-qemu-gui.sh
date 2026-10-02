#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
KERNEL="$BUILD_ROOT/images/seven-kernel"
ROOTFS="$BUILD_ROOT/images/rootfs.ext2"

command -v qemu-system-x86_64 >/dev/null 2>&1 || {
    echo "qemu-system-x86_64 is required." >&2
    exit 1
}

[ -f "$KERNEL" ] || {
    echo "Seven kernel not found. Run: bash seven/build.sh" >&2
    exit 1
}

[ -f "$ROOTFS" ] || {
    echo "Seven root filesystem not found. Run: bash seven/build.sh" >&2
    exit 1
}

KVM_ARGS=()
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ARGS=(-enable-kvm -cpu host)
fi

exec qemu-system-x86_64     "${KVM_ARGS[@]}"     -m 4096     -smp 4     -kernel "$KERNEL"     -drive "file=$ROOTFS,format=raw,if=virtio"     -append "root=/dev/vda rootwait rw quiet loglevel=3"     -device virtio-vga     -device qemu-xhci     -device usb-tablet     -device virtio-keyboard-pci     -nic user,model=virtio-net-pci     -no-reboot
